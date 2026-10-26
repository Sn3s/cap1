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
  const ShareItChip(
      {super.key, required this.achievement, this.compact = false});

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
      child:
          const Icon(Icons.ios_share_rounded, size: 11, color: _shareYellowInk),
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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  hint:
                      'How does this win feel? Share advice or cheer yourself on…',
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
    final colors = _gradients[profile.uid.hashCode.abs() % _gradients.length];
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
        border: hero ? null : Border.all(color: color.withValues(alpha: .25)),
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
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
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

enum _CommunitySection { circle, peers }

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  CommunityController? _community;
  var _section = _CommunitySection.circle;

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
    final state = AppScope.of(context);
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
                    'Compare privately or get support from your circle',
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
        _CommunitySectionSwitch(
          value: _section,
          onChanged: (value) => setState(() => _section = value),
        ),
        const SizedBox(height: 14),
        if (_section == _CommunitySection.peers)
          _PeerDashboard(state: state)
        else ...[
          _CommunityBanner(
            friendCount: community.friends.length,
            postsThisWeek: friendPostsThisWeek,
            onFindFriends: () => _showFindFriendsSheet(context),
          ),
          const SizedBox(height: 14),
          if (state.isSignedIn &&
              state.consentCommunity &&
              state.uid != null) ...[
            _DecisionRequestSection(uid: state.uid!),
            const SizedBox(height: 14),
          ],
          if (connected) _PostComposer(community: community, state: state),
          if (community.lastError != null) ...[
            const SizedBox(height: 12),
            _CommunityErrorBanner(message: community.lastError!),
          ],
          const SizedBox(height: 18),
          if (!connected && state.isSignedIn)
            const _CommunityConsentRequired()
          else if (!connected || community.feedLoading)
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
      ],
    );
  }
}

class _CommunityConsentRequired extends StatelessWidget {
  const _CommunityConsentRequired();

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(children: [
          const Icon(Icons.lock_outline_rounded, color: _purple, size: 34),
          const SizedBox(height: 10),
          Text('Your circle is private by default',
              style: GoogleFonts.fredoka(
                  color: _title, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'Turn on Community feedback during your privacy setup before Shellby connects your profile, friends, or shared updates.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _body,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700),
          ),
        ]),
      );
}

class _DecisionRequestSection extends StatelessWidget {
  const _DecisionRequestSection({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<DecisionRequest>>(
        stream: CooperativeService().decisionsFor(uid),
        builder: (context, snapshot) {
          final decisions = snapshot.data ?? const <DecisionRequest>[];
          if (decisions.isEmpty) return const SizedBox.shrink();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trusted-circle decisions',
                    style: TextStyle(
                        color: _title,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                for (final decision in decisions.take(3)) ...[
                  _SecureDecisionCard(decision: decision, uid: uid),
                  const SizedBox(height: 9),
                ],
              ]);
        },
      );
}

class _SecureDecisionCard extends StatelessWidget {
  const _SecureDecisionCard({required this.decision, required this.uid});
  final DecisionRequest decision;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final mine = decision.author.uid == uid;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.how_to_vote_outlined, color: _purple, size: 18),
          const SizedBox(width: 7),
          const Expanded(
              child: Text('Decision request',
                  style: TextStyle(
                      color: _purple,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900))),
          Icon(
              decision.isOpen ? Icons.lock_outline_rounded : Icons.lock_rounded,
              color: _body,
              size: 15),
        ]),
        const SizedBox(height: 8),
        Text(decision.message,
            style: const TextStyle(
                color: _title,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w800)),
        if ((decision.context ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(decision.context!,
              style: const TextStyle(
                  color: _body,
                  fontSize: 11.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: 10),
        if (mine)
          _DecisionAuthorActions(decision: decision)
        else
          Wrap(spacing: 7, runSpacing: 7, children: [
            for (final option in decision.options)
              OutlinedButton(
                onPressed: !decision.isOpen
                    ? null
                    : () =>
                        _showDecisionResponseSheet(context, decision, option),
                child: Text(option),
              ),
          ]),
        const SizedBox(height: 10),
        _DecisionResponsesPreview(decisionId: decision.id),
      ]),
    );
  }
}

Future<void> _showDecisionResponseSheet(
  BuildContext context,
  DecisionRequest decision,
  String option,
) async {
  final comment = TextEditingController();
  var allowAiReview = false;
  var sending = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: _surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Share your perspective',
              style: GoogleFonts.fredoka(
                  color: _title, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Your choice: $option',
              style:
                  const TextStyle(color: _purple, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          _MessageField(
            controller: comment,
            hint: 'Optional: explain your perspective…',
            onChanged: (_) {},
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: allowAiReview,
            onChanged: (value) => setSheetState(() => allowAiReview = value),
            title: const Text(
                'Allow Shelby to include this comment in the author’s review',
                style: TextStyle(
                    color: _title, fontSize: 12, fontWeight: FontWeight.w800)),
            subtitle: const Text(
                'Off by default. Your vote is counted either way.',
                style: TextStyle(
                    color: _body, fontSize: 10.5, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: sending
                    ? null
                    : () async {
                        setSheetState(() => sending = true);
                        try {
                          await CooperativeService().respond(
                            decisionId: decision.id,
                            option: option,
                            comment: comment.text,
                            allowAiReview: allowAiReview,
                          );
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                          if (context.mounted)
                            showAppNotice(context,
                                message: 'Perspective shared.',
                                icon: Icons.check_rounded);
                        } catch (error) {
                          if (context.mounted)
                            showAppNotice(context,
                                message: error is FirebaseException
                                    ? error.message ??
                                        'Couldn’t save that response.'
                                    : 'Couldn’t save that response.',
                                icon: Icons.warning_amber_rounded);
                        } finally {
                          if (context.mounted)
                            setSheetState(() => sending = false);
                        }
                      },
                icon: sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: const Text('Share response'),
              )),
        ]),
      ),
    ),
  );
  comment.dispose();
}

class _DecisionResponsesPreview extends StatelessWidget {
  const _DecisionResponsesPreview({required this.decisionId});
  final String decisionId;
  @override
  Widget build(BuildContext context) => StreamBuilder<List<DecisionResponse>>(
        stream: CooperativeService().responsesFor(decisionId),
        builder: (context, snapshot) {
          final responses = snapshot.data ?? const <DecisionResponse>[];
          if (responses.isEmpty) return const SizedBox.shrink();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${responses.length} response${responses.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
                for (final response in responses
                    .where((item) => item.comment.isNotEmpty)
                    .take(3))
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                        '${response.author.displayName}: ${response.comment}',
                        style: const TextStyle(
                            color: _body,
                            fontSize: 11.5,
                            height: 1.28,
                            fontWeight: FontWeight.w600)),
                  ),
              ]);
        },
      );
}

