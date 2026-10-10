part of '../../main.dart';

// ─── Cooperative personal informatics: UI ───────────────────────────────────
//
// Entry points:
//   • "Share it!" chips on header cards, the profile scorecard, the streak
//     tile, milestones and badges → showShareAchievementSheet().
//   • Community icon in PageHeader (Notifications · Community · Profile)
//     → CommunityPage (thread-style feed with composer on top).
//   • Profile → FriendRequestsCard (max 3 rows, expandable, Find friends).

const _shareYellow = Color(0xFFFFD84D);
const _shareYellowInk = Color(0xFF5C3B00);

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[time.month - 1]} ${time.day}';
}

Future<CommunityController> _ensureCommunity(BuildContext context) async {
  final state = AppScope.of(context);
  if (!state.community.isConnected) await state.connectCommunity();
  return state.community;
}

// ── Share it! ──────────────────────────────────────────────────────────────

/// The small yellow "Share it!" pill that sits in the corner of a card.
class ShareItChip extends StatelessWidget {
  const ShareItChip({super.key, required this.achievement, this.compact = false});

  final ShareableAchievement achievement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Share ${achievement.title} with friends',
      child: Material(
        color: _shareYellow,
        shape: const StadiumBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => showShareAchievementSheet(context, achievement),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 4 : 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.ios_share_rounded,
                    size: compact ? 12 : 13, color: _shareYellowInk),
                const SizedBox(width: 4),
                Text(
                  'Share it!',
                  style: GoogleFonts.nunito(
                    fontSize: compact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w900,
                    color: _shareYellowInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A round yellow share icon pinned to the corner of a small tile.
class _CornerShareDot extends StatelessWidget {
  const _CornerShareDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: _shareYellow,
        shape: BoxShape.circle,
        border: Border.all(color: _surface, width: 2),
        boxShadow: [
          BoxShadow(
            color: _shareYellow.withValues(alpha: .5),
            blurRadius: 6,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.ios_share_rounded,
          size: 11, color: _shareYellowInk),
    );
  }
}

Future<void> showShareAchievementSheet(
  BuildContext context,
  ShareableAchievement achievement,
) async {
  final community = await _ensureCommunity(context);
  if (!context.mounted) return;
  final posted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ShareAchievementSheet(
      community: community,
      achievement: achievement,
    ),
  );
  if (posted == true && context.mounted) {
    _push(context, const CommunityPage());
  }
}

class _ShareAchievementSheet extends StatefulWidget {
  const _ShareAchievementSheet({
    required this.community,
    required this.achievement,
  });

  final CommunityController community;
  final ShareableAchievement achievement;

  @override
  State<_ShareAchievementSheet> createState() => _ShareAchievementSheetState();
}

class _ShareAchievementSheetState extends State<_ShareAchievementSheet> {
  final _controller = TextEditingController();
  var _visibility = PostVisibility.friends;
  var _posting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    setState(() {
      _posting = true;
      _error = null;
    });
    final typed = _controller.text.trim();
    try {
      await widget.community.createPost(
        message: typed.isEmpty
            ? 'Proud of this little win — one step closer to my goal!'
            : typed,
        visibility: _visibility,
        achievement: widget.achievement,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _posting = false;
        _error = error is CommunityException
            ? error.message
            : 'Couldn’t post right now. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.community.me!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CommunityAvatar(profile: me, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            me.displayName,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: _title,
                            ),
                          ),
                          Text(
                            me.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _body,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context, false),
                      style: IconButton.styleFrom(
                        backgroundColor: _brand.withValues(alpha: .12),
                        foregroundColor: _sage,
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AchievementCard(achievement: widget.achievement, hero: true),
                const SizedBox(height: 14),
                _MessageField(
                  controller: _controller,
                  hint: 'How does this win feel? Share advice or cheer yourself on…',
                  minLines: 3,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _VisibilityButton(
                      value: _visibility,
                      onChanged: (value) => setState(() => _visibility = value),
                    ),
                    const Spacer(),
                    _CharacterCount(length: _controller.text.characters.length),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: _red,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _GradientButton(
                  label: _visibility == PostVisibility.friends
                      ? 'Post to Friends'
                      : 'Save to Only Me',
                  icon: Icons.send_rounded,
                  busy: _posting,
                  onPressed: _posting ? null : _post,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Only the card above is shared — never balances or account details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared community building blocks ──────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: _border,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({super.key, required this.profile, this.size = 40});

  final SocialProfile profile;
  final double size;

  static const _gradients = [
    [Color(0xFF7FD4A8), _purple],
    [Color(0xFFFFB86B), Color(0xFFE0483D)],
    [Color(0xFF6AA8F0), _purple],
    [Color(0xFF57BE8C), Color(0xFF2F8A5E)],
    [_belly, _purple],
  ];

  @override
  Widget build(BuildContext context) {
    final colors =
        _gradients[profile.uid.hashCode.abs() % _gradients.length];
    final photo = profile.photoUrl ?? '';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: photo.isEmpty
          ? Text(
              profile.initials,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: size * .32,
                fontWeight: FontWeight.w900,
              ),
            )
          : Image.network(
              photo,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Text(
                profile.initials,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: size * .32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    );
  }
}

/// The badge/streak/stat card attached to a post. `hero` is the bold
/// gradient version used in the share sheet; otherwise a soft tint for feeds.
class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.achievement,
    this.hero = false,
  });

