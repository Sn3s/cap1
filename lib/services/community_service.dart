part of '../main.dart';

// ─── Cooperative personal informatics: data layer ───────────────────────────
//
// Social data lives in its own Firestore collections, never in the private
// `profiles/{uid}` document (which is owner-only and replaced on every save):
//
//   userDirectory/{emailLower}       exact-match email lookup (get only)
//   friendRequests/{fromUid_toUid}   pending requests, deleted on answer
//   friendships/{uidA_uidB}          accepted pairs with profile snapshots
//   posts/{postId}                   fan-out-on-write: `audience` lists every
//                                    uid allowed to read the post
//   posts/{postId}/comments/{id}     replies
//   users/{uid}/notifications/{id}   likes, replies and accepted requests
//                                    sent to {uid} by their friends
//
// `CommunityController` (core/community_state.dart) talks to a
// `CommunityBackend`; Firestore in production, in-memory for tests and for
// signed-out demo sessions. Nothing here reads or writes the Health Score.

const communityPostMaxLength = 250;
const communityFeedLimit = 50;

enum PostVisibility { friends, onlyMe }

extension PostVisibilityX on PostVisibility {
  String get wire => this == PostVisibility.friends ? 'friends' : 'only_me';
  String get label => this == PostVisibility.friends ? 'Friends' : 'Only Me';
  String get detail => this == PostVisibility.friends
      ? 'Visible in your friends’ community feed'
      : 'A private note only you can see';
  IconData get icon => this == PostVisibility.friends
      ? Icons.visibility_rounded
      : Icons.visibility_off_rounded;

  static PostVisibility parse(Object? value) =>
      value == 'only_me' ? PostVisibility.onlyMe : PostVisibility.friends;
}

String normalizeCommunityEmail(String email) => email.trim().toLowerCase();

DateTime _communityDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  // Pending server timestamps read back as null until the write lands.
  return DateTime.now();
}

class CommunityException implements Exception {
  const CommunityException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SocialProfile {
  const SocialProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return email.isEmpty ? '?' : email.substring(0, 1).toUpperCase();
    }
    final first = parts.first.substring(0, 1);
    final last = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return (first + last).toUpperCase();
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'emailLower': normalizeCommunityEmail(email),
        if ((photoUrl ?? '').isNotEmpty) 'photoUrl': photoUrl,
      };

  static SocialProfile fromMap(Map<String, dynamic> data) => SocialProfile(
        uid: data['uid']?.toString() ?? '',
        displayName: data['displayName']?.toString() ?? 'Shelby friend',
        email: data['email']?.toString() ?? '',
        photoUrl: data['photoUrl']?.toString(),
      );

  @override
  bool operator ==(Object other) =>
      other is SocialProfile &&
      other.uid == uid &&
      other.displayName == displayName &&
      other.email == email &&
      other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(uid, displayName, email, photoUrl);
}

/// A milestone, badge, streak or stat a user chose to attach to a post.
/// Only these display strings travel; never balances or account details
/// beyond what the user previews in the share sheet.
class ShareableAchievement {
  const ShareableAchievement({
    required this.kind,
    required this.title,
    required this.value,
    required this.detail,
    required this.colorValue,
    required this.iconKey,
  });

  /// streak | badge | score | milestone | goal | scorecard
  final String kind;
  final String title;
  final String value;
  final String detail;
  final int colorValue;
  final String iconKey;

  Color get color => Color(colorValue);
  IconData get icon => _shareIcons[iconKey] ?? Icons.emoji_events_rounded;

  Map<String, dynamic> toMap() => {
        'kind': kind,
        'title': title,
        'value': value,
        'detail': detail,
        'colorValue': colorValue,
        'iconKey': iconKey,
      };

  static ShareableAchievement? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final data = Map<String, dynamic>.from(raw);
    return ShareableAchievement(
      kind: data['kind']?.toString() ?? 'badge',
      title: data['title']?.toString() ?? '',
      value: data['value']?.toString() ?? '',
      detail: data['detail']?.toString() ?? '',
      colorValue: (data['colorValue'] as num?)?.toInt() ?? _brand.toARGB32(),
      iconKey: data['iconKey']?.toString() ?? 'trophy',
    );
  }
}