class _DecisionAuthorActions extends StatelessWidget {
  const _DecisionAuthorActions({required this.decision});
  final DecisionRequest decision;
  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 8, runSpacing: 8, children: [
        OutlinedButton.icon(
          onPressed: () async {
            try {
              final approved = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Review with Shelby?'),
                  content: const Text(
                    'Shelby will create a private on-device reflection from this decision question, the context you chose to share, vote totals, and only comments whose authors selected review. It will not receive your transactions, balances, income, full goals, or health score.',
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Continue')),
                  ],
                ),
              );
              if (approved != true || !context.mounted) return;
              final review =
                  await CooperativeService().reviewWithShellby(decision.id);
              if (!context.mounted) return;
              await showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('Shelby’s reflection'),
                        content: SingleChildScrollView(
                            child: Text(
                                '$review\n\nDecision support only — your final decision remains yours.')),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'))
                        ],
                      ));
            } catch (error) {
              if (context.mounted)
                showAppNotice(context,
                    message: error is FirebaseException
                        ? error.message ?? 'Shelby review is unavailable.'
                        : 'Shelby review is unavailable.',
                    icon: Icons.warning_amber_rounded);
            }
          },
          icon: const Icon(Icons.auto_awesome_outlined, size: 16),
          label: const Text('Review with Shelby'),
        ),
        if (decision.isOpen)
          TextButton(
            onPressed: () => CooperativeService().close(decision.id),
            child: const Text('Close request'),
          ),
      ]);
}

class _CommunitySectionSwitch extends StatelessWidget {
  const _CommunitySectionSwitch({required this.value, required this.onChanged});
  final _CommunitySection value;
  final ValueChanged<_CommunitySection> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            for (final entry in [
              (_CommunitySection.circle, 'Circle', Icons.forum_rounded),
              (_CommunitySection.peers, 'Peers', Icons.groups_rounded),
            ])
              Expanded(
                child: InkWell(
                  onTap: () => onChanged(entry.$1),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          value == entry.$1 ? _bellySoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(entry.$3,
                            size: 16,
                            color: value == entry.$1 ? _purple : _body),
                        const SizedBox(width: 6),
                        Text(entry.$2,
                            style: TextStyle(
                              color: value == entry.$1 ? _purple : _body,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

enum _ComparisonLens { you, friends, peers }

class _PeerDashboard extends StatefulWidget {
  const _PeerDashboard({required this.state});
  final AppState state;

  @override
  State<_PeerDashboard> createState() => _PeerDashboardState();
}

class _PeerDashboardState extends State<_PeerDashboard> {
  var _lens = _ComparisonLens.you;
  String? _selectedFriendUid;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshTrustedCircleSnapshot());
  }

  Future<void> _refreshTrustedCircleSnapshot() async {
    final state = widget.state;
    if (!state.isSignedIn || !state.consentTrustedCircle) return;
    try {
      await CooperativeService().publishTrustedCircleSnapshot(
        emergencyMonths: state.benchmarkEmergencyMonths,
        savingsRate: state.benchmarkSavingsRate,
        selectedActions: state.selectedActionIds.length,
      );
    } catch (_) {
      // The comparison itself remains usable if a background refresh is
      // temporarily offline; the user can revisit after connectivity returns.
    }
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon) = switch (_lens) {
      _ComparisonLens.you => (
          'Your financial context',
          'See your own progress first. Nothing on this view is shared.',
          Icons.person_outline_rounded,
        ),
      _ComparisonLens.friends => (
          'Trusted-circle comparison',
          'Friends appear only when they choose to share these coarse progress bands.',
          Icons.group_outlined,
        ),
      _ComparisonLens.peers => (
          'Anonymous peer context',
          'Compare with a collated cohort—not a leaderboard or a list of people.',
          Icons.visibility_off_rounded,
        ),
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ShelbyHeroHeader(
        color: const Color(0xFF245C71),
        icon: icon,
        title: title,
        subtitle: subtitle,
      ),
      const SizedBox(height: 14),
      _ComparisonLensSwitch(
        value: _lens,
        onChanged: (value) => setState(() => _lens = value),
      ),
      const SizedBox(height: 14),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(.025, .02),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: switch (_lens) {
          _ComparisonLens.you => _YourComparisonView(
              key: const ValueKey('your-comparison'), state: widget.state),
          _ComparisonLens.friends => _FriendsComparisonView(
              key: const ValueKey('friends-comparison'),
              state: widget.state,
              selectedFriendUid: _selectedFriendUid,
              onFriendSelected: (uid) =>
                  setState(() => _selectedFriendUid = uid),
            ),
          _ComparisonLens.peers => _PeerComparisonView(
              key: const ValueKey('peer-comparison'), state: widget.state),
        },
      ),
    ]);
  }
}

class _ComparisonLensSwitch extends StatelessWidget {
  const _ComparisonLensSwitch({required this.value, required this.onChanged});
  final _ComparisonLens value;
  final ValueChanged<_ComparisonLens> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (_ComparisonLens.you, 'You', Icons.person_outline_rounded),
      (_ComparisonLens.friends, 'Friends', Icons.group_outlined),
      (_ComparisonLens.peers, 'Peers', Icons.public_rounded),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: _surface,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: Semantics(
                selected: value == item.$1,
                button: true,
                label: '${item.$2} comparison',
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => onChanged(item.$1),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    scale: value == item.$1 ? 1 : .96,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: value == item.$1 ? _purple : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.$3,
                              size: 16,
                              color: value == item.$1 ? Colors.white : _body),
                          const SizedBox(width: 6),
                          Text(item.$2,
                              style: TextStyle(
                                  color:
                                      value == item.$1 ? Colors.white : _body,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _YourComparisonView extends StatelessWidget {
  const _YourComparisonView({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final emergency = state.benchmarkEmergencyMonths;
    final savings = state.benchmarkSavingsRate;
    final trend = _emergencyTrend(state);
    final hasHistory = state.d1Ledger.isNotEmpty;
    final trendChange = trend.last - trend.first;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: _bellySoft, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.show_chart_rounded, color: _purple),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency-cover trend',
                        style: TextStyle(
                            color: _title,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                    Text('A private view of your recent check-ins',
                        style: TextStyle(
                            color: _body,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700)),
                  ]),
            ),
          ]),
          const SizedBox(height: 18),
          _EmergencyTrendChart(
            points: trend,
            hasHistory: hasHistory,
            currentMonths: emergency,
            change: trendChange,
          ),
          if (!hasHistory) ...[
            const SizedBox(height: 10),
            const Text(
              'This is your baseline. Your line becomes a real trend as emergency-fund activity is recorded.',
              style: TextStyle(
                  color: _body,
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ]),
      ),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your progress at a glance',
              style: TextStyle(
                  color: _title, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Private signals designed to make your next step clear.',
              style: TextStyle(
                  color: _body, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _PersonalProgressBar(
            label: 'Emergency coverage',
            detail: emergency >= 3
                ? '3+ months covered'
                : '${emergency.toStringAsFixed(1)} months covered',
            value: (emergency / 3).clamp(0.0, 1.0),
            color: _sage,
          ),
          _PersonalProgressBar(
            label: 'Saving habit',
            detail: '${(savings * 100).round()}% of your baseline income',
            value: (savings / .20).clamp(0.0, 1.0),
            color: _amber,
          ),
          _PersonalProgressBar(
            label: 'Plan follow-through',
            detail:
                '${state.selectedActionIds.length} selected action${state.selectedActionIds.length == 1 ? '' : 's'}',
            value: (state.selectedActionIds.length / 3).clamp(0.0, 1.0),
            color: _purple,
          ),
        ]),
      ),
    ]);
  }
}

