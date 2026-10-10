import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _alex = SocialProfile(
    uid: 'alex', displayName: 'Alex Reyes', email: 'Alex.Reyes@email.com');
const _mika = SocialProfile(
    uid: 'mika', displayName: 'Mika Santos', email: 'mika@email.com');
const _paolo = SocialProfile(
    uid: 'paolo', displayName: 'Paolo Cruz', email: 'paolo@email.com');

/// Two controllers sharing one backend behave like two phones on one server.
Future<(InMemoryCommunityBackend, CommunityController, CommunityController)>
    _twoUsers() async {
  final backend = InMemoryCommunityBackend();
  final alex = CommunityController();
  final mika = CommunityController();
  await alex.connect(_alex, backend);
  await mika.connect(_mika, backend);
  await pumpEventQueue();
  return (backend, alex, mika);
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('friend workflow', () {
    test('search is exact, case-insensitive, and refuses your own email',
        () async {
      final (_, alex, mika) = await _twoUsers();

      final found = await mika.searchByEmail('  ALEX.reyes@EMAIL.com ');
      expect(found?.uid, 'alex');
      expect(await mika.searchByEmail('nobody@email.com'), isNull);
      expect(() => alex.searchByEmail('alex.reyes@email.com'),
          throwsA(isA<CommunityException>()));
      expect(() => alex.searchByEmail('not-an-email'),
          throwsA(isA<CommunityException>()));
    });

    test('request → accept creates a friendship on both sides', () async {
      final (_, alex, mika) = await _twoUsers();

      expect(await mika.sendFriendRequest(_alex), FriendStatus.requested);
      await pumpEventQueue();
      expect(alex.incomingRequests.single.from.uid, 'mika');
      expect(mika.statusFor('alex'), FriendStatus.requested);
      expect(alex.statusFor('mika'), FriendStatus.incoming);

      await alex.acceptFriendRequest(alex.incomingRequests.single);
      await pumpEventQueue();
      expect(alex.incomingRequests, isEmpty);
      expect(mika.outgoingRequests, isEmpty);
      expect(alex.friends.single.uid, 'mika');
      expect(mika.friends.single.uid, 'alex');
      expect(mika.statusFor('alex'), FriendStatus.friend);
    });

    test('decline removes the request without a friendship', () async {
      final (_, alex, mika) = await _twoUsers();
      await mika.sendFriendRequest(_alex);
      await pumpEventQueue();

      await alex.declineFriendRequest(alex.incomingRequests.single);
      await pumpEventQueue();
      expect(alex.incomingRequests, isEmpty);
      expect(alex.friends, isEmpty);
      expect(mika.statusFor('alex'), FriendStatus.none);
    });

    test('crossing requests resolve into a friendship', () async {
      final (_, alex, mika) = await _twoUsers();
      await mika.sendFriendRequest(_alex);
      await pumpEventQueue();

      expect(await alex.sendFriendRequest(_mika), FriendStatus.friend);
      await pumpEventQueue();
      expect(alex.friends.single.uid, 'mika');
      expect(alex.incomingRequests, isEmpty);
      expect(alex.outgoingRequests, isEmpty);
    });
  });

  group('posts', () {
    test('Friends posts reach friends; Only Me posts stay private', () async {
      final (backend, alex, mika) = await _twoUsers();
      final paolo = CommunityController();
      await paolo.connect(_paolo, backend);
      backend.connectFriends(_alex, _mika);
      await pumpEventQueue();

      await alex.createPost(message: 'Hit my savings target!');
      await alex.createPost(
        message: 'Note to self: skip takeout',
        visibility: PostVisibility.onlyMe,
      );
      await pumpEventQueue();

      expect(alex.posts.map((p) => p.message), [
        'Note to self: skip takeout',
        'Hit my savings target!',
      ]);
      expect(mika.posts.single.message, 'Hit my savings target!');
      expect(paolo.posts, isEmpty, reason: 'not a friend');
    });

    test('messages are trimmed and capped at 250 characters', () async {
      final (_, alex, _) = await _twoUsers();
      expect(() => alex.createPost(message: '   '),
          throwsA(isA<CommunityException>()));
      expect(() => alex.createPost(message: 'x' * 251),
          throwsA(isA<CommunityException>()));
      await alex.createPost(message: '  ${'y' * 250}  ');
      await pumpEventQueue();
      expect(alex.posts.single.message.length, 250);
    });

    test('achievements travel with the post', () async {
      final (backend, alex, mika) = await _twoUsers();
      backend.connectFriends(_alex, _mika);
      await pumpEventQueue();

      await alex.createPost(
        message: 'One week!',
        achievement: streakShareable(7),
      );
      await pumpEventQueue();
      final shared = mika.posts.single.achievement!;
      expect(shared.value, '7-day streak');
      expect(shared.icon, Icons.local_fire_department_rounded);
    });

    test('likes toggle per user and replies bump the count', () async {
      final (backend, alex, mika) = await _twoUsers();
      backend.connectFriends(_alex, _mika);
      await pumpEventQueue();
      await alex.createPost(message: 'First paycheck saved');
      await pumpEventQueue();

      await mika.toggleLike(mika.posts.single);
      await pumpEventQueue();
      expect(alex.posts.single.likeCount, 1);
      expect(alex.posts.single.isLikedBy('mika'), isTrue);

      await mika.toggleLike(mika.posts.single);
      await pumpEventQueue();
      expect(alex.posts.single.likeCount, 0);

      await mika.addComment(mika.posts.single, 'So proud of you!');
      await pumpEventQueue();
      expect(alex.posts.single.commentCount, 1);
      final replies = await alex.commentsFor(alex.posts.single.id).first;
      expect(replies.single.author.uid, 'mika');
    });

    test('only the author can delete a post', () async {
      final (backend, alex, mika) = await _twoUsers();
      backend.connectFriends(_alex, _mika);
      await pumpEventQueue();
      await alex.createPost(message: 'Bye soon');
      await pumpEventQueue();

      expect(() => mika.deletePost(mika.posts.single),
          throwsA(isA<CommunityException>()));
      await alex.deletePost(alex.posts.single);
      await pumpEventQueue();
      expect(mika.posts, isEmpty);
    });

    test('unseen count tracks friends’ posts since the feed was opened',
        () async {
      final (backend, alex, mika) = await _twoUsers();
      backend.connectFriends(_alex, _mika);
      await pumpEventQueue();
      await mika.createPost(message: 'Hello circle');
      await alex.createPost(message: 'My own post');
      await pumpEventQueue();

      expect(alex.unseenPostCount, 1);
      alex.markFeedSeen();
      expect(alex.unseenPostCount, 0);
    });
  });

  group('unfriend, notifications, privacy', () {
    test('unfriending removes the friendship for both people', () async {
      final (backend, alex, mika) = await _twoUsers();
      backend.connectFriends(_alex, _mika);
      await pumpEventQueue();
      expect(alex.friends.single.uid, 'mika');

      await alex.removeFriend(_mika);
      await pumpEventQueue();
      expect(alex.friends, isEmpty);
      expect(mika.friends, isEmpty);
      expect(alex.statusFor('mika'), FriendStatus.none);

      await alex.createPost(message: 'After the break');
      await pumpEventQueue();
      expect(mika.posts, isEmpty, reason: 'new posts skip ex-friends');
    });

    test('likes, replies and accepts notify the other person', () async {
      final (backend, alex, mika) = await _twoUsers();
      backend.connectFriends(_alex, _mika);
      await pumpEventQueue();
      await alex.createPost(message: 'Saved my first ₱1,000 buffer');
      await pumpEventQueue();

      await mika.toggleLike(mika.posts.single);
      await mika.toggleLike(mika.posts.single); // unlike
      await mika.toggleLike(mika.posts.single); // like again: no duplicate
      await mika.addComment(mika.posts.single, 'Amazing!');
      await pumpEventQueue();

      expect(alex.notifications.map((n) => n.type).toSet(), {
        CommunityNotificationType.like,
        CommunityNotificationType.reply,
      });
      expect(alex.notifications, hasLength(2));
      expect(alex.unreadNotificationCount, 2);
      expect(mika.notifications, isEmpty, reason: 'no self-notifications');

      await alex.markNotificationsRead();
      await pumpEventQueue();
      expect(alex.unreadNotificationCount, 0);

      final paolo = CommunityController();
      await paolo.connect(_paolo, backend);
      await paolo.sendFriendRequest(_alex);
      await pumpEventQueue();
      await alex.acceptFriendRequest(alex.incomingRequests.single);
      await pumpEventQueue();
      expect(paolo.notifications.single.type,
          CommunityNotificationType.friendAccepted);
      expect(paolo.notifications.single.actor.uid, 'alex');
    });

    test('"Let friends find me" off hides you from email search', () async {
      final (_, alex, mika) = await _twoUsers();
      expect(await mika.searchByEmail(_alex.email), isNotNull);

      await alex.setDiscoverable(false);
      expect(await mika.searchByEmail(_alex.email), isNull);

      await alex.setDiscoverable(true);
      expect(await mika.searchByEmail(_alex.email), isNotNull);
    });

    test('discoverability persists through the AppState profile', () async {
      final state = AppState();
      final backend = InMemoryCommunityBackend();
      state.communityBackendForTesting = backend;
      await state.connectCommunity();
      await state.setDiscoverableByEmail(false);
      expect(state.discoverableByEmail, isFalse);
      expect(state.community.discoverable, isFalse);
      expect(await backend.findByEmail(state.socialProfile.email), isNull);
    });
  });

  group('badges', () {
    test('streak badges come from the longest streak and stay earned', () {
      final state = AppState()..longestLoginStreak = 7;
      final badges = {for (final b in computeBadges(state)) b.id: b};
      expect(badges['streak_3']!.earned, isTrue);
      expect(badges['streak_7']!.earned, isTrue);
      expect(badges['streak_14']!.earned, isFalse);
      expect(badges['streak_14']!.progressLabel, '7 of 14 days');

      state.seenBadgeIds.add('streak_14');
      expect(
        computeBadges(state).firstWhere((b) => b.id == 'streak_14').earned,
        isTrue,
      );
    });

    test('first check sets a silent baseline, later unlocks are celebrated',
        () {
      final state = AppState()..longestLoginStreak = 3;
      expect(state.collectNewlyEarnedBadges(), isEmpty);
      expect(state.seenBadgeIds, contains('streak_3'));

      state.longestLoginStreak = 7;
      expect(state.collectNewlyEarnedBadges().map((b) => b.id), ['streak_7']);
      expect(state.collectNewlyEarnedBadges(), isEmpty);
    });

    test('badges never change the health score', () {
      final state = AppState()..seedReflectionDemoDataForTesting();
      final before = state.healthScore;
      state.collectNewlyEarnedBadges();
      state.seenBadgeIds.addAll(computeBadges(state).map((b) => b.id));
      expect(state.healthScore, before);
    });
  });

  group('UI', () {
    Future<AppState> pumpWith(
      WidgetTester tester,
      Widget home, {
      InMemoryCommunityBackend? custom,
    }) async {
      final state = AppState()
        ..name = 'Alex Reyes'
        ..email = 'alex.reyes@email.com';
      final backend = custom ?? InMemoryCommunityBackend();
      if (custom == null) await backend.seedDemoCircle(state.socialProfile);
      state.communityBackendForTesting = backend;
      await tester.pumpWidget(AppScope(
        state: state,
        child: MaterialApp(home: home),
      ));
      return state;
    }

    testWidgets('header order is Notifications · Community · Profile',
        (tester) async {
      await pumpWith(
        tester,
        const Scaffold(body: PageHeader(eyebrow: 'HOME', title: 'Hi')),
      );
      final schedule = tester.getCenter(find.byIcon(Icons.schedule_rounded));
      final community = tester.getCenter(find.byIcon(Icons.forum_rounded));
      final profile = tester.getCenter(find.byIcon(Icons.person_rounded));
      expect(schedule.dx, lessThan(community.dx));
      expect(community.dx, lessThan(profile.dx));
    });

    testWidgets('demo circle uses Ken, Yco, Nina, Matty and Kole',
        (tester) async {
      final state = await pumpWith(
        tester,
        const Scaffold(body: SizedBox()),
      );
      await state.connectCommunity();
      await tester.pump();
      expect(state.community.friends.map((f) => f.displayName).toSet(),
          {'Ken', 'Yco', 'Nina'});
      expect(state.community.incomingRequests.map((r) => r.from.displayName),
          containsAll(['Matty', 'Kole']));
      expect(state.community.unreadNotificationCount, 2);
    });

    testWidgets('friend requests show 3 rows, expand, and accept',
        (tester) async {
      const me = SocialProfile(
          uid: 'local-you',
          displayName: 'Alex Reyes',
          email: 'alex.reyes@email.com');
      final backend = InMemoryCommunityBackend();
      for (final name in ['Ana', 'Ben', 'Cy', 'Dee']) {
        await backend.sendFriendRequest(
          from: SocialProfile(uid: name, displayName: name, email: '$name@x.com'),
          to: me,
        );
      }
      final state = await pumpWith(
        tester,
        const Scaffold(body: SingleChildScrollView(child: FriendRequestsCard())),
        custom: backend,
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip(RegExp('^Accept ')), findsNWidgets(3));
      expect(find.text('Show 1 more'), findsOneWidget);

      await tester.tap(find.text('Show 1 more'));
      await tester.pumpAndSettle();
      expect(find.byTooltip(RegExp('^Accept ')), findsNWidgets(4));

      await tester.tap(find.byTooltip('Accept Ana'));
      await tester.pumpAndSettle();
      expect(state.community.incomingRequests, hasLength(3));
      expect(state.community.statusFor('Ana'), FriendStatus.friend);
    });

    testWidgets('My friends tab swipes in and unfriends with confirmation',
        (tester) async {
      final state = await pumpWith(
        tester,
        const Scaffold(body: SingleChildScrollView(child: FriendRequestsCard())),
      );
      await tester.pumpAndSettle();

      await tester.fling(
          find.text('Money Circle'), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Unfriend Ken'), findsOneWidget);
      expect(find.text('See all 3 friends'), findsOneWidget);

      await tester.tap(find.byTooltip('Unfriend Ken'));
      await tester.pumpAndSettle();
      expect(find.text('Remove Ken?'), findsOneWidget);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(state.community.statusFor('demo-ken'), FriendStatus.none);
      expect(find.text('See all 2 friends'), findsOneWidget);
    });

    testWidgets('community header opens friends and notifications',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final state = await pumpWith(tester, const CommunityPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('All my friends'));
      await tester.pumpAndSettle();
      expect(find.text('3 friends in your circle'), findsOneWidget);
      expect(find.byTooltip('Unfriend Nina'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(state.community.unreadNotificationCount, 2);
      await tester.tap(find.byTooltip('Community notifications'));
      await tester.pumpAndSettle();
      expect(find.text('2 new from your circle'), findsOneWidget);
      expect(find.textContaining('Yco replied to your post', findRichText: true),
          findsOneWidget);
      expect(find.textContaining('Ken liked your post', findRichText: true),
          findsOneWidget);
      expect(state.community.unreadNotificationCount, 0);
    });

    testWidgets('Find friends searches by email and sends a request',
        (tester) async {
      final state = await pumpWith(
        tester,
        const Scaffold(body: SingleChildScrollView(child: FriendRequestsCard())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find friends'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'kole@shelby.app');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Kole already asked us, so "Add" becomes "Accept".
      expect(find.text('kole@shelby.app'), findsWidgets);
      await tester.tap(find.widgetWithText(FilledButton, 'Accept'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Friends'), findsOneWidget);
      expect(state.community.statusFor('demo-kole'), FriendStatus.friend);
    });

    testWidgets('Share it! posts an achievement into the community feed',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final state = await pumpWith(
        tester,
        Scaffold(body: Center(child: ShareItChip(achievement: streakShareable(9)))),
      );
      await tester.tap(find.text('Share it!'));
      await tester.pumpAndSettle();

      expect(find.text('Alex Reyes'), findsOneWidget);
      expect(find.text('alex.reyes@email.com'), findsOneWidget);
      expect(find.text('9-day streak'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Nine days strong!');
      await tester.tap(find.text('Post to Friends'));
      await tester.pumpAndSettle();

      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Nine days strong!'), findsOneWidget);
      final mine = state.community.posts
          .firstWhere((post) => post.author.uid == state.socialProfile.uid);
      expect(mine.achievement?.value, '9-day streak');
      expect(mine.visibility, PostVisibility.friends);
    });

    testWidgets('composer can post as Only Me', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final state = await pumpWith(tester, const CommunityPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Private reflection');
      await tester.tap(find.byTooltip('Who sees your post?'));
      await tester.pumpAndSettle();
      expect(find.text('Who sees your post?'), findsWidgets);
      await tester.tap(find.text('Only Me').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      final mine = state.community.posts
          .firstWhere((post) => post.message == 'Private reflection');
      expect(mine.visibility, PostVisibility.onlyMe);
    });
  });
}
