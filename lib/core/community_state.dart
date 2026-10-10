part of '../main.dart';

enum FriendStatus { self, friend, requested, incoming, none }

/// Runtime state for the community feature: friends, requests and the feed.
///
/// Kept apart from `AppState` because it is live, server-owned data (streams
/// from other users), not the signed-in user's private profile. `AppState`
/// owns one instance as `state.community`; community widgets listen to it
/// directly with `ListenableBuilder`. It never touches the Health Score.
class CommunityController extends ChangeNotifier {
  CommunityBackend? _backend;
  SocialProfile? me;

  List<FriendRequest> incomingRequests = const [];
  List<FriendRequest> outgoingRequests = const [];
  List<SocialProfile> friends = const [];
  List<CommunityPost> posts = const [];
  List<CommunityNotification> notifications = const [];
  bool feedLoading = false;

  /// "Let friends find me": when false the user is removed from the email
  /// directory, so search can't surface them. Existing friends and pending
  /// requests are unaffected.
  bool discoverable = true;
  String? lastError;
  DateTime? _feedSeenAt;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  bool get isConnected => me != null && _backend != null;

  CommunityBackend get _requireBackend {
    final backend = _backend;
    if (backend == null || me == null) {
      throw const CommunityException('Community is still connecting.');
    }
    return backend;
  }

  /// Posts by other people that arrived since the feed was last opened.
  int get unseenPostCount {
    final self = me?.uid;
    final seen = _feedSeenAt;
    return posts
        .where((post) =>
            post.author.uid != self &&
            (seen == null || post.createdAt.isAfter(seen)))
        .length;
  }

  int get unreadNotificationCount =>
      notifications.where((item) => !item.read).length;

  void markFeedSeen({bool notify = true}) {
    _feedSeenAt = DateTime.now();
    if (notify) notifyListeners();
  }

  /// Starts (or restarts) the live session for [profile]. Safe to call on
  /// every app open: reconnecting the same user only refreshes the
  /// directory entry so name/photo changes propagate.
  Future<void> connect(
    SocialProfile profile,
    CommunityBackend backend, {
    bool discoverable = true,
  }) async {
    final sameSession = me?.uid == profile.uid && identical(_backend, backend);
    this.discoverable = discoverable;
    if (sameSession) {
      if (me != profile) {
        me = profile;
        notifyListeners();
      }
      await _syncDirectory();
      return;
    }
    await disconnect(notify: false);
    this.discoverable = discoverable;
    _backend = backend;
    me = profile;
    feedLoading = true;
    notifyListeners();
    await _syncDirectory();
    _subscriptions.addAll([
      backend.incomingRequests(profile.uid).listen((value) {
        incomingRequests = value;
        notifyListeners();
      }, onError: _onStreamError),
      backend.outgoingRequests(profile.uid).listen((value) {
        outgoingRequests = value;
        notifyListeners();
      }, onError: _onStreamError),
      backend.friends(profile.uid).listen((value) {
        friends = value;
        notifyListeners();
      }, onError: _onStreamError),
      backend.notifications(profile.uid).listen((value) {
        notifications = value;
        notifyListeners();
      }, onError: _onStreamError),
      backend.feed(profile.uid).listen((value) {
        posts = value;
        feedLoading = false;
        notifyListeners();
      }, onError: (Object error) {
        feedLoading = false;
        _onStreamError(error);
      }),
    ]);
  }