class _FriendsComparisonView extends StatelessWidget {
  const _FriendsComparisonView({
    super.key,
    required this.state,
    required this.selectedFriendUid,
    required this.onFriendSelected,
  });
  final AppState state;
  final String? selectedFriendUid;
  final ValueChanged<String?> onFriendSelected;

  CircleSnapshot get _mine => CircleSnapshot(
        uid: state.uid ?? 'you',
        emergencyBand: state.benchmarkEmergencyMonths >= 3
            ? 'three_plus'
            : state.benchmarkEmergencyMonths >= 1
                ? 'one_to_three'
                : 'under_one',
        savingBand: state.benchmarkSavingsRate >= .2
            ? 'twenty_plus'
            : state.benchmarkSavingsRate > 0
                ? 'some'
                : 'none',
        planBand: state.selectedActionIds.length >= 3
            ? 'committed'
            : state.selectedActionIds.isEmpty
                ? 'starting'
                : 'active',
      );

  @override
  Widget build(BuildContext context) {
    if (!state.consentTrustedCircle) {
      return const _TrustedCircleRequired();
    }
    final friends = state.community.friends;
    if (friends.isEmpty) {
      return const _PeerMetric(
        icon: Icons.group_add_outlined,
        title: 'Build your trusted circle',
        value: 'No friends yet',
        detail:
            'Add trusted friends first. Each person controls whether their coarse progress bands are shared.',
        color: _purple,
      );
    }
    return StreamBuilder<List<CircleSnapshot>>(
      stream: CooperativeService()
          .circleSnapshotsFor(friends.map((friend) => friend.uid)),
      builder: (context, snapshot) {
        final shared = <String, CircleSnapshot>{
          for (final item in snapshot.data ?? const <CircleSnapshot>[])
            item.uid: item,
        };
        final visibleFriends =
            friends.where((friend) => shared.containsKey(friend.uid)).toList();
        if (visibleFriends.isEmpty) {
          return const _PeerMetric(
            icon: Icons.lock_outline_rounded,
            title: 'Waiting for sharing choices',
            value: 'No shared snapshots yet',
            detail:
                'Friends appear here only after they turn on Trusted circle sharing. Shelby never fills this view with their private balances or transactions.',
            color: _purple,
          );
        }
        final selected =
            selectedFriendUid == null ? null : shared[selectedFriendUid];
        final selectedProfile = selected == null
            ? null
            : visibleFriends.firstWhere((friend) => friend.uid == selected.uid);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Trusted-circle progress',
                  style: TextStyle(
                      color: _title,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(
                  child: Text(
                    '${visibleFriends.length} friend${visibleFriends.length == 1 ? '' : 's'} sharing a coarse snapshot',
                    style: const TextStyle(
                        color: _body,
                        fontSize: 11.5,
                        height: 1.3,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text('HIGH-LEVEL ONLY',
                      style: TextStyle(
                          color: _purple,
                          fontSize: 8.5,
                          letterSpacing: .35,
                          fontWeight: FontWeight.w900)),
                ),
              ]),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _FriendSelectionChip(
                  label: 'Circle average',
                  selected: selected == null,
                  onTap: () => onFriendSelected(null),
                ),
                for (final friend in visibleFriends)
                  _FriendSelectionChip(
                    label: friend.displayName,
                    selected: selected?.uid == friend.uid,
                    onTap: () => onFriendSelected(friend.uid),
                  ),
              ]),
              const SizedBox(height: 20),
              _TrustedCircleBarChart(
                mine: _mine,
                focus: selected ?? _circleAverage(shared.values),
                average: _circleAverage(shared.values),
                focusLabel: selectedProfile?.displayName ?? 'Circle average',
                showingIndividual: selectedProfile != null,
              ),
            ]),
          ),
          const SizedBox(height: 10),
          const _CohortTakeaway(
            icon: Icons.verified_user_outlined,
            color: _purple,
            text:
                'The chart compares only three bands: emergency readiness, saving habit, and plan activity. Each friend can turn this sharing off at any time.',
          ),
        ]);
      },
    );
  }

  CircleSnapshot _circleAverage(Iterable<CircleSnapshot> snapshots) {
    final values = snapshots.toList();
    double mean(double Function(CircleSnapshot value) select) =>
        values.map(select).fold(0.0, (sum, value) => sum + value) /
        values.length;
    String emergency(double score) => score >= .75
        ? 'three_plus'
        : score >= .25
            ? 'one_to_three'
            : 'under_one';
    String saving(double score) => score >= .75
        ? 'twenty_plus'
        : score >= .25
            ? 'some'
            : 'none';
    String plan(double score) => score >= .75
        ? 'committed'
        : score >= .25
            ? 'active'
            : 'starting';
    return CircleSnapshot(
      uid: 'circle-average',
      emergencyBand: emergency(mean((item) => item.emergencyScore)),
      savingBand: saving(mean((item) => item.savingScore)),
      planBand: plan(mean((item) => item.planScore)),
    );
  }
}

class _TrustedCircleRequired extends StatelessWidget {
  const _TrustedCircleRequired();
  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.lock_outline_rounded, color: _purple, size: 30),
          const SizedBox(height: 10),
          const Text('Trusted sharing is off',
              style: TextStyle(
                  color: _title, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text(
            'Turn on Trusted circle sharing in Privacy setup to see this view. It shares only three coarse progress bands with current friends—never balances, income, transactions, or your health score.',
            style: TextStyle(
                color: _body,
                fontSize: 11.5,
                height: 1.35,
                fontWeight: FontWeight.w700),
          ),
        ]),
      );
}