const _shareIcons = <String, IconData>{
  'fire': Icons.local_fire_department_rounded,
  'trophy': Icons.emoji_events_rounded,
  'shield': Icons.shield_rounded,
  'trending': Icons.trending_up_rounded,
  'flag': Icons.flag_rounded,
  'celebration': Icons.celebration_rounded,
  'score': Icons.speed_rounded,
  'star': Icons.star_rounded,
  'label': Icons.sell_rounded,
  'savings': Icons.savings_rounded,
  'heart': Icons.favorite_rounded,
  'wallet': Icons.account_balance_wallet_rounded,
};

class FriendRequest {
  const FriendRequest({
    required this.from,
    required this.to,
    required this.createdAt,
  });

  final SocialProfile from;
  final SocialProfile to;
  final DateTime createdAt;

  String get id => friendRequestId(from.uid, to.uid);

  static FriendRequest fromMap(Map<String, dynamic> data) => FriendRequest(
        from: SocialProfile.fromMap(Map<String, dynamic>.from(
            data['from'] as Map? ?? {'uid': data['fromUid']})),
        to: SocialProfile.fromMap(Map<String, dynamic>.from(
            data['to'] as Map? ?? {'uid': data['toUid']})),
        createdAt: _communityDate(data['createdAt']),
      );
}

String friendRequestId(String fromUid, String toUid) => '${fromUid}_$toUid';

/// Order-independent id so A→B and B→A resolve to the same friendship.
String friendshipId(String a, String b) =>
    a.compareTo(b) <= 0 ? '${a}_$b' : '${b}_$a';

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.author,
    required this.message,
    required this.visibility,
    required this.createdAt,
    this.achievement,
    this.likedBy = const [],
    this.commentCount = 0,
  });

  final String id;
  final SocialProfile author;
  final String message;
  final PostVisibility visibility;
  final DateTime createdAt;
  final ShareableAchievement? achievement;
  final List<String> likedBy;
  final int commentCount;

  int get likeCount => likedBy.length;
  bool isLikedBy(String uid) => likedBy.contains(uid);

  CommunityPost copyWith({List<String>? likedBy, int? commentCount}) =>
      CommunityPost(
        id: id,
        author: author,
        message: message,
        visibility: visibility,
        createdAt: createdAt,
        achievement: achievement,
        likedBy: likedBy ?? this.likedBy,
        commentCount: commentCount ?? this.commentCount,
      );

  static CommunityPost fromMap(String id, Map<String, dynamic> data) =>
      CommunityPost(
        id: id,
        author: SocialProfile.fromMap(Map<String, dynamic>.from(
            data['author'] as Map? ?? {'uid': data['authorUid']})),
        message: data['message']?.toString() ?? '',
        visibility: PostVisibilityX.parse(data['visibility']),
        createdAt: _communityDate(data['createdAt']),
        achievement: ShareableAchievement.fromMap(data['achievement']),
        likedBy: [
          if (data['likedBy'] is List)
            for (final uid in data['likedBy'] as List) uid.toString(),
        ],
        commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      );
}