  Future<void> disconnect({bool notify = true}) async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _backend = null;
    me = null;
    incomingRequests = const [];
    outgoingRequests = const [];
    friends = const [];
    posts = const [];
    notifications = const [];
    feedLoading = false;
    lastError = null;
    _feedSeenAt = null;
    if (notify) notifyListeners();
  }

  void _onStreamError(Object error) {
    lastError = error is FirebaseException
        ? 'Community is offline right now (${error.code}).'
        : error.toString();
    debugPrint('Community stream error: $error');
    notifyListeners();
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _onStreamError(error);
    }
  }

  Future<void> _syncDirectory() async {
    final backend = _backend;
    final profile = me;
    if (backend == null || profile == null) return;
    await _guard(() => discoverable
        ? backend.upsertProfile(profile)
        : backend.removeFromDirectory(profile));
  }

  Future<void> setDiscoverable(bool value) async {
    discoverable = value;
    notifyListeners();
    await _syncDirectory();
  }

  /// Notifications are a courtesy: a failure (e.g. the two users are no
  /// longer friends) must never fail the like/reply/accept itself.
  Future<void> _notify(String toUid, CommunityNotification notification) async {
    final backend = _backend;
    if (backend == null || toUid == me?.uid) return;
    try {
      await backend.sendNotification(toUid: toUid, notification: notification);
    } catch (error) {
      debugPrint('Community notification skipped: $error');
    }
  }

  FriendStatus statusFor(String uid) {
    if (uid == me?.uid) return FriendStatus.self;
    if (friends.any((friend) => friend.uid == uid)) return FriendStatus.friend;
    if (outgoingRequests.any((request) => request.to.uid == uid)) {
      return FriendStatus.requested;
    }
    if (incomingRequests.any((request) => request.from.uid == uid)) {
      return FriendStatus.incoming;
    }
    return FriendStatus.none;
  }

  // ── Friends ────────────────────────────────────────────────────────────

  /// Exact-match lookup by the email attached to a Shelby account.
  /// Returns null when nobody has that email.
  Future<SocialProfile?> searchByEmail(String rawEmail) async {
    final backend = _requireBackend;
    final email = normalizeCommunityEmail(rawEmail);
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw const CommunityException('Enter the full email of a Shelby user.');
    }
    if (email == normalizeCommunityEmail(me!.email)) {
      throw const CommunityException('That’s your own email!');
    }
    return backend.findByEmail(email);
  }

  /// Sends a request; if [target] already asked us, accepts instead so two
  /// crossing requests become a friendship rather than a stalemate.
  Future<FriendStatus> sendFriendRequest(SocialProfile target) async {
    final backend = _requireBackend;
    switch (statusFor(target.uid)) {
      case FriendStatus.self:
        throw const CommunityException('You can’t add yourself.');
      case FriendStatus.friend:
        return FriendStatus.friend;
      case FriendStatus.requested:
        return FriendStatus.requested;
      case FriendStatus.incoming:
        await acceptFriendRequest(incomingRequests
            .firstWhere((request) => request.from.uid == target.uid));
        return FriendStatus.friend;
      case FriendStatus.none:
        await backend.sendFriendRequest(from: me!, to: target);
        return FriendStatus.requested;
    }
  }

  Future<void> acceptFriendRequest(FriendRequest request) async {
    final backend = _requireBackend;
    // Optimistic: drop the row immediately; the stream confirms.
    incomingRequests =
        incomingRequests.where((r) => r.id != request.id).toList();
    notifyListeners();
    // Snapshot our current name/photo into the friendship, not the one
    // captured when the request was sent.
    await backend.acceptFriendRequest(
        FriendRequest(from: request.from, to: me!, createdAt: request.createdAt));
    final crossing = outgoingRequests
        .where((r) => r.to.uid == request.from.uid)
        .toList();
    for (final stale in crossing) {
      await backend.deleteFriendRequest(stale);
    }
    await _notify(
      request.from.uid,
      CommunityNotification(
        id: '',
        type: CommunityNotificationType.friendAccepted,
        actor: me!,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Unfriends [friend]. Old "Friends" posts keep their original audience
  /// (fan-out on write), so only future posts stop reaching them.
  Future<void> removeFriend(SocialProfile friend) async {
    final backend = _requireBackend;
    final previous = friends;
    friends = friends.where((f) => f.uid != friend.uid).toList();
    notifyListeners();
    try {
      await backend.removeFriend(uid: me!.uid, friendUid: friend.uid);
    } catch (_) {
      friends = previous;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markNotificationsRead() async {
    final backend = _backend;
    final uid = me?.uid;
    final unread = [
      for (final item in notifications)
        if (!item.read) item.id,
    ];
    if (backend == null || uid == null || unread.isEmpty) return;
    notifications = [for (final item in notifications) item.copyWith(read: true)];
    notifyListeners();
    await _guard(() => backend.markNotificationsRead(uid: uid, ids: unread));
  }

  CommunityPost? postById(String? id) =>
      id == null ? null : posts.where((post) => post.id == id).firstOrNull;

  Future<void> declineFriendRequest(FriendRequest request) async {
    final backend = _requireBackend;
    incomingRequests =
        incomingRequests.where((r) => r.id != request.id).toList();
    notifyListeners();
    await backend.deleteFriendRequest(request);
  }

  // ── Posts ──────────────────────────────────────────────────────────────

  static String? validateMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return 'Write something to share.';
    if (trimmed.characters.length > communityPostMaxLength) {
      return 'Keep it under $communityPostMaxLength characters.';
    }
    return null;
  }

  /// Publishes a post. `Friends` posts are fanned out to the current friend
  /// list at write time; `Only Me` posts have an audience of one.
  Future<void> createPost({
    required String message,
    PostVisibility visibility = PostVisibility.friends,
    ShareableAchievement? achievement,
  }) async {
    final backend = _requireBackend;
    final error = validateMessage(message);
    if (error != null) throw CommunityException(error);
    final audience = <String>[
      me!.uid,
      if (visibility == PostVisibility.friends)
        for (final friend in friends) friend.uid,
    ];
    await backend.createPost(
      author: me!,
      message: message.trim(),
      visibility: visibility,
      audience: audience,
      achievement: achievement,
    );
  }

  Future<void> deletePost(CommunityPost post) async {
    final backend = _requireBackend;
    if (post.author.uid != me!.uid) {
      throw const CommunityException('You can only delete your own posts.');
    }
    posts = posts.where((p) => p.id != post.id).toList();
    notifyListeners();
    await backend.deletePost(post.id);
  }

  Future<void> toggleLike(CommunityPost post) async {
    final backend = _requireBackend;
    final uid = me!.uid;
    final liked = !post.isLikedBy(uid);
    posts = [
      for (final p in posts)
        if (p.id == post.id)
          p.copyWith(
            likedBy: liked
                ? [...p.likedBy, uid]
                : p.likedBy.where((id) => id != uid).toList(),
          )
        else
          p,
    ];
    notifyListeners();
    try {
      await backend.setLiked(postId: post.id, uid: uid, liked: liked);
      if (liked) {
        await _notify(
          post.author.uid,
          CommunityNotification(
            id: CommunityNotification.likeId(post.id, uid),
            type: CommunityNotificationType.like,
            actor: me!,
            createdAt: DateTime.now(),
            postId: post.id,
            preview: _preview(post.message),
          ),
        );
      }
    } catch (error) {
      // Roll back the optimistic toggle.
      posts = [
        for (final p in posts)
          if (p.id == post.id) post else p,
      ];
      notifyListeners();
      rethrow;
    }
  }

  Stream<List<PostComment>> commentsFor(String postId) =>
      _requireBackend.comments(postId);

  Future<void> addComment(CommunityPost post, String message) async {
    final backend = _requireBackend;
    final error = validateMessage(message);
    if (error != null) throw CommunityException(error);
    await backend.addComment(
      postId: post.id,
      author: me!,
      message: message.trim(),
    );
    await _notify(
      post.author.uid,
      CommunityNotification(
        id: '',
        type: CommunityNotificationType.reply,
        actor: me!,
        createdAt: DateTime.now(),
        postId: post.id,
        preview: _preview(message.trim()),
      ),
    );
  }

  static String _preview(String text) => text.characters.length <= 80
      ? text
      : '${text.characters.take(80)}…';
}