List<double> _emergencyTrend(AppState state) {
  final current = math.max(0.0, state.benchmarkEmergencyMonths).toDouble();
  final events = <(DateTime, double)>[];
  for (final entry in state.d1Ledger) {
    final date = DateTime.tryParse(entry['date']?.toString() ?? '');
    final amount = (entry['amount'] as num?)?.toDouble() ?? 0;
    final type = entry['type']?.toString().toLowerCase() ?? '';
    if (date == null || amount <= 0) continue;
    final change = type.contains('use') || type.contains('withdraw')
        ? -amount
        : type.contains('replenish') || type.contains('deposit')
            ? amount
            : 0.0;
    if (change != 0) events.add((date, change));
  }
  if (events.isEmpty) return List<double>.filled(6, current);
  events.sort((a, b) => a.$1.compareTo(b.$1));
  var opening =
      (current - events.fold(0.0, (sum, event) => sum + event.$2)).toDouble();
  final observations = <double>[math.max(0.0, opening).toDouble()];
  for (final event in events) {
    opening = math.max(0.0, opening + event.$2).toDouble();
    observations.add(opening);
  }
  return List<double>.generate(6, (index) {
    final source = (index * (observations.length - 1) / 5).round();
    return observations[source];
  });
}

class _EmergencyTrendChart extends StatelessWidget {
  const _EmergencyTrendChart({
    required this.points,
    required this.hasHistory,
    required this.currentMonths,
    required this.change,
  });

  final List<double> points;
  final bool hasHistory;
  final double currentMonths;
  final double change;

  @override
  Widget build(BuildContext context) {
    final positive = change >= 0;
    final changeLabel = !hasHistory
        ? 'Baseline'
        : '${positive ? '+' : ''}${change.toStringAsFixed(1)} mo';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(
          currentMonths >= 3 ? '3+' : currentMonths.toStringAsFixed(1),
          style: const TextStyle(
            color: _title,
            fontSize: 31,
            height: .95,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 5),
        const Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Text('months covered',
              style: TextStyle(
                  color: _body, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: (positive ? _sage : _amber).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            changeLabel,
            style: TextStyle(
              color: positive ? _sage : _amber,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ]),
      const SizedBox(height: 13),
      SizedBox(
        height: 138,
        width: double.infinity,
        child: Stack(children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (_, progress, __) => CustomPaint(
                painter: _ProgressLinePainter(
                  points: points.map((point) => point * progress).toList(),
                  color: _purple,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 8,
            top: 6,
            child: Text('3 mo target',
                style: TextStyle(
                    color: _body, fontSize: 9.5, fontWeight: FontWeight.w800)),
          ),
          Positioned(
            right: 8,
            bottom: 6,
            child: Text(hasHistory ? 'Today' : 'Today • baseline',
                style: const TextStyle(
                    color: _body, fontSize: 9.5, fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
      const SizedBox(height: 2),
      const Text('Six recent check-in points',
          style: TextStyle(
              color: _body, fontSize: 10, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _ProgressLinePainter extends CustomPainter {
  const _ProgressLinePainter({required this.points, required this.color});
  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const top = 12.0;
    const bottom = 14.0;
    const side = 7.0;
    final chartHeight = math.max(1, size.height - top - bottom);
    final minPoint = math.min(0, points.reduce(math.min));
    final maxPoint = math.max(3, points.reduce(math.max));
    final range = math.max(.25, maxPoint - minPoint);
    final grid = Paint()
      ..color = _border
      ..strokeWidth = 1;
    for (var line = 0; line < 4; line++) {
      final y = top + chartHeight * line / 3;
      canvas.drawLine(Offset(side, y), Offset(size.width - side, y), grid);
    }
    final targetY = top + chartHeight * (1 - (3 - minPoint) / range);
    if (targetY >= top && targetY <= size.height - bottom) {
      final target = Paint()
        ..color = _sage.withValues(alpha: .55)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      for (var x = side; x < size.width - side; x += 7) {
        canvas.drawLine(Offset(x, targetY), Offset(x + 3, targetY), target);
      }
    }
    final path = Path();
    final fill = Path();
    for (var index = 0; index < points.length; index++) {
      final x = side + (size.width - side * 2) * index / (points.length - 1);
      final y = top + chartHeight * (1 - (points[index] - minPoint) / range);
      if (index == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height - bottom);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width - side, size.height - bottom);
    fill.close();
    canvas.drawPath(
      fill,
      Paint()..color = color.withValues(alpha: .12),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var index = 0; index < points.length; index++) {
      final x = side + (size.width - side * 2) * index / (points.length - 1);
      final y = top + chartHeight * (1 - (points[index] - minPoint) / range);
      canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = _surface);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressLinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}

class _PersonalProgressBar extends StatelessWidget {
  const _PersonalProgressBar({
    required this.label,
    required this.detail,
    required this.value,
    required this.color,
  });
  final String label;
  final String detail;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: _title,
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
            ),
            Text(detail,
                style: const TextStyle(
                    color: _body, fontSize: 10.5, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Container(
            height: 9,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(99),
            ),
            clipBehavior: Clip.antiAlias,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              builder: (_, progress, __) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
}

class _FriendSelectionChip extends StatelessWidget {
  const _FriendSelectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          scale: selected ? 1 : .97,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? _purple : _bg,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: selected ? _purple : _border),
            ),
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w900)),
          ),
        ),
      );
}

class _TrustedCircleBarChart extends StatelessWidget {
  const _TrustedCircleBarChart({
    required this.mine,
    required this.focus,
    required this.average,
    required this.focusLabel,
    required this.showingIndividual,
  });
  final CircleSnapshot mine;
  final CircleSnapshot focus;
  final CircleSnapshot average;
  final String focusLabel;
  final bool showingIndividual;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        'Emergency',
        mine.emergencyScore,
        focus.emergencyScore,
        average.emergencyScore
      ),
      (
        'Saving habit',
        mine.savingScore,
        focus.savingScore,
        average.savingScore
      ),
      ('Plan activity', mine.planScore, focus.planScore, average.planScore),
    ];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .985, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey('${focus.uid}-$showingIndividual'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                showingIndividual
                    ? 'You compared with $focusLabel'
                    : 'You compared with your circle average',
                style: const TextStyle(
                    color: _title, fontSize: 12.5, fontWeight: FontWeight.w900),
              ),
            ),
            const Icon(Icons.bar_chart_rounded, size: 18, color: _purple),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const _CircleChartLegend(color: _purple, label: 'You'),
            const SizedBox(width: 12),
            _CircleChartLegend(color: _sage, label: focusLabel),
            if (showingIndividual) ...[
              const SizedBox(width: 12),
              const _CircleChartLegend(color: _body, label: 'Circle avg'),
            ],
          ]),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final metric in metrics)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _CircleMetricBars(
                      label: metric.$1,
                      mine: metric.$2,
                      focus: metric.$3,
                      average: showingIndividual ? metric.$4 : null,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bar height shows a band—not a money amount: early · building · strong.',
            style: TextStyle(
                color: _body,
                fontSize: 10.5,
                height: 1.3,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CircleChartLegend extends StatelessWidget {
  const _CircleChartLegend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Flexible(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _body,
                      fontSize: 10,
                      fontWeight: FontWeight.w800))),
        ]),
      );
}