  final ShareableAchievement achievement;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final color = achievement.color;
    final deep = Color.lerp(color, _purple, .55)!;
    return Container(
      padding: EdgeInsets.all(hero ? 16 : 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(hero ? 22 : 18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hero
              ? [color, deep]
              : [color.withValues(alpha: .10), color.withValues(alpha: .20)],
        ),
        border: hero
            ? null
            : Border.all(color: color.withValues(alpha: .25)),
        boxShadow: hero
            ? [
                BoxShadow(
                  color: color.withValues(alpha: .30),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: hero ? 48 : 40,
            height: hero ? 48 : 40,
            decoration: BoxDecoration(
              color: hero ? Colors.white.withValues(alpha: .20) : color,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(achievement.icon,
                color: Colors.white, size: hero ? 24 : 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title.toUpperCase(),
                  style: TextStyle(
                    color: hero
                        ? Colors.white.withValues(alpha: .78)
                        : Color.lerp(color, Colors.black, .2),
                    fontSize: 10,
                    letterSpacing: .9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.value,
                  style: GoogleFonts.nunito(
                    color: hero ? Colors.white : _title,
                    fontSize: hero ? 19 : 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (achievement.detail.isNotEmpty)
                  Text(
                    achievement.detail,
                    style: TextStyle(
                      color: hero ? Colors.white.withValues(alpha: .80) : _body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageField extends StatelessWidget {
  const _MessageField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.minLines = 2,
    this.bordered = true,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final int minLines;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: 6,
      maxLength: communityPostMaxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        color: _title,
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _body.withValues(alpha: .7),
          fontWeight: FontWeight.w600,
        ),
        counterText: '',
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
    if (!bordered) return field;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: field,
    );
  }
}

class _CharacterCount extends StatelessWidget {
  const _CharacterCount({required this.length});
  final int length;

  @override
  Widget build(BuildContext context) {
    final near = length > communityPostMaxLength - 25;
    return Text(
      '$length/$communityPostMaxLength',
      style: TextStyle(
        color: near ? _amber : _body.withValues(alpha: .7),
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

/// Eye button that opens the small "Who sees your post?" chooser.
class _VisibilityButton extends StatelessWidget {
  const _VisibilityButton({required this.value, required this.onChanged});

  final PostVisibility value;
  final ValueChanged<PostVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final private = value == PostVisibility.onlyMe;
    final tint = private ? _purple : _sage;
    return PopupMenuButton<PostVisibility>(
      tooltip: 'Who sees your post?',
      initialValue: value,
      onSelected: onChanged,
      offset: const Offset(0, 40),
      color: _surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 260),
      itemBuilder: (context) => [
        const PopupMenuItem<PostVisibility>(
          enabled: false,
          height: 52,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Who sees your post?',
                style: TextStyle(
                  color: _title,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'You can change this before posting.',
                style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        for (final option in PostVisibility.values)
          PopupMenuItem<PostVisibility>(
            value: option,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: option == value ? _sage : _bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    option.icon,
                    size: 15,
                    color: option == value ? Colors.white : _body,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: const TextStyle(
                          color: _title,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        option.detail,
                        style: const TextStyle(
                          color: _body,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (option == value)
                  const Icon(Icons.check_rounded, size: 16, color: _sage),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(value.icon, size: 14, color: tint),
            const SizedBox(width: 5),
            Text(
              value.label,
              style: GoogleFonts.nunito(
                color: tint,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            Icon(Icons.expand_more_rounded, size: 16, color: tint),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.busy = false,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool busy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled || busy ? 1 : .45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(compact ? 13 : 18),
          gradient: const LinearGradient(colors: [_brand, _purple]),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(compact ? 13 : 18),
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 18,
                vertical: compact ? 8 : 14,
              ),
              child: Row(
                mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(icon, size: compact ? 13 : 16, color: Colors.white),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: compact ? 12 : 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header icon ───────────────────────────────────────────────────────────

class _CommunityIconButton extends StatelessWidget {
  const _CommunityIconButton();

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    final community = scope?.notifier?.community;
    final button = IconButton(
      onPressed: () => _push(context, const CommunityPage()),
      style: IconButton.styleFrom(
        backgroundColor: _bellySoft,
        foregroundColor: _purple,
      ),
      icon: const Icon(Icons.forum_rounded),
    );
    return Tooltip(
      message: 'Community',
      child: community == null
          ? button
          : ListenableBuilder(
              listenable: community,
              builder: (context, child) => Stack(
                clipBehavior: Clip.none,
                children: [
                  child!,
                  if (community.unseenPostCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _brand,
                          shape: BoxShape.circle,
                          border: Border.all(color: _bg, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              child: button,
            ),
    );
  }
}

/// Small count bubble for pending friend requests on the Profile icon.
class _FriendRequestBadge extends StatelessWidget {
  const _FriendRequestBadge({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    final community = scope?.notifier?.community;
    if (community == null) return child;
    return ListenableBuilder(
      listenable: community,
      builder: (context, child) {
        final count = community.incomingRequests.length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 17, minHeight: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _bg, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: child,
    );
  }
}

// ── Community page ────────────────────────────────────────────────────────

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  CommunityController? _community;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final community = await _ensureCommunity(context);
      if (!mounted) return;
      setState(() => _community = community);
      community.markFeedSeen();
    });
  }

  @override
  void deactivate() {
    // Called mid-build while the route pops, so record without notifying.
    _community?.markFeedSeen(notify: false);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final community = _community ?? AppScope.of(context).community;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: community,
          builder: (context, _) => _buildFeed(context, community),
        ),
      ),
    );
  }

  Widget _buildFeed(BuildContext context, CommunityController community) {
    final connected = community.isConnected;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final friendPostsThisWeek = community.posts
        .where((post) =>
            post.author.uid != community.me?.uid &&
            post.createdAt.isAfter(weekAgo))
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.maybePop(context),
              style: IconButton.styleFrom(backgroundColor: _surface),
              icon: const Icon(Icons.arrow_back_rounded, color: _title),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community',
                    style: GoogleFonts.fredoka(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: _title,
                    ),
                  ),
                  const Text(
                    'Wins, wisdom & encouragement from friends',
                    style: TextStyle(
                      color: _body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _FriendStack(
              friends: community.friends,
              onTap: () => _push(context, const FriendsPage()),
            ),
            const SizedBox(width: 6),
            _NotificationBell(
              unread: community.unreadNotificationCount,
              onTap: () => _push(context, const CommunityNotificationsPage()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CommunityBanner(
          friendCount: community.friends.length,
          postsThisWeek: friendPostsThisWeek,
          onFindFriends: () => _showFindFriendsSheet(context),
        ),
        const SizedBox(height: 14),
        if (connected) _PostComposer(community: community),
        if (community.lastError != null) ...[
          const SizedBox(height: 12),
          _CommunityErrorBanner(message: community.lastError!),
        ],
        const SizedBox(height: 18),
        if (!connected || community.feedLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: _brand)),
          )
        else if (community.posts.isEmpty)
          _EmptyFeed(onFindFriends: () => _showFindFriendsSheet(context))
        else
          for (final post in community.posts) ...[
            _PostCard(post: post, community: community),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _FriendStack extends StatelessWidget {
  const _FriendStack({required this.friends, required this.onTap});
  final List<SocialProfile> friends;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shown = friends.take(3).toList();
    return Tooltip(
      message: 'All my friends',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: shown.isEmpty
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.group_outlined, color: _purple),
                )
              : SizedBox(
                  width: 32.0 + (shown.length - 1) * 18,
                  height: 32,
                  child: Stack(
                    children: [
                      for (var i = 0; i < shown.length; i++)
                        Positioned(
                          left: i * 18.0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _bg, width: 2),
                            ),
                            child: ClipOval(
                              child: CommunityAvatar(
                                  profile: shown[i], size: 28),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unread, required this.onTap});
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Community notifications',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: onTap,
            style: IconButton.styleFrom(
              backgroundColor: _bellySoft,
              foregroundColor: _purple,
            ),
            icon: Icon(unread > 0
                ? Icons.notifications_active_rounded
                : Icons.notifications_none_rounded),
          ),
          if (unread > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _red,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _bg, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommunityBanner extends StatelessWidget {
  const _CommunityBanner({
    required this.friendCount,
    required this.postsThisWeek,
    required this.onFindFriends,
  });

  final int friendCount;
  final int postsThisWeek;
  final VoidCallback onFindFriends;

  @override
  Widget build(BuildContext context) {
    return ShelbyHeroHeader(
      color: const Color(0xFF4A2F73),
      icon: Icons.diversity_3_rounded,
      title: friendCount == 0
          ? 'Build your money circle'
          : 'You’re in good company',
      subtitle: friendCount == 0
          ? 'Add friends by email to cheer each other on.'
          : '$friendCount friend${friendCount == 1 ? '' : 's'} · $postsThisWeek post${postsThisWeek == 1 ? '' : 's'} this week',
      trailing: TextButton.icon(
        onPressed: onFindFriends,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: .14),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 15),
        label: const Text(
          'Add',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _CommunityErrorBanner extends StatelessWidget {
  const _CommunityErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: _amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _title,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.onFindFriends});
  final VoidCallback onFindFriends;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Image.asset('assets/images/share_shelby.png',
                fit: BoxFit.contain),
          ),
          const SizedBox(height: 12),
          Text(
            'Your feed is quiet… for now',
            style: GoogleFonts.fredoka(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share a small win above, or add friends to see theirs.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _body,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onFindFriends,
            icon: const Icon(Icons.person_search_rounded, size: 18),
            label: const Text('Find friends'),
          ),
        ],
      ),
    );
  }
}

class _PostComposer extends StatefulWidget {
  const _PostComposer({required this.community});
  final CommunityController community;

  @override
  State<_PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<_PostComposer> {
  final _controller = TextEditingController();
  var _visibility = PostVisibility.friends;
  var _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _posting = true);
    try {
      await widget.community.createPost(
        message: _controller.text,
        visibility: _visibility,
      );
      _controller.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (error) {
      if (!mounted) return;
      showAppNotice(
        context,
        message: error is CommunityException
            ? error.message
            : 'Couldn’t post right now. Please try again.',
        icon: Icons.warning_amber_rounded,
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.community.me!;
    final canPost = _controller.text.trim().isNotEmpty && !_posting;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommunityAvatar(profile: me, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      me.displayName,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _title,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _MessageField(
                      controller: _controller,
                      bordered: false,
                      hint:
                          'Share a small win, ask for advice, or start a money conversation…',
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 8),
          Row(
            children: [
              _VisibilityButton(
                value: _visibility,
                onChanged: (value) => setState(() => _visibility = value),
              ),
              const Spacer(),
              _CharacterCount(length: _controller.text.characters.length),
              const SizedBox(width: 10),
              _GradientButton(
                label: 'Post',
                icon: Icons.send_rounded,
                compact: true,
                busy: _posting,
                onPressed: canPost ? _submit : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.community});

  final CommunityPost post;
  final CommunityController community;

  @override
  Widget build(BuildContext context) {
    final mine = post.author.uid == community.me?.uid;
    final liked = post.isLikedBy(community.me?.uid ?? '');
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommunityAvatar(profile: post.author, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mine ? '${post.author.displayName} (you)' : post.author.displayName,
                      style: GoogleFonts.nunito(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: _title,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_timeAgo(post.createdAt)} · ',
                          style: const TextStyle(
                            color: _body,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(post.visibility.icon, size: 11, color: _body),
                        const SizedBox(width: 3),
                        Text(
                          post.visibility.label,
                          style: const TextStyle(
                            color: _body,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (mine)
                PopupMenuButton<String>(
                  tooltip: 'Post options',
                  icon: const Icon(Icons.more_horiz_rounded, color: _body),
                  color: _surface,
                  surfaceTintColor: Colors.transparent,
                  onSelected: (_) async {
                    try {
                      await community.deletePost(post);
                    } catch (_) {
                      if (context.mounted) {
                        showAppNotice(context,
                            message: 'Couldn’t delete that post.',
                            icon: Icons.warning_amber_rounded);
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: _red),
                          SizedBox(width: 8),
                          Text('Delete post'),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(width: 8),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 8, 10),
            child: Text(
              post.message,
              style: const TextStyle(
                color: _title,
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (post.achievement != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 6),
              child: AchievementCard(achievement: post.achievement!),
            ),
          Row(
            children: [
              _PostAction(
                icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: liked ? const Color(0xFFE05C7A) : _body,
                label: '${post.likeCount}',
                semantics: liked ? 'Unlike' : 'Like',
                onTap: () async {
                  try {
                    await community.toggleLike(post);
                  } catch (_) {
                    if (context.mounted) {
                      showAppNotice(context,
                          message: 'Couldn’t update that like.',
                          icon: Icons.warning_amber_rounded);
                    }
                  }
                },
              ),
              if (post.visibility == PostVisibility.friends)
                _PostAction(
                  icon: Icons.mode_comment_outlined,
                  color: _body,
                  label: '${post.commentCount}',
                  semantics: 'Replies',
                  onTap: () => _openReplies(context, post, community),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.semantics,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.post, required this.community});

  final CommunityPost post;
  final CommunityController community;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  late final Stream<List<PostComment>> _comments =
      widget.community.commentsFor(widget.post.id);
  var _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      await widget.community.addComment(widget.post, _controller.text);
      _controller.clear();
    } catch (error) {
      if (!mounted) return;
      showAppNotice(
        context,
        message: error is CommunityException
            ? error.message
            : 'Couldn’t send that reply.',
        icon: Icons.warning_amber_rounded,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * .72;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 12),
              Text(
                'Replies',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _title,
                ),
              ),
              Text(
                'to ${widget.post.author.displayName}',
                style: const TextStyle(
                  color: _body,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<PostComment>>(
                  stream: _comments,
                  builder: (context, snapshot) {
                    final comments = snapshot.data ?? const <PostComment>[];
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: _brand),
                      );
                    }
                    if (comments.isEmpty) {
                      return const Center(
                        child: Text(
                          'No replies yet. Say something kind!',
                          style: TextStyle(
                            color: _body,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommunityAvatar(profile: comment.author, size: 32),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${comment.author.displayName} · ${_timeAgo(comment.createdAt)}',
                                      style: const TextStyle(
                                        color: _body,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      comment.message,
                                      style: const TextStyle(
                                        color: _title,
                                        fontSize: 13,
                                        height: 1.4,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _MessageField(
                      controller: _controller,
                      minLines: 1,
                      hint: 'Write a reply…',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send reply',
                    onPressed: _controller.text.trim().isEmpty || _sending
                        ? null
                        : _send,
                    style: IconButton.styleFrom(backgroundColor: _brand),
                    icon: const Icon(Icons.send_rounded, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Friend requests & Find friends (Profile) ──────────────────────────────

Future<void> _showFindFriendsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 14),
              Text(
                'Find friends',
                style: GoogleFonts.fredoka(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: _title,
                ),
              ),
              const SizedBox(height: 10),
              const _FindFriendsPanel(autofocus: true),
            ],
          ),
        ),
      ),
    ),
  );
}

enum _CircleTab { requests, friends }

class FriendRequestsCard extends StatefulWidget {
  const FriendRequestsCard({super.key});

  static const previewCount = 3;

  @override
  State<FriendRequestsCard> createState() => _FriendRequestsCardState();
}

class _FriendRequestsCardState extends State<FriendRequestsCard> {
  var _tab = _CircleTab.requests;
  var _expanded = false;
  var _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensureCommunity(context);
    });
  }

  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 250) return;
    setState(() => _tab =
        velocity < 0 ? _CircleTab.friends : _CircleTab.requests);
  }

  @override
  Widget build(BuildContext context) {
    final community = AppScope.of(context).community;
    return ListenableBuilder(
      listenable: community,
      builder: (context, _) {
        final requests = community.incomingRequests;
        final friends = community.friends;
        return AppCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: _onSwipe,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Money Circle',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _title,
                  ),
                ),
                const Text(
                  'Swipe or tap to switch between requests and friends',
                  style: TextStyle(
                    color: _body,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _CircleTabs(
                  tab: _tab,
                  requestCount: requests.length,
                  friendCount: friends.length,
                  onChanged: (tab) => setState(() => _tab = tab),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  ),
                  child: _tab == _CircleTab.requests
                      ? _buildRequests(community, requests)
                      : _buildFriends(context, community, friends),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _searching = !_searching),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _sage,
                    side: const BorderSide(color: _border),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    _searching
                        ? Icons.close_rounded
                        : Icons.person_add_alt_1_rounded,
                    size: 17,
                  ),
                  label: Text(
                    _searching ? 'Close search' : 'Find friends',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _searching
                      ? const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: _FindFriendsPanel(autofocus: true),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequests(
    CommunityController community,
    List<FriendRequest> requests,
  ) {
    if (requests.isEmpty) {
      return const _CircleEmptyRow(
        key: ValueKey('requests-empty'),
        icon: Icons.check_circle_rounded,
        text: 'You’re all caught up',
      );
    }
    final shown = _expanded
        ? requests
        : requests.take(FriendRequestsCard.previewCount).toList();
    final hidden = requests.length - FriendRequestsCard.previewCount;
    return Column(
      key: const ValueKey('requests'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final request in shown)
          _FriendRequestRow(
            key: ValueKey(request.id),
            request: request,
            community: community,
          ),
        if (hidden > 0)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(foregroundColor: _purple),
            icon: Icon(
              _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 18,
            ),
            label: Text(
              _expanded ? 'Show less' : 'Show $hidden more',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }

  Widget _buildFriends(
    BuildContext context,
    CommunityController community,
    List<SocialProfile> friends,
  ) {
    if (friends.isEmpty) {
      return const _CircleEmptyRow(
        key: ValueKey('friends-empty'),
        icon: Icons.group_add_rounded,
        text: 'No friends yet — find someone below',
      );
    }
    return Column(
      key: const ValueKey('friends'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final friend in friends.take(FriendRequestsCard.previewCount))
          _FriendRow(
            key: ValueKey(friend.uid),
            friend: friend,
            community: community,
          ),
        TextButton.icon(
          onPressed: () => _push(context, const FriendsPage()),
          style: TextButton.styleFrom(foregroundColor: _purple),
          icon: const Icon(Icons.groups_rounded, size: 18),
          label: Text(
            'See all ${friends.length} friend${friends.length == 1 ? '' : 's'}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _CircleTabs extends StatelessWidget {
  const _CircleTabs({
    required this.tab,
    required this.requestCount,
    required this.friendCount,
    required this.onChanged,
  });

  final _CircleTab tab;
  final int requestCount;
  final int friendCount;
  final ValueChanged<_CircleTab> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(_CircleTab value, String label, int count) {
      final selected = tab == value;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: selected ? _surface : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x142E1B47),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      color: selected ? _title : _body,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected ? _bellySoft : _border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: selected ? _purple : _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          segment(_CircleTab.requests, 'Requests', requestCount),
          segment(_CircleTab.friends, 'My friends', friendCount),
        ],
      ),
    );
  }
}

class _CircleEmptyRow extends StatelessWidget {
  const _CircleEmptyRow({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: _sage),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _body,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmUnfriend(
  BuildContext context,
  CommunityController community,
  SocialProfile friend,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text('Remove ${friend.displayName}?'),
      content: Text(
        '${friend.displayName} won’t see your future posts, and you won’t see theirs. '
        'They aren’t notified.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _red),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await community.removeFriend(friend);
  } catch (_) {
    if (context.mounted) {
      showAppNotice(context,
          message: 'Couldn’t remove that friend.',
          icon: Icons.warning_amber_rounded);
    }
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({super.key, required this.friend, required this.community});

  final SocialProfile friend;
  final CommunityController community;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CommunityAvatar(profile: friend, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.displayName,
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: _title,
                  ),
                ),
                Text(
                  friend.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _RoundAction(
            tooltip: 'Unfriend ${friend.displayName}',
            icon: Icons.close_rounded,
            background: _red.withValues(alpha: .08),
            foreground: _red,
            onTap: () => _confirmUnfriend(context, community, friend),
          ),
        ],
      ),
    );
  }
}

/// "All my friends": the full list, with unfriend and Find friends.
class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final community = AppScope.of(context).community;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: community,
          builder: (context, _) {
            final friends = community.friends;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const _CommunitySubpageBar(title: 'All my friends'),
                const SizedBox(height: 14),
                ShelbyHeroHeader(
                  color: _purple,
                  icon: Icons.groups_rounded,
                  title: friends.isEmpty
                      ? 'Your circle starts here'
                      : '${friends.length} friend${friends.length == 1 ? '' : 's'} in your circle',
                  subtitle: 'Friends see your “Friends” posts and can cheer you on.',
                ),
                const SizedBox(height: 14),
                const AppCard(
                  padding: EdgeInsets.all(14),
                  child: _FindFriendsPanel(),
                ),
                const SizedBox(height: 14),
                if (friends.isEmpty)
                  const _CircleEmptyRow(
                    icon: Icons.group_add_rounded,
                    text: 'Search a friend’s email above to add them',
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    child: Column(
                      children: [
                        for (var i = 0; i < friends.length; i++) ...[
                          _FriendRow(
                            key: ValueKey(friends[i].uid),
                            friend: friends[i],
                            community: community,
                          ),
                          if (i < friends.length - 1)
                            const Divider(height: 1, color: _border, indent: 50),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CommunitySubpageBar extends StatelessWidget {
  const _CommunitySubpageBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          style: IconButton.styleFrom(backgroundColor: _surface),
          icon: const Icon(Icons.arrow_back_rounded, color: _title),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _title,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Community notifications ───────────────────────────────────────────────

class CommunityNotificationsPage extends StatefulWidget {
  const CommunityNotificationsPage({super.key});

  @override
  State<CommunityNotificationsPage> createState() =>
      _CommunityNotificationsPageState();
}

class _CommunityNotificationsPageState
    extends State<CommunityNotificationsPage> {
  // Unread ids when the page opened, so they stay highlighted this visit.
  Set<String>? _freshIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final community = await _ensureCommunity(context);
      if (!mounted) return;
      setState(() => _freshIds = {
            for (final item in community.notifications)
              if (!item.read) item.id,
          });
      await community.markNotificationsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final community = AppScope.of(context).community;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: community,
          builder: (context, _) {
            final items = community.notifications;
            final fresh = _freshIds ?? const <String>{};
            final newer = items.where((n) => fresh.contains(n.id)).toList();
            final earlier = items.where((n) => !fresh.contains(n.id)).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const _CommunitySubpageBar(title: 'Notifications'),
                const SizedBox(height: 14),
                ShelbyHeroHeader(
                  color: const Color(0xFF4A2F73),
                  icon: Icons.notifications_active_rounded,
                  title: newer.isEmpty
                      ? 'You’re all caught up'
                      : '${newer.length} new from your circle',
                  subtitle: 'Likes, replies and accepted friend requests.',
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  const _CircleEmptyRow(
                    icon: Icons.notifications_none_rounded,
                    text: 'Nothing yet — share a win to get the ball rolling',
                  ),
                if (newer.isNotEmpty) ...[
                  const _SectionLabel('NEW'),
                  for (final item in newer)
                    _NotificationTile(item: item, community: community, fresh: true),
                  const SizedBox(height: 10),
                ],
                if (earlier.isNotEmpty) ...[
                  const _SectionLabel('EARLIER'),
                  for (final item in earlier)
                    _NotificationTile(item: item, community: community),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: _body,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.community,
    this.fresh = false,
  });

  final CommunityNotification item;
  final CommunityController community;
  final bool fresh;

  @override
  Widget build(BuildContext context) {
    final (verb, icon, color) = switch (item.type) {
      CommunityNotificationType.reply => (
          'replied to your post',
          Icons.mode_comment_rounded,
          _purple,
        ),
      CommunityNotificationType.like => (
          'liked your post',
          Icons.favorite_rounded,
          const Color(0xFFE05C7A),
        ),
      CommunityNotificationType.friendAccepted => (
          'accepted your friend request',
          Icons.how_to_reg_rounded,
          _sage,
        ),
    };
    final post = community.postById(item.postId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: fresh ? _bellySoft : _surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: post == null
              ? null
              : () => _openReplies(context, post, community),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: fresh ? _belly : _border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CommunityAvatar(profile: item.actor, size: 40),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: _surface, width: 2),
                        ),
                        child: Icon(icon, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: _title,
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: item.actor.displayName,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            TextSpan(text: ' $verb'),
                          ],
                        ),
                      ),
                      if (item.preview.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          '“${item.preview}”',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _body,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        _timeAgo(item.createdAt),
                        style: const TextStyle(
                          color: _body,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openReplies(
  BuildContext context,
  CommunityPost post,
  CommunityController community,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CommentsSheet(post: post, community: community),
  );
}

// ── Privacy ───────────────────────────────────────────────────────────────

class CommunityPrivacyScreen extends StatelessWidget {
  const CommunityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const _CommunitySubpageBar(title: 'Privacy & security'),
            const SizedBox(height: 14),
            const ShelbyHeroHeader(
              color: _purple,
              icon: Icons.shield_rounded,
              title: 'You decide who finds you',
              subtitle:
                  'Your balances never leave your account. Shared cards only show progress.',
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: SwitchListTile.adaptive(
                value: state.discoverableByEmail,
                activeTrackColor: _brand,
                onChanged: (value) => state.setDiscoverableByEmail(value),
                secondary: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_search_rounded,
                      color: _purple, size: 20),
                ),
                title: const Text(
                  'Let friends find me',
                  style: TextStyle(color: _title, fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  state.discoverableByEmail
                      ? 'People who type your exact email can send you a friend request.'
                      : 'Hidden from email search. Existing friends and requests stay.',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendRequestRow extends StatelessWidget {
  const _FriendRequestRow({
    super.key,
    required this.request,
    required this.community,
  });

  final FriendRequest request;
  final CommunityController community;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
    String failure,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        showAppNotice(context,
            message: failure, icon: Icons.warning_amber_rounded);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final from = request.from;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CommunityAvatar(profile: from, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  from.displayName,
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: _title,
                  ),
                ),
                Text(
                  '${from.email} · ${_timeAgo(request.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _RoundAction(
            tooltip: 'Accept ${from.displayName}',
            icon: Icons.check_rounded,
            background: _brand.withValues(alpha: .16),
            foreground: _sage,
            onTap: () => _run(
              context,
              () => community.acceptFriendRequest(request),
              'Couldn’t accept that request.',
            ),
          ),
          const SizedBox(width: 6),
          _RoundAction(
            tooltip: 'Decline ${from.displayName}',
            icon: Icons.close_rounded,
            background: _bg,
            foreground: _body,
            onTap: () => _run(
              context,
              () => community.declineFriendRequest(request),
              'Couldn’t decline that request.',
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.tooltip,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, size: 18, color: foreground),
          ),
        ),
      ),
    );
  }
}

class _FindFriendsPanel extends StatefulWidget {
  const _FindFriendsPanel({this.autofocus = false});
  final bool autofocus;

  @override
  State<_FindFriendsPanel> createState() => _FindFriendsPanelState();
}

class _FindFriendsPanelState extends State<_FindFriendsPanel> {
  final _controller = TextEditingController();
  var _loading = false;
  var _searched = false;
  SocialProfile? _result;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final community = await _ensureCommunity(context);
      final result = await community.searchByEmail(_controller.text);
      if (!mounted) return;
      setState(() {
        _result = result;
        _searched = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error is CommunityException
          ? error.message
          : 'Search is unavailable right now.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = AppScope.of(context).community;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          onSubmitted: (_) => _search(),
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            color: _title,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Search by email, e.g. friend@email.com',
            hintStyle: TextStyle(
              color: _body.withValues(alpha: .7),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: _body),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Search',
                    onPressed:
                        _controller.text.trim().isEmpty ? null : _search,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    color: _brand,
                  ),
            filled: true,
            fillColor: _bg,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              _error!,
              style: const TextStyle(
                color: _red,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (_searched && _result == null)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'No Shelby account uses that email yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _body,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (_result != null)
          ListenableBuilder(
            listenable: community,
            builder: (context, _) =>
                _SearchResultRow(profile: _result!, community: community),
          ),
      ],
    );
  }
}

class _SearchResultRow extends StatefulWidget {
  const _SearchResultRow({required this.profile, required this.community});

  final SocialProfile profile;
  final CommunityController community;

  @override
  State<_SearchResultRow> createState() => _SearchResultRowState();
}

class _SearchResultRowState extends State<_SearchResultRow> {
  var _busy = false;

  Future<void> _add() async {
    setState(() => _busy = true);
    try {
      await widget.community.sendFriendRequest(widget.profile);
    } catch (error) {
      if (mounted) {
        showAppNotice(
          context,
          message: error is CommunityException
              ? error.message
              : 'Couldn’t send that request.',
          icon: Icons.warning_amber_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.community.statusFor(widget.profile.uid);
    final (label, icon, enabled) = switch (status) {
      FriendStatus.friend => ('Friends', Icons.check_rounded, false),
      FriendStatus.requested => ('Requested', Icons.schedule_rounded, false),
      FriendStatus.incoming => ('Accept', Icons.check_rounded, true),
      FriendStatus.self => ('You', Icons.person_rounded, false),
      FriendStatus.none => ('Add', Icons.person_add_alt_1_rounded, true),
    };
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          CommunityAvatar(profile: widget.profile, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.profile.displayName,
                  style: GoogleFonts.nunito(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: _title,
                  ),
                ),
                Text(
                  widget.profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: enabled && !_busy ? _add : null,
            style: FilledButton.styleFrom(
              backgroundColor: _brand,
              disabledBackgroundColor: _bg,
              disabledForegroundColor: _body,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _busy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, size: 16),
            label: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badges (Profile) ──────────────────────────────────────────────────────

class BadgesCard extends StatelessWidget {
  const BadgesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = computeBadges(AppScope.of(context));
    final earned = badges.where((badge) => badge.earned).length;
    final ordered = [
      ...badges.where((badge) => badge.earned),
      ...badges.where((badge) => !badge.earned),
    ];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Badges',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _title,
                    ),
                  ),
                ),
                Text(
                  '$earned / ${badges.length} earned',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              itemCount: ordered.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) => _BadgeMedallion(
                badge: ordered[index],
                onTap: () => _showBadgeSheet(context, ordered[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeMedallion extends StatelessWidget {
  const _BadgeMedallion({required this.badge, this.onTap, this.size = 56});

  final ShelbyBadge badge;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final medal = SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size + 8,
            height: size + 8,
            child: CircularProgressIndicator(
              value: badge.progress,
              strokeWidth: 3,
              backgroundColor: _border,
              color: badge.earned ? badge.color : _body.withValues(alpha: .45),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: badge.earned
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        badge.color,
                        Color.lerp(badge.color, _purple, .5)!,
                      ],
                    )
                  : null,
              color: badge.earned ? null : _bg,
            ),
            alignment: Alignment.center,
            child: Icon(
              badge.earned ? badge.icon : Icons.lock_rounded,
              size: size * .42,
              color: badge.earned ? Colors.white : _body.withValues(alpha: .5),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return medal;
    return Semantics(
      button: true,
      label: '${badge.title}, ${badge.progressLabel}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 78,
          child: Column(
            children: [
              medal,
              const SizedBox(height: 6),
              Text(
                badge.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: badge.earned ? _title : _body,
                  fontSize: 10.5,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showBadgeSheet(BuildContext context, ShelbyBadge badge) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 20),
            _BadgeMedallion(badge: badge, size: 84),
            const SizedBox(height: 14),
            Text(
              badge.title,
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: _title,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _body,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            if (!badge.earned) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: badge.progress,
                  minHeight: 8,
                  backgroundColor: _border,
                  color: badge.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.progressLabel,
                style: const TextStyle(
                  color: _body,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    showShareAchievementSheet(context, badge.toShareable());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _shareYellow,
                    foregroundColor: _shareYellowInk,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text(
                    'Share it!',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Celebration shown when a badge unlocks, with a direct path to share it.
Future<void> showBadgeUnlockedDialog(BuildContext context, ShelbyBadge badge) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: .40),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, __) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: badge.color.withValues(alpha: .35),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BADGE UNLOCKED',
                style: TextStyle(
                  color: badge.color,
                  fontSize: 11,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _BadgeMedallion(badge: badge, size: 88),
              const SizedBox(height: 14),
              Text(
                badge.title,
                style: GoogleFonts.fredoka(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: _title,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _body,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    showShareAchievementSheet(context, badge.toShareable());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _shareYellow,
                    foregroundColor: _shareYellowInk,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text(
                    'Share it!',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(foregroundColor: _body),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    transitionBuilder: (_, animation, __, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .85, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