class PostComment {
  const PostComment({
    required this.id,
    required this.author,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final SocialProfile author;
  final String message;
  final DateTime createdAt;

  static PostComment fromMap(String id, Map<String, dynamic> data) =>
      PostComment(
        id: id,
        author: SocialProfile.fromMap(Map<String, dynamic>.from(
            data['author'] as Map? ?? {'uid': data['authorUid']})),
        message: data['message']?.toString() ?? '',
        createdAt: _communityDate(data['createdAt']),
      );
}

enum CommunityNotificationType { reply, like, friendAccepted }

extension CommunityNotificationTypeX on CommunityNotificationType {
  String get wire => switch (this) {
        CommunityNotificationType.reply => 'reply',
        CommunityNotificationType.like => 'like',
        CommunityNotificationType.friendAccepted => 'friend_accepted',
      };

  static CommunityNotificationType parse(Object? value) => switch (value) {
        'like' => CommunityNotificationType.like,
        'friend_accepted' => CommunityNotificationType.friendAccepted,
        _ => CommunityNotificationType.reply,
      };
}

/// An activity item in someone's Community notifications bell.
class CommunityNotification {
  const CommunityNotification({
    required this.id,
    required this.type,
    required this.actor,
    required this.createdAt,
    this.postId,
    this.preview = '',
    this.read = false,
  });

  final String id;
  final CommunityNotificationType type;
  final SocialProfile actor;
  final DateTime createdAt;
  final String? postId;
  final String preview;
  final bool read;

  /// Likes use a stable id so re-liking replaces instead of stacking.
  static String likeId(String postId, String actorUid) =>
      'like_${postId}_$actorUid';

  CommunityNotification copyWith({bool? read}) => CommunityNotification(
        id: id,
        type: type,
        actor: actor,
        createdAt: createdAt,
        postId: postId,
        preview: preview,
        read: read ?? this.read,
      );

  Map<String, dynamic> toMap() => {
        'type': type.wire,
        'actorUid': actor.uid,
        'actor': actor.toMap(),
        if (postId != null) 'postId': postId,
        'preview': preview,
        'read': read,
      };

  static CommunityNotification fromMap(String id, Map<String, dynamic> data) =>
      CommunityNotification(
        id: id,
        type: CommunityNotificationTypeX.parse(data['type']),
        actor: SocialProfile.fromMap(Map<String, dynamic>.from(
            data['actor'] as Map? ?? {'uid': data['actorUid']})),
        createdAt: _communityDate(data['createdAt']),
        postId: data['postId']?.toString(),
        preview: data['preview']?.toString() ?? '',
        read: data['read'] == true,
      );
}

/// Storage contract for the community feature. Every method is scoped to
/// what the signed-in user may see; Firestore rules enforce the same scope
/// server-side (see firestore.rules).
abstract class CommunityBackend {
  Future<void> upsertProfile(SocialProfile me);

  /// Hides [me] from email search ("Let friends find me" off).
  Future<void> removeFromDirectory(SocialProfile me);
  Future<SocialProfile?> findByEmail(String email);

  Stream<List<FriendRequest>> incomingRequests(String uid);
  Stream<List<FriendRequest>> outgoingRequests(String uid);
  Stream<List<SocialProfile>> friends(String uid);
  Stream<List<CommunityPost>> feed(String uid);
  Stream<List<PostComment>> comments(String postId);

  Future<void> sendFriendRequest({
    required SocialProfile from,
    required SocialProfile to,
  });
  Future<void> acceptFriendRequest(FriendRequest request);
  Future<void> deleteFriendRequest(FriendRequest request);
  Future<void> removeFriend({required String uid, required String friendUid});

  Stream<List<CommunityNotification>> notifications(String uid);
  Future<void> sendNotification({
    required String toUid,
    required CommunityNotification notification,
  });
  Future<void> markNotificationsRead({
    required String uid,
    required List<String> ids,
  });

  Future<String> createPost({
    required SocialProfile author,
    required String message,
    required PostVisibility visibility,
    required List<String> audience,
    ShareableAchievement? achievement,
  });
  Future<void> deletePost(String postId);
  Future<void> setLiked({
    required String postId,
    required String uid,
    required bool liked,
  });
  Future<void> addComment({
    required String postId,
    required SocialProfile author,
    required String message,
  });
}

class FirestoreCommunityBackend implements CommunityBackend {
  FirestoreCommunityBackend([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _directory =>
      _db.collection('userDirectory');
  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('friendRequests');
  CollectionReference<Map<String, dynamic>> get _friendships =>
      _db.collection('friendships');
  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('posts');
  CollectionReference<Map<String, dynamic>> _inbox(String uid) =>
      _db.collection('users').doc(uid).collection('notifications');

  @override
  Future<void> upsertProfile(SocialProfile me) async {
    final key = normalizeCommunityEmail(me.email);
    if (key.isEmpty) return;
    await _directory.doc(key).set({
      ...me.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeFromDirectory(SocialProfile me) async {
    final key = normalizeCommunityEmail(me.email);
    if (key.isEmpty) return;
    final doc = _directory.doc(key);
    // Rules only allow deleting an entry you own, and deleting a missing
    // doc is rejected (no `resource`), so check first.
    final snapshot = await doc.get();
    if (snapshot.data()?['uid'] == me.uid) await doc.delete();
  }

  @override
  Future<SocialProfile?> findByEmail(String email) async {
    final key = normalizeCommunityEmail(email);
    if (key.isEmpty) return null;
    final snapshot = await _directory.doc(key).get();
    final data = snapshot.data();
    return data == null ? null : SocialProfile.fromMap(data);
  }

  @override
  Stream<List<FriendRequest>> incomingRequests(String uid) => _requests
      .where('toUid', isEqualTo: uid)
      .snapshots()
      .map(_requestsFrom);

  @override
  Stream<List<FriendRequest>> outgoingRequests(String uid) => _requests
      .where('fromUid', isEqualTo: uid)
      .snapshots()
      .map(_requestsFrom);

  List<FriendRequest> _requestsFrom(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) =>
      snapshot.docs.map((doc) => FriendRequest.fromMap(doc.data())).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Stream<List<SocialProfile>> friends(String uid) => _friendships
          .where('members', arrayContains: uid)
          .snapshots()
          .map((snapshot) {
        final result = <SocialProfile>[];
        for (final doc in snapshot.docs) {
          final profiles = doc.data()['profiles'];
          if (profiles is! Map) continue;
          for (final entry in profiles.entries) {
            if (entry.key == uid || entry.value is! Map) continue;
            result.add(SocialProfile.fromMap(
                Map<String, dynamic>.from(entry.value as Map)));
          }
        }
        result.sort((a, b) => a.displayName.compareTo(b.displayName));
        return result;
      });

  @override
  Stream<List<CommunityPost>> feed(String uid) => _posts
      .where('audience', arrayContains: uid)
      .orderBy('createdAt', descending: true)
      .limit(communityFeedLimit)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CommunityPost.fromMap(doc.id, doc.data()))
          .toList());

  @override
  Stream<List<PostComment>> comments(String postId) => _posts
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt')
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PostComment.fromMap(doc.id, doc.data()))
          .toList());

  @override
  Future<void> sendFriendRequest({
    required SocialProfile from,
    required SocialProfile to,
  }) {
    return _requests.doc(friendRequestId(from.uid, to.uid)).set({
      'fromUid': from.uid,
      'toUid': to.uid,
      'from': from.toMap(),
      'to': to.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> acceptFriendRequest(FriendRequest request) {
    // One atomic batch: the friendship appears and the request disappears
    // together. Rules only allow the recipient to create the friendship
    // while the matching request still exists.
    final batch = _db.batch()
      ..set(_friendships.doc(friendshipId(request.from.uid, request.to.uid)), {
        'members': [request.from.uid, request.to.uid],
        'requesterUid': request.from.uid,
        'accepterUid': request.to.uid,
        'profiles': {
          request.from.uid: request.from.toMap(),
          request.to.uid: request.to.toMap(),
        },
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..delete(_requests.doc(request.id));
    return batch.commit();
  }

  @override
  Future<void> deleteFriendRequest(FriendRequest request) =>
      _requests.doc(request.id).delete();

  @override
  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  }) =>
      _friendships.doc(friendshipId(uid, friendUid)).delete();

  @override
  Stream<List<CommunityNotification>> notifications(String uid) => _inbox(uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CommunityNotification.fromMap(doc.id, doc.data()))
          .toList());

  @override
  Future<void> sendNotification({
    required String toUid,
    required CommunityNotification notification,
  }) {
    final inbox = _inbox(toUid);
    final doc = notification.id.isEmpty ? inbox.doc() : inbox.doc(notification.id);
    return doc.set({
      ...notification.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markNotificationsRead({
    required String uid,
    required List<String> ids,
  }) {
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_inbox(uid).doc(id), {'read': true});
    }
    return batch.commit();
  }

  @override
  Future<String> createPost({
    required SocialProfile author,
    required String message,
    required PostVisibility visibility,
    required List<String> audience,
    ShareableAchievement? achievement,
  }) async {
    final doc = _posts.doc();
    await doc.set({
      'authorUid': author.uid,
      'author': author.toMap(),
      'message': message,
      'visibility': visibility.wire,
      'audience': audience,
      if (achievement != null) 'achievement': achievement.toMap(),
      'likedBy': <String>[],
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  @override
  Future<void> deletePost(String postId) => _posts.doc(postId).delete();

  @override
  Future<void> setLiked({
    required String postId,
    required String uid,
    required bool liked,
  }) {
    return _posts.doc(postId).update({
      'likedBy': liked
          ? FieldValue.arrayUnion([uid])
          : FieldValue.arrayRemove([uid]),
    });
  }

  @override
  Future<void> addComment({
    required String postId,
    required SocialProfile author,
    required String message,
  }) {
    final post = _posts.doc(postId);
    final batch = _db.batch()
      ..set(post.collection('comments').doc(), {
        'authorUid': author.uid,
        'author': author.toMap(),
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..update(post, {'commentCount': FieldValue.increment(1)});
    return batch.commit();
  }
}

/// Same contract as Firestore, held in memory. Used by tests and by
/// signed-out/demo sessions so the community screens are never empty shells.
class InMemoryCommunityBackend implements CommunityBackend {
  InMemoryCommunityBackend();

  final Map<String, SocialProfile> _directory = {};
  final Map<String, FriendRequest> _requests = {};
  final Map<String, List<SocialProfile>> _friendships = {};
  final Map<String, CommunityPost> _posts = {};
  final Map<String, List<String>> _audiences = {};
  final Map<String, List<PostComment>> _comments = {};
  final Map<String, Map<String, CommunityNotification>> _inboxes = {};
  final _changes = StreamController<void>.broadcast();
  var _nextId = 0;

  void _changed() => _changes.add(null);

  Stream<T> _watch<T>(T Function() read) => Stream<T>.multi((controller) {
        controller.add(read());
        final sub = _changes.stream.listen((_) => controller.add(read()));
        controller.onCancel = sub.cancel;
      });

  /// Registers a user so they can be found by email (test/demo helper).
  void registerUser(SocialProfile profile) {
    _directory[normalizeCommunityEmail(profile.email)] = profile;
  }

  /// Instantly links two users as friends (test/demo helper).
  void connectFriends(SocialProfile a, SocialProfile b) {
    _friendships[friendshipId(a.uid, b.uid)] = [a, b];
    _changed();
  }

  @override
  Future<void> upsertProfile(SocialProfile me) async {
    registerUser(me);
  }

  @override
  Future<void> removeFromDirectory(SocialProfile me) async {
    final key = normalizeCommunityEmail(me.email);
    if (_directory[key]?.uid == me.uid) _directory.remove(key);
  }

  @override
  Future<SocialProfile?> findByEmail(String email) async =>
      _directory[normalizeCommunityEmail(email)];

  @override
  Stream<List<FriendRequest>> incomingRequests(String uid) => _watch(() =>
      _requests.values.where((request) => request.to.uid == uid).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  @override
  Stream<List<FriendRequest>> outgoingRequests(String uid) => _watch(() =>
      _requests.values.where((request) => request.from.uid == uid).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  @override
  Stream<List<SocialProfile>> friends(String uid) => _watch(() => [
        for (final pair in _friendships.values)
          if (pair.any((member) => member.uid == uid))
            pair.firstWhere((member) => member.uid != uid),
      ]..sort((a, b) => a.displayName.compareTo(b.displayName)));

  @override
  Stream<List<CommunityPost>> feed(String uid) => _watch(() {
        final visible = [
          for (final post in _posts.values)
            if (_audiences[post.id]?.contains(uid) ?? false) post,
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return visible.take(communityFeedLimit).toList();
      });

  @override
  Stream<List<PostComment>> comments(String postId) =>
      _watch(() => List.of(_comments[postId] ?? const <PostComment>[]));

  @override
  Future<void> sendFriendRequest({
    required SocialProfile from,
    required SocialProfile to,
  }) async {
    final request =
        FriendRequest(from: from, to: to, createdAt: DateTime.now());
    _requests[request.id] = request;
    _changed();
  }

  @override
  Future<void> acceptFriendRequest(FriendRequest request) async {
    if (_requests.remove(request.id) == null) {
      throw const CommunityException('That request is no longer available.');
    }
    _friendships[friendshipId(request.from.uid, request.to.uid)] = [
      request.from,
      request.to,
    ];
    _changed();
  }

  @override
  Future<void> deleteFriendRequest(FriendRequest request) async {
    _requests.remove(request.id);
    _changed();
  }

  @override
  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  }) async {
    _friendships.remove(friendshipId(uid, friendUid));
    _changed();
  }

  @override
  Stream<List<CommunityNotification>> notifications(String uid) =>
      _watch(() => (_inboxes[uid]?.values.toList() ?? [])
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  @override
  Future<void> sendNotification({
    required String toUid,
    required CommunityNotification notification,
  }) async {
    final inbox = _inboxes[toUid] ??= {};
    final id = notification.id.isEmpty ? 'n-${_nextId++}' : notification.id;
    inbox[id] = CommunityNotification(
      id: id,
      type: notification.type,
      actor: notification.actor,
      createdAt: DateTime.now(),
      postId: notification.postId,
      preview: notification.preview,
    );
    _changed();
  }

  @override
  Future<void> markNotificationsRead({
    required String uid,
    required List<String> ids,
  }) async {
    final inbox = _inboxes[uid];
    if (inbox == null) return;
    for (final id in ids) {
      final item = inbox[id];
      if (item != null) inbox[id] = item.copyWith(read: true);
    }
    _changed();
  }

  @override
  Future<String> createPost({
    required SocialProfile author,
    required String message,
    required PostVisibility visibility,
    required List<String> audience,
    ShareableAchievement? achievement,
    DateTime? createdAt,
    List<String> likedBy = const [],
    int commentCount = 0,
  }) async {
    final id = 'post-${_nextId++}';
    _posts[id] = CommunityPost(
      id: id,
      author: author,
      message: message,
      visibility: visibility,
      createdAt: createdAt ?? DateTime.now(),
      achievement: achievement,
      likedBy: likedBy,
      commentCount: commentCount,
    );
    _audiences[id] = List.of(audience);
    _changed();
    return id;
  }

  @override
  Future<void> deletePost(String postId) async {
    _posts.remove(postId);
    _audiences.remove(postId);
    _comments.remove(postId);
    _changed();
  }

  @override
  Future<void> setLiked({
    required String postId,
    required String uid,
    required bool liked,
  }) async {
    final post = _posts[postId];
    if (post == null) return;
    final likedBy = {...post.likedBy};
    liked ? likedBy.add(uid) : likedBy.remove(uid);
    _posts[postId] = post.copyWith(likedBy: likedBy.toList());
    _changed();
  }

  @override
  Future<void> addComment({
    required String postId,
    required SocialProfile author,
    required String message,
  }) async {
    final post = _posts[postId];
    if (post == null) {
      throw const CommunityException('That post was removed.');
    }
    (_comments[postId] ??= []).add(PostComment(
      id: 'comment-${_nextId++}',
      author: author,
      message: message,
      createdAt: DateTime.now(),
    ));
    _posts[postId] = post.copyWith(commentCount: post.commentCount + 1);
    _changed();
  }

  /// A small circle for signed-out demo sessions: three friends with posts,
  /// two people waiting on a friend request, and a post of yours that a
  /// friend liked and replied to (so the notifications bell has activity).
  Future<void> seedDemoCircle(SocialProfile me) async {
    const ken = SocialProfile(
        uid: 'demo-ken', displayName: 'Ken', email: 'ken@shelby.app');
    const yco = SocialProfile(
        uid: 'demo-yco', displayName: 'Yco', email: 'yco@shelby.app');
    const nina = SocialProfile(
        uid: 'demo-nina', displayName: 'Nina', email: 'nina@shelby.app');
    const pending = [
      SocialProfile(
          uid: 'demo-matty', displayName: 'Matty', email: 'matty@shelby.app'),
      SocialProfile(
          uid: 'demo-kole', displayName: 'Kole', email: 'kole@shelby.app'),
    ];
    for (final profile in [ken, yco, nina, ...pending]) {
      registerUser(profile);
    }
    for (final friend in [ken, yco, nina]) {
      connectFriends(me, friend);
    }
    final now = DateTime.now();
    for (var i = 0; i < pending.length; i++) {
      final request = FriendRequest(
        from: pending[i],
        to: me,
        createdAt: now.subtract(Duration(hours: i + 1)),
      );
      _requests[request.id] = request;
    }
    final circle = [me.uid, ken.uid, yco.uid, nina.uid];
    await createPost(
      author: nina,
      message:
          'My best tip this week: move savings first, then plan the rest around what is left.',
      visibility: PostVisibility.friends,
      audience: circle,
      createdAt: now.subtract(const Duration(days: 1)),
      likedBy: [ken.uid, yco.uid],
      achievement: ShareableAchievement(
        kind: 'streak',
        title: 'Week Warrior',
        value: '7-day streak',
        detail: 'Opened Shelby every day this week',
        colorValue: _amber.toARGB32(),
        iconKey: 'fire',
      ),
    );
    await createPost(
      author: yco,
      message:
          'Finally reached my first emergency fund milestone. Next stop: a full 3-month cushion!',
      visibility: PostVisibility.friends,
      audience: circle,
      createdAt: now.subtract(const Duration(hours: 2)),
      likedBy: [nina.uid],
      achievement: ShareableAchievement(
        kind: 'badge',
        title: 'First Cushion',
        value: 'Badge unlocked',
        detail: 'Emergency fund covers 1 month of essentials',
        colorValue: _red.toARGB32(),
        iconKey: 'shield',
      ),
    );
    final kenPost = await createPost(
      author: ken,
      message:
          'Small steps really add up. Meal prepping kept me under my grocery budget for the first time!',
      visibility: PostVisibility.friends,
      audience: circle,
      createdAt: now.subtract(const Duration(minutes: 18)),
    );
    await addComment(
      postId: kenPost,
      author: nina,
      message: 'Love this! Any recipe recommendations?',
    );
    final myPost = await createPost(
      author: me,
      message: 'Started tracking every peso this month. Wish me luck!',
      visibility: PostVisibility.friends,
      audience: circle,
      createdAt: now.subtract(const Duration(hours: 5)),
      likedBy: [ken.uid],
    );
    const reply = 'You got this! The first week is the hardest.';
    await addComment(postId: myPost, author: yco, message: reply);
    await sendNotification(
      toUid: me.uid,
      notification: CommunityNotification(
        id: CommunityNotification.likeId(myPost, ken.uid),
        type: CommunityNotificationType.like,
        actor: ken,
        createdAt: now,
        postId: myPost,
        preview: 'Started tracking every peso this month. Wish me luck!',
      ),
    );
    await sendNotification(
      toUid: me.uid,
      notification: CommunityNotification(
        id: '',
        type: CommunityNotificationType.reply,
        actor: yco,
        createdAt: now,
        postId: myPost,
        preview: reply,
      ),
    );
  }
}