class _CircleMetricBars extends StatelessWidget {
  const _CircleMetricBars({
    required this.label,
    required this.mine,
    required this.focus,
    required this.average,
  });
  final String label;
  final double mine;
  final double focus;
  final double? average;

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(_bandLabel(focus),
            style: const TextStyle(
                color: _body, fontSize: 9.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        SizedBox(
          height: 116,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _VerticalBandBar(value: mine, color: _purple),
              const SizedBox(width: 5),
              _VerticalBandBar(value: focus, color: _sage),
              if (average != null) ...[
                const SizedBox(width: 5),
                _VerticalBandBar(value: average!, color: _body),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: _title, fontSize: 10, fontWeight: FontWeight.w900)),
      ]);
}

String _bandLabel(double value) => value >= .75
    ? 'Strong'
    : value >= .25
        ? 'Building'
        : 'Early';

class _VerticalBandBar extends StatelessWidget {
  const _VerticalBandBar({required this.value, required this.color});
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: 16,
        height: 108,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(7),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: 16,
          height: math.max(8, 108 * value.clamp(0.0, 1.0)),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(7)),
        ),
      );
}

class _PeerComparisonView extends StatelessWidget {
  const _PeerComparisonView({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isSignedIn && state.consentBenchmarking)
          StreamBuilder<BenchmarkAggregate?>(
            stream: CooperativeService()
                .benchmarkForEmployment(state.employmentStatus),
            builder: (context, snapshot) {
              final benchmark = snapshot.data;
              if (benchmark == null ||
                  benchmark.eligibleCount < benchmarkMinimumCohort) {
                final contributors = benchmark?.eligibleCount ?? 0;
                return _PeerMetric(
                  icon: Icons.insights_outlined,
                  title: 'Anonymous benchmarks',
                  value: '$contributors / $benchmarkMinimumCohort contributors',
                  detail: contributors == 0
                      ? 'Refresh your anonymous summary, then invite similar opted-in users to contribute. Shelby shows the comparison once at least $benchmarkMinimumCohort people participate.'
                      : 'Your cohort is building. Shelby shows the comparison once at least $benchmarkMinimumCohort similar opted-in users participate.',
                  color: _amber,
                );
              }
              return _BenchmarkInsights(
                aggregate: benchmark,
                emergencyMonths: state.benchmarkEmergencyMonths,
                savingsRate: state.benchmarkSavingsRate,
                cohortLabel: state.employmentStatus,
              );
            },
          )
        else
          const _PeerMetric(
            icon: Icons.insights_outlined,
            title: 'Anonymous benchmarks',
            value: 'Opt in to compare',
            detail:
                'Shelby only shows a comparison after enough similar anonymous users participate.',
            color: _amber,
          ),
        const SizedBox(height: 16),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded, color: _purple),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Your exact income, balances, transactions, health score, and goals are never visible to peers here.',
                  style: TextStyle(
                      color: _body,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (state.isSignedIn && state.consentBenchmarking)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final contributorId = state.ensureBenchmarkContributorId();
                  // Persist the private random id first. The contribution
                  // document never contains it as a field, only in its id.
                  await state.saveProfile();
                  final result =
                      await CooperativeService().publishBenchmarkContribution(
                    contributorId: contributorId,
                    employment: state.employmentStatus,
                    emergencyMonths: state.benchmarkEmergencyMonths,
                    savingsRate: state.benchmarkSavingsRate,
                  );
                  if (!context.mounted) return;
                  showAppNotice(
                    context,
                    message: result.eligible
                        ? 'Your anonymous cohort is ready for comparison.'
                        : 'Your anonymous summary was added. Shelby will compare after at least 3 similar users participate.',
                    icon: Icons.lock_outline_rounded,
                  );
                } catch (error) {
                  if (context.mounted) {
                    showAppNotice(context,
                        message: error is FirebaseException
                            ? error.message ??
                                'Couldn’t refresh the anonymous benchmark.'
                            : 'Couldn’t refresh the anonymous benchmark.',
                        icon: Icons.warning_amber_rounded);
                  }
                }
              },
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Refresh anonymous comparison'),
            ),
          )
        else if (state.isSignedIn)
          const Text(
            'Turn on Anonymous peer benchmarks in Privacy setup to contribute a coarse monthly summary and view eligible comparisons.',
            style: TextStyle(
                color: _body,
                fontSize: 11.5,
                height: 1.35,
                fontWeight: FontWeight.w700),
          ),
      ],
    );
  }
}

/// A readable, aggregate-only view of the anonymous contribution records.
/// The bars deliberately show distributions, not rankings or named people.
class _BenchmarkInsights extends StatelessWidget {
  const _BenchmarkInsights({
    required this.aggregate,
    required this.emergencyMonths,
    required this.savingsRate,
    required this.cohortLabel,
  });

  final BenchmarkAggregate aggregate;
  final double emergencyMonths;
  final double savingsRate;
  final String cohortLabel;

  String get _emergencyBand => emergencyMonths >= 3
      ? 'three_plus'
      : emergencyMonths >= 1
          ? 'one_to_three'
          : 'under_one';

  String get _savingBand => savingsRate >= .2
      ? 'twenty_plus'
      : savingsRate > 0
          ? 'some'
          : 'none';

  @override
  Widget build(BuildContext context) {
    final total = aggregate.eligibleCount;
    final normalizedCohort =
        cohortLabel.trim().isEmpty ? 'Similar' : cohortLabel.trim();
    final emergencyStrong = _percent(aggregate.emergencyBands['three_plus']);
    final savingStrong = _percent(aggregate.savingBands['twenty_plus']);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _bellySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.insights_rounded, color: _purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your anonymous peer snapshot',
                        style: TextStyle(
                            color: _title,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text('$total $normalizedCohort contributors this month',
                        style: const TextStyle(
                            color: _body,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: _sage.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text('LIVE',
                    style: TextStyle(
                        color: _sage,
                        fontSize: 10,
                        letterSpacing: .5,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _PeerSnapshotStat(
                label: 'Contributors',
                value: '$total',
                detail: 'this month',
                color: _purple,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _PeerSnapshotStat(
                label: 'Your emergency band',
                value: _displayBand(_emergencyBand),
                detail: 'coarse only',
                color: _amber,
              ),
            ),
          ]),
          const SizedBox(height: 18),
          _CohortDistributionChart(
            icon: Icons.shield_outlined,
            title: 'Emergency coverage',
            subtitle: 'Months of essential expenses covered',
            color: _amber,
            bands: [
              _CohortBand(
                label: 'Under 1 month',
                count: aggregate.emergencyBands['under_one'] ?? 0,
                color: const Color(0xFFE77E63),
                selected: _emergencyBand == 'under_one',
              ),
              _CohortBand(
                label: '1–3 months',
                count: aggregate.emergencyBands['one_to_three'] ?? 0,
                color: _amber,
                selected: _emergencyBand == 'one_to_three',
              ),
              _CohortBand(
                label: '3+ months',
                count: aggregate.emergencyBands['three_plus'] ?? 0,
                color: _sage,
                selected: _emergencyBand == 'three_plus',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CohortTakeaway(
            icon: Icons.lightbulb_outline_rounded,
            text: _emergencyTakeaway(emergencyStrong),
            color: _amber,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: _border),
          ),
          _CohortDistributionChart(
            icon: Icons.savings_outlined,
            title: 'Monthly saving habit',
            subtitle: 'Share of income set aside',
            color: _sage,
            bands: [
              _CohortBand(
                label: 'Not setting aside yet',
                count: aggregate.savingBands['none'] ?? 0,
                color: const Color(0xFFE77E63),
                selected: _savingBand == 'none',
              ),
              _CohortBand(
                label: 'Some savings',
                count: aggregate.savingBands['some'] ?? 0,
                color: _amber,
                selected: _savingBand == 'some',
              ),
              _CohortBand(
                label: '20% or more',
                count: aggregate.savingBands['twenty_plus'] ?? 0,
                color: _sage,
                selected: _savingBand == 'twenty_plus',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CohortTakeaway(
            icon: Icons.auto_graph_rounded,
            text: _savingTakeaway(savingStrong),
            color: _sage,
          ),
          const SizedBox(height: 14),
          const Text(
            '“You” marks only your own coarse band. Every other result is an anonymous cohort total—never an income, balance, transaction, score, or name.',
            style: TextStyle(
                color: _body,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  int _percent(int? count) =>
      ((count ?? 0) * 100 / aggregate.eligibleCount).round();

  String _emergencyTakeaway(int strongPercent) => switch (_emergencyBand) {
        'three_plus' =>
          'You are in the 3+ month group. $strongPercent% of this cohort reports the same level of coverage.',
        'one_to_three' =>
          'You are in the 1–3 month group. Your next personal milestone is a 3-month cushion.',
        _ =>
          'You are building your first month of coverage. Progress is shown as a band, never a balance.',
      };

  String _savingTakeaway(int strongPercent) => switch (_savingBand) {
        'twenty_plus' =>
          'You are in the 20%+ group. $strongPercent% of this cohort reports the same saving range.',
        'some' =>
          'You are setting something aside. The chart shows the cohort mix, not anyone’s exact rate.',
        _ =>
          'Your snapshot is currently in the “not setting aside yet” band. Refresh after your next update.',
      };
}

String _displayBand(String value) => switch (value) {
      'three_plus' || 'twenty_plus' => 'Strong',
      'one_to_three' || 'some' => 'Building',
      _ => 'Early',
    };

class _PeerSnapshotStat extends StatelessWidget {
  const _PeerSnapshotStat({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .16)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  color: _body, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: color, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(detail,
              style: const TextStyle(
                  color: _body, fontSize: 9.5, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _CohortBand {
  const _CohortBand({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
}

class _CohortDistributionChart extends StatelessWidget {
  const _CohortDistributionChart({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bands,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<_CohortBand> bands;

  @override
  Widget build(BuildContext context) {
    final total = bands.fold<int>(0, (sum, band) => sum + band.count);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _BenchmarkSectionHeading(
        icon: icon,
        title: title,
        subtitle: subtitle,
        color: color,
      ),
      const SizedBox(height: 12),
      Row(children: [
        const Text('Cohort mix',
            style: TextStyle(
                color: _body, fontSize: 10.5, fontWeight: FontWeight.w800)),
        const Spacer(),
        const Icon(Icons.person_pin_circle_outlined, size: 14, color: _purple),
        const SizedBox(width: 4),
        const Text('Your band',
            style: TextStyle(
                color: _purple, fontSize: 10.5, fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 46,
          child: Row(
            children: [
              for (final band in bands)
                Expanded(
                  flex: math.max(1, band.count),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 560),
                    curve: Curves.easeOutCubic,
                    builder: (_, progress, __) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color:
                            band.color.withValues(alpha: .25 + .75 * progress),
                        border: band.selected
                            ? Border.all(color: _purple, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        total == 0
                            ? '0%'
                            : '${(band.count * 100 / total).round()}%',
                        style: TextStyle(
                          color: _title,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 9),
      for (final band in bands)
        _CohortDistributionLegend(band: band, total: total),
    ]);
  }
}

class _CohortDistributionLegend extends StatelessWidget {
  const _CohortDistributionLegend({required this.band, required this.total});

  final _CohortBand band;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (band.count * 100 / total).round();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: band.selected ? _bellySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: band.selected
              ? _purple.withValues(alpha: .34)
              : Colors.transparent,
        ),
      ),
      child: Row(children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: band.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(band.label,
              style: const TextStyle(
                  color: _title, fontSize: 10.5, fontWeight: FontWeight.w800)),
        ),
        if (band.selected) ...[
          const Text('YOU',
              style: TextStyle(
                  color: _purple,
                  fontSize: 8.5,
                  letterSpacing: .35,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
        ],
        Text('$percent% · ${band.count}',
            style: const TextStyle(
                color: _body, fontSize: 10, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _BenchmarkSectionHeading extends StatelessWidget {
  const _BenchmarkSectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 19, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: _title,
                      fontSize: 13,
                      fontWeight: FontWeight.w900)),
              Text(subtitle,
                  style: const TextStyle(
                      color: _body,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ]);
}

class _CohortTakeaway extends StatelessWidget {
  const _CohortTakeaway({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: _title,
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      );
}

class _PeerMetric extends StatelessWidget {
  const _PeerMetric(
      {required this.icon,
      required this.title,
      required this.value,
      required this.detail,
      required this.color});
  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
                Text(value,
                    style: const TextStyle(
                        color: _title,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(detail,
                    style: const TextStyle(
                        color: _body,
                        fontSize: 11.5,
                        height: 1.25,
                        fontWeight: FontWeight.w600)),
              ])),
        ]),
      );
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
                              child:
                                  CommunityAvatar(profile: shown[i], size: 28),
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
  const _PostComposer({required this.community, required this.state});
  final CommunityController community;
  final AppState state;

  @override
  State<_PostComposer> createState() => _PostComposerState();
}

class _PostComposerState extends State<_PostComposer> {
  final _controller = TextEditingController();
  final _firstOption = TextEditingController();
  final _secondOption = TextEditingController();
  final Set<String> _recipients = {};
  var _visibility = PostVisibility.friends;
  var _kind = CommunityPostKind.update;
  var _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    _firstOption.dispose();
    _secondOption.dispose();
    super.dispose();
  }

  CommunityShareSnapshot? get _snapshot {
    if (_kind == CommunityPostKind.goalProgress) {
      final goal = widget.state.selectedGoal.trim();
      return CommunityShareSnapshot(
        title: goal.isEmpty ? 'My current financial goal' : goal,
        detail: widget.state.selectedActionIds.isEmpty
            ? 'I am setting up my next step.'
            : '${widget.state.selectedActionIds.length} selected action${widget.state.selectedActionIds.length == 1 ? '' : 's'} in my plan.',
        kind: _kind,
      );
    }
    if (_kind == CommunityPostKind.actionProgress) {
      final actionId = widget.state.selectedActionIds.isEmpty
          ? null
          : widget.state.selectedActionIds.first;
      final action = actionId == null ? null : _d2Actions[actionId];
      return CommunityShareSnapshot(
        title: action?.text ?? 'My next money action',
        detail: 'In progress · shared without amounts or account details.',
        kind: _kind,
      );
    }
    return null;
  }

  String get _hint => switch (_kind) {
        CommunityPostKind.question =>
          'What would you like your circle to help you think through?',
        CommunityPostKind.decision =>
          'Describe the decision and the context you want to share…',
        CommunityPostKind.goalProgress =>
          'What support or accountability would help?',
        CommunityPostKind.actionProgress =>
          'What update or support would you like to share?',
        CommunityPostKind.update =>
          'Share a small win, question, or money reflection…',
      };

  Future<void> _submit() async {
    setState(() => _posting = true);
    try {
      if (_kind == CommunityPostKind.decision && widget.state.isSignedIn) {
        if (_recipients.isEmpty) {
          throw const CommunityException(
              'Choose at least one trusted-circle member.');
        }
        await CooperativeService().createDecisionRequest(
          message: _controller.text,
          options: [_firstOption.text.trim(), _secondOption.text.trim()],
          recipients: _recipients.toList(),
        );
        _controller.clear();
        _firstOption.clear();
        _secondOption.clear();
        _recipients.clear();
        if (mounted) {
          setState(() => _kind = CommunityPostKind.update);
          showAppNotice(context,
              message: 'Your decision request is now with your trusted circle.',
              icon: Icons.send_rounded);
        }
        return;
      }
      await widget.community.createPost(
        message: _controller.text,
        visibility: _visibility,
        kind: _kind,
        snapshot: _snapshot,
        decisionOptions: _kind == CommunityPostKind.decision
            ? [_firstOption.text.trim(), _secondOption.text.trim()]
                .where((option) => option.isNotEmpty)
                .toList()
            : const [],
      );
      _controller.clear();
      _firstOption.clear();
      _secondOption.clear();
      if (mounted) setState(() => _kind = CommunityPostKind.update);
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
    final hasChoices = _kind != CommunityPostKind.decision ||
        (_firstOption.text.trim().isNotEmpty &&
            _secondOption.text.trim().isNotEmpty);
    final canPost =
        _controller.text.trim().isNotEmpty && hasChoices && !_posting;
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
                    Text(
                      _kind == CommunityPostKind.update
                          ? 'Share with your circle'
                          : _kind.label,
                      style: TextStyle(
                          color: _purple,
                          fontSize: 11,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    _MessageField(
                      controller: _controller,
                      bordered: false,
                      hint: _hint,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _PostKindPicker(
            value: _kind,
            onChanged: (value) => setState(() => _kind = value),
          ),
          if (_snapshot != null) ...[
            const SizedBox(height: 10),
            _ShareSnapshotPreview(snapshot: _snapshot!),
          ],
          if (_kind == CommunityPostKind.decision) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _DecisionOptionField(
                      controller: _firstOption,
                      hint: 'Option 1',
                      onChanged: (_) => setState(() {}))),
              const SizedBox(width: 8),
              Expanded(
                  child: _DecisionOptionField(
                      controller: _secondOption,
                      hint: 'Option 2',
                      onChanged: (_) => setState(() {}))),
            ]),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickRecipients,
              icon: const Icon(Icons.group_outlined, size: 16),
              label: Text(_recipients.isEmpty
                  ? 'Choose trusted-circle members'
                  : '${_recipients.length} recipient${_recipients.length == 1 ? '' : 's'} selected'),
            ),
          ],
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

  Future<void> _pickRecipients() async {
    final picked = Set<String>.from(_recipients);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Choose your trusted circle',
                  style: TextStyle(
                      color: _title,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Only selected current friends can view and respond.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              for (final friend in widget.community.friends)
                CheckboxListTile(
                  value: picked.contains(friend.uid),
                  onChanged: (selected) => setSheetState(() {
                    selected == true
                        ? picked.add(friend.uid)
                        : picked.remove(friend.uid);
                  }),
                  title: Text(friend.displayName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w800)),
                  secondary: CommunityAvatar(profile: friend, size: 32),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              const SizedBox(height: 6),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _recipients
                          ..clear()
                          ..addAll(picked);
                      });
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Use selected members'),
                  )),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PostKindPicker extends StatelessWidget {
  const _PostKindPicker({required this.value, required this.onChanged});
  final CommunityPostKind value;
  final ValueChanged<CommunityPostKind> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final kind in CommunityPostKind.values)
            Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(
                selected: value == kind,
                onSelected: (_) => onChanged(kind),
                avatar: Icon(kind.icon,
                    size: 14, color: value == kind ? Colors.white : _body),
                label: Text(kind.label),
                labelStyle: TextStyle(
                    color: value == kind ? Colors.white : _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
                selectedColor: _purple,
                backgroundColor: _bg,
                side: BorderSide(color: value == kind ? _purple : _border),
              ),
            ),
        ]),
      );
}

class _DecisionOptionField extends StatelessWidget {
  const _DecisionOptionField(
      {required this.controller, required this.hint, required this.onChanged});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        maxLength: 60,
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: _bg,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border)),
        ),
      );
}

class _ShareSnapshotPreview extends StatelessWidget {
  const _ShareSnapshotPreview({required this.snapshot});
  final CommunityShareSnapshot snapshot;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: _bellySoft, borderRadius: BorderRadius.circular(13)),
        child: Row(children: [
          Icon(snapshot.kind.icon, color: _purple, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(snapshot.title,
                    style: const TextStyle(
                        color: _title,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
                Text(snapshot.detail,
                    style: const TextStyle(
                        color: _body,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ])),
          const Icon(Icons.lock_outline_rounded, color: _purple, size: 15),
        ]),
      );
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
                      mine
                          ? '${post.author.displayName} (you)'
                          : post.author.displayName,
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
          if (post.kind != CommunityPostKind.update)
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 8),
              child: _PostTypePill(kind: post.kind),
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
          if (post.snapshot != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: _SharedSnapshotCard(snapshot: post.snapshot!),
            ),
          if (post.kind == CommunityPostKind.decision)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: _DecisionChoices(post: post, community: community),
            ),
          Row(
            children: [
              _PostAction(
                icon: liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
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

class _PostTypePill extends StatelessWidget {
  const _PostTypePill({required this.kind});
  final CommunityPostKind kind;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: _bellySoft, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(kind.icon, size: 13, color: _purple),
          const SizedBox(width: 5),
          Text(kind.label,
              style: const TextStyle(
                  color: _purple, fontSize: 10.5, fontWeight: FontWeight.w900)),
        ]),
      );
}

class _SharedSnapshotCard extends StatelessWidget {
  const _SharedSnapshotCard({required this.snapshot});
  final CommunityShareSnapshot snapshot;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: _bellySoft, borderRadius: BorderRadius.circular(11)),
            child: Icon(snapshot.kind.icon, size: 18, color: _purple),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(snapshot.title,
                    style: const TextStyle(
                        color: _title,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900)),
                Text(snapshot.detail,
                    style: const TextStyle(
                        color: _body,
                        fontSize: 11,
                        height: 1.25,
                        fontWeight: FontWeight.w700)),
              ])),
          const Tooltip(
              message: 'A static, user-approved summary',
              child: Icon(Icons.lock_outline_rounded, size: 15, color: _body)),
        ]),
      );
}

class _DecisionChoices extends StatelessWidget {
  const _DecisionChoices({required this.post, required this.community});
  final CommunityPost post;
  final CommunityController community;

  @override
  Widget build(BuildContext context) {
    final uid = community.me?.uid ?? '';
    final mine = post.author.uid == uid;
    final vote = post.voteBy(uid);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: _bellySoft.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          mine
              ? '${post.decisionVotes.length} perspective${post.decisionVotes.length == 1 ? '' : 's'} from your circle'
              : 'Share your perspective',
          style: const TextStyle(
              color: _title, fontSize: 11.5, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        for (final option in post.decisionOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: mine
                  ? null
                  : () async {
                      try {
                        await community.voteOnDecision(post, option);
                      } catch (_) {
                        if (context.mounted) {
                          showAppNotice(context,
                              message: 'Couldn’t save that perspective.',
                              icon: Icons.warning_amber_rounded);
                        }
                      }
                    },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  color: vote == option ? _purple : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: vote == option ? _purple : _border),
                ),
                child: Row(children: [
                  Expanded(
                      child: Text(option,
                          style: TextStyle(
                              color: vote == option ? Colors.white : _title,
                              fontSize: 12,
                              fontWeight: FontWeight.w800))),
                  Text('${post.votesFor(option)}',
                      style: TextStyle(
                          color: vote == option ? Colors.white : _body,
                          fontSize: 11,
                          fontWeight: FontWeight.w900)),
                ]),
              ),
            ),
          ),
        if (mine)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
                'Votes are input, not instructions. Your final decision stays private.',
                style: TextStyle(
                    color: _body, fontSize: 10.5, fontWeight: FontWeight.w700)),
          ),
      ]),
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
      FocusManager.instance.primaryFocus?.unfocus();
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

  Future<void> _delete(PostComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete reply?'),
        content: const Text('This removes your reply for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.community.deleteComment(widget.post, comment);
    } catch (_) {
      if (mounted) {
        showAppNotice(context,
            message: 'Couldn’t delete that reply.',
            icon: Icons.warning_amber_rounded);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Fit in the space above the keyboard so the header and composer stay
    // on screen while typing (a fixed height overflowed the screen).
    final height = math.min(
      media.size.height * .72,
      media.size.height - keyboard - media.padding.top - 24,
    );
    final myUid = widget.community.me?.uid;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close replies',
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: _brand.withValues(alpha: .12),
                      foregroundColor: _sage,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
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
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${comment.author.displayName} · ${_timeAgo(comment.createdAt)}',
                                            style: const TextStyle(
                                              color: _body,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        if (comment.author.uid == myUid)
                                          InkWell(
                                            onTap: () => _delete(comment),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: const Padding(
                                              padding: EdgeInsets.all(2),
                                              child: Icon(
                                                Icons.delete_outline_rounded,
                                                size: 16,
                                                color: _body,
                                                semanticLabel: 'Delete reply',
                                              ),
                                            ),
                                          ),
                                      ],
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
    setState(
        () => _tab = velocity < 0 ? _CircleTab.friends : _CircleTab.requests);
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
                  subtitle:
                      'Friends see your “Friends” posts and can cheer you on.',
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
                            const Divider(
                                height: 1, color: _border, indent: 50),
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
                    _NotificationTile(
                        item: item, community: community, fresh: true),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900),
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
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: SwitchListTile.adaptive(
                value: state.consentBenchmarking,
                activeTrackColor: _brand,
                onChanged: state.isSignedIn
                    ? (value) => state.setConsentBenchmarking(value)
                    : null,
                secondary: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insights_outlined,
                      color: _purple, size: 20),
                ),
                title: const Text(
                  'Anonymous peer benchmarks',
                  style: TextStyle(color: _title, fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  state.isSignedIn
                      ? 'Share only coarse monthly bands to compare with similar opted-in users. No identity, income, balances, or transactions are included.'
                      : 'Sign in to choose whether you join anonymous peer comparisons.',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: SwitchListTile.adaptive(
                value: state.consentCommunity,
                activeTrackColor: _brand,
                onChanged: state.isSignedIn
                    ? (value) => state.setConsentCommunity(value)
                    : null,
                secondary: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.forum_outlined,
                      color: _purple, size: 20),
                ),
                title: const Text(
                  'Community feedback',
                  style: TextStyle(color: _title, fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  state.isSignedIn
                      ? 'Use the friends feed for posts, comments, and selected updates. You choose every item you share.'
                      : 'Sign in to use the friends feed.',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: SwitchListTile.adaptive(
                value: state.consentTrustedCircle,
                activeTrackColor: _brand,
                onChanged: state.isSignedIn
                    ? (value) => state.setConsentTrustedCircle(value)
                    : null,
                secondary: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _bellySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.group_outlined,
                      color: _purple, size: 20),
                ),
                title: const Text(
                  'Trusted circle sharing',
                  style: TextStyle(color: _title, fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  state.isSignedIn
                      ? 'Let people you explicitly add exchange chosen posts and decision perspectives.'
                      : 'Sign in to manage trusted-circle sharing.',
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
                    onPressed: _controller.text.trim().isEmpty ? null : _search,
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
