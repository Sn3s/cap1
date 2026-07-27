part of '../../main.dart';

/// Shows an in-app notice as a centered pop-up card over a shadowed
/// backdrop, instead of a bottom SnackBar. Use this for warnings/status
/// messages on screens that have a docked FloatingActionButton (a SnackBar
/// there visually shoves the FAB upward as it appears).
Future<void> showAppNotice(
  BuildContext context, {
  required String message,
  IconData icon = Icons.info_rounded,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: .35),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _AppNoticeCard(message: message, icon: icon),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AppNoticeCard extends StatefulWidget {
  const _AppNoticeCard({required this.message, required this.icon});
  final String message;
  final IconData icon;

  @override
  State<_AppNoticeCard> createState() => _AppNoticeCardState();
}

class _AppNoticeCardState extends State<_AppNoticeCard> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .2),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: _bellySoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(widget.icon, color: _brand, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: _title,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
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

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.onAccountTap,
    this.onTimeTap,
  });

  final String eyebrow;
  final String title;
  final VoidCallback? onAccountTap;
  final VoidCallback? onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AccountIconButton(
            onTap: onAccountTap ?? () => _push(context, const ProfilePage()),
          ),
          const SizedBox(width: 8),
          _TimeButton(
            onTap: onTimeTap ??
                () => _push(context, const NotificationSettingsScreen()),
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Shelby reminder times',
      child: IconButton(
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: _bellySoft,
          foregroundColor: _purple,
        ),
        icon: const Icon(Icons.schedule_rounded),
      ),
    );
  }
}

class _AccountIconButton extends StatelessWidget {
  const _AccountIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Account',
      child: IconButton(
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: _bellySoft,
          foregroundColor: _purple,
        ),
        icon: const Icon(Icons.person_rounded),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class PrepInfoCard extends StatelessWidget {
  const PrepInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _title,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: _body,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class SelectableOption extends StatelessWidget {
  const SelectableOption({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.body,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? body;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final dimmed = !enabled;
    return InkWell(
      onTap: dimmed ? null : onTap,
      borderRadius: BorderRadius.circular(22),
      child: Opacity(
        opacity: dimmed ? .45 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? _bellySoft : _surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? _brand : _border, width: 2),
          ),
          child: Row(
            children: [
              IconBubble(
                icon,
                color: selected ? Colors.white : _brand,
                background: selected ? _brand : _bellySoft,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _title,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (body != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        body!,
                        style: const TextStyle(
                          color: _body,
                          height: 1.3,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (dimmed) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.lock_rounded,
                              size: 13, color: _body),
                          const SizedBox(width: 4),
                          Text(
                            'Coming soon',
                            style: const TextStyle(
                              color: _body,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                dimmed
                    ? Icons.lock_outline_rounded
                    : (selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined),
                color: selected ? _brand : _body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.fromUser,
    required this.text,
    this.loading = false,
  });

  final bool fromUser;
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .72,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fromUser ? _brand : _surface,
          borderRadius: BorderRadius.circular(18),
          border: fromUser ? null : Border.all(color: _border),
          boxShadow: fromUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: loading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fromUser ? Colors.white : _brand,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    text,
                    style: TextStyle(
                      color: fromUser ? Colors.white : _body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: _markdownBlocks(
                  text,
                  fromUser ? Colors.white : _title,
                ),
              ),
      ),
    );
  }

  List<InlineSpan> _inlineSpans(
    String value,
    Color color, {
    FontWeight baseWeight = FontWeight.w500,
  }) {
    final spans = <InlineSpan>[];
    var remaining = value;
    while (remaining.isNotEmpty) {
      final start = remaining.indexOf('**');
      if (start == -1) {
        spans.add(TextSpan(text: remaining));
        break;
      }
      if (start > 0) {
        spans.add(TextSpan(text: remaining.substring(0, start)));
      }
      final afterStart = start + 2;
      final end = remaining.indexOf('**', afterStart);
      if (end == -1) {
        spans.add(TextSpan(text: remaining.substring(start)));
        break;
      }
      spans.add(
        TextSpan(
          text: remaining.substring(afterStart, end),
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      );
      remaining = remaining.substring(end + 2);
    }
    return spans;
  }

  static final _headerLine = RegExp(r'^#{1,3}\s+(.*)');
  static final _bulletLine = RegExp(r'^[-*]\s+(.*)');

  List<Widget> _markdownBlocks(String text, Color color) {
    final widgets = <Widget>[];
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 6));
        continue;
      }
      final header = _headerLine.firstMatch(line);
      final bullet = _bulletLine.firstMatch(line);
      if (header != null) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 8, bottom: 2),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  height: 1.32,
                ),
                children: _inlineSpans(header.group(1)!, color,
                    baseWeight: FontWeight.w800),
              ),
            ),
          ),
        );
      } else if (bullet != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        height: 1.32)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        height: 1.32,
                      ),
                      children: _inlineSpans(bullet.group(1)!, color),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  height: 1.32,
                ),
                children: _inlineSpans(line, color),
              ),
            ),
          ),
        );
      }
    }
    return widgets.isEmpty ? [const SizedBox.shrink()] : widgets;
  }
}

class CompactChoice extends StatelessWidget {
  const CompactChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _brand : _surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? _brand : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _title,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? _brand : _border),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: selected ? _brand : _body,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConsentToggle extends StatelessWidget {
  const ConsentToggle({
    super.key,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
    this.locked = false,
  });

  final String title;
  final String body;
  final bool value;
  final bool locked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            IconBubble(locked ? Icons.lock_rounded : Icons.tune_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _title,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(
                      color: _body,
                      height: 1.25,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: _brand,
              onChanged: locked ? null : onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _body, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _title,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.phase,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottom,
    this.centerTitle = false,
    this.scrollBody = true,
    this.onBack,
  });

  final int phase;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottom;
  final bool centerTitle;
  final bool scrollBody;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              PhaseHeader(
                phase: phase,
                total: _onboardingPhaseTotal,
                onBack: onBack,
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: centerTitle ? TextAlign.center : TextAlign.left,
                style: const TextStyle(
                  color: _body,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: scrollBody
                    ? ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [child],
                      )
                    : child,
              ),
              const SizedBox(height: 18),
              bottom,
            ],
          ),
        ),
      ),
    );
  }
}

class PhaseHeader extends StatelessWidget {
  const PhaseHeader({
    super.key,
    required this.phase,
    required this.total,
    this.onBack,
  });

  final int phase;
  final int total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.maybePop(context),
          color: _brand,
          icon: const Icon(Icons.chevron_left_rounded, size: 32),
        ),
        Expanded(child: StepProgress(current: phase, total: total)),
        const SizedBox(width: 14),
        Text(
          'Phase $phase/$total',
          style: const TextStyle(
            color: _body,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: current / total,
        minHeight: 7,
        backgroundColor: _bellySoft,
        color: _brand,
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    final pressed = _pressed && active;
    return GestureDetector(
      onTapDown: active ? (_) => setState(() => _pressed = true) : null,
      onTapUp: active ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: active ? () => setState(() => _pressed = false) : null,
      onTap: active ? widget.onPressed : null,
      child: SizedBox(
        width: double.infinity,
        height: 62,
        child: Stack(
          children: [
            // 3D ledge — visible only when not pressed and active
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: active ? _pressGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            // Button face — slides down 4px on press
            AnimatedPositioned(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              top: pressed ? 4 : 0,
              left: 0,
              right: 0,
              child: Container(
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? _brand : _brand.withOpacity(.3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (widget.icon != null) ...[
                      const SizedBox(width: 10),
                      Icon(widget.icon, size: 20, color: Colors.white),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _bellySoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _belly, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: _purple,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, color: _purple, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.88),
        border: const Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.layers_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text(
            'Shellby',
            style: TextStyle(
              color: _title,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: _body),
          ),
          const CircleAvatar(
            radius: 20,
            backgroundColor: _bellySoft,
            child: Text(
              'F',
              style: TextStyle(color: _brand, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142E1B47), // plum ink @ 8% opacity
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x0D2E1B47), // plum ink @ 5% opacity
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.positive,
    this.color = _brand,
  });

  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final bool positive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(
                icon,
                color: color,
                background: color.withOpacity(.1),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (positive ? _green : _red).withOpacity(.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      positive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: positive ? _green : _red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: TextStyle(
                        color: positive ? _green : _red,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              color: _title,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _body,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.icon,
    this.tag,
  });

  final String title;
  final String description;
  final int progress;
  final IconData icon;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              IconBubble(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: _title,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _bellySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag!.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        color: _body,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                'Current Confidence',
                style: TextStyle(
                  color: _body,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: _brand,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress / 100,
              color: _brand,
              backgroundColor: _bellySoft,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialItemCard extends StatelessWidget {
  const FinancialItemCard({
    super.key,
    required this.item,
    required this.icon,
    this.danger = false,
  });

  final MoneyItem item;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          IconBubble(
            icon,
            color: danger ? _red : _brand,
            background: danger ? const Color(0xFFFFEEF2) : _bellySoft,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: _body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Text(
            money(item.value),
            style: const TextStyle(
              color: _title,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow(
    this.name,
    this.category,
    this.date,
    this.amount,
    this.positive, {
    super.key,
  });

  final String name;
  final String category;
  final String date;
  final String amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBubble(
            positive ? Icons.arrow_outward_rounded : Icons.south_east_rounded,
            color: positive ? _green : _red,
            background: (positive ? _green : _red).withOpacity(.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _title,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$category - $date',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: positive ? _green : _title,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class LineChart extends StatelessWidget {
  const LineChart({super.key, required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(values, labels),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.values, this.labels);

  final List<double> values;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0;
    const bottom = 28.0;
    const top = 16.0;
    final chartWidth = size.width - left - 8;
    final chartHeight = size.height - top - bottom;
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);

    final grid = Paint()
      ..color = _border
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), grid);
    }

    Offset point(int i) {
      final x = left + chartWidth * i / (values.length - 1);
      final normalized = (values[i] - minValue) / (maxValue - minValue);
      final y = top + chartHeight * (1 - normalized);
      return Offset(x, y);
    }

    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }

    final fill = Path.from(path)
      ..lineTo(point(values.length - 1).dx, top + chartHeight)
      ..lineTo(point(0).dx, top + chartHeight)
      ..close();
    canvas.drawPath(fill, Paint()..color = _brand.withOpacity(.07));
    canvas.drawPath(
      path,
      Paint()
        ..color = _brand
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(point(i), 4.5, Paint()..color = _brand);
      _drawText(
        canvas,
        labels[i],
        Offset(point(i).dx - 12, size.height - 18),
        10,
        _body,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Ghost extends StatefulWidget {
  const Ghost({super.key, this.size = 120, this.mood = GhostMood.happy});

  final double size;
  final GhostMood mood;

  @override
  State<Ghost> createState() => _GhostState();
}

enum GhostMood { happy, thinking }

class _GhostState extends State<Ghost> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final lift = math.sin(controller.value * math.pi) * -8;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 4,
                child: Transform.scale(
                  scale: 1 + controller.value * .18,
                  child: Container(
                    width: widget.size * .45,
                    height: widget.size * .08,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, lift),
                child: CustomPaint(
                  painter: _GhostPainter(widget.mood),
                  size: Size.square(widget.size * .88),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  _GhostPainter(this.mood);

  final GhostMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * .18,
        size.height * .14,
        size.width * .64,
        size.height * .68,
      ),
      topLeft: Radius.circular(size.width * .32),
      topRight: Radius.circular(size.width * .32),
      bottomLeft: Radius.circular(size.width * .07),
      bottomRight: Radius.circular(size.width * .07),
    );
    canvas.drawRRect(body, Paint()..color = _brand);
    canvas.drawRRect(
      body.inflate(size.width * .07),
      Paint()..color = _belly.withOpacity(.55),
    );
    final eye = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    if (mood == GhostMood.thinking) {
      canvas.drawLine(
        Offset(size.width * .34, size.height * .38),
        Offset(size.width * .46, size.height * .38),
        eye,
      );
      canvas.drawLine(
        Offset(size.width * .58, size.height * .38),
        Offset(size.width * .70, size.height * .38),
        eye,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * .40, size.height * .38),
          radius: size.width * .06,
        ),
        math.pi,
        math.pi,
        false,
        eye,
      );
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * .64, size.height * .38),
          radius: size.width * .06,
        ),
        math.pi,
        math.pi,
        false,
        eye,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * .52, size.height * .54),
        width: size.width * .25,
        height: size.height * .16,
      ),
      0,
      math.pi,
      false,
      eye,
    );
  }

  @override
  bool shouldRepaint(covariant _GhostPainter oldDelegate) =>
      oldDelegate.mood != mood;
}

class FinancialPyramid extends StatelessWidget {
  const FinancialPyramid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 48,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Container(
            width: 190,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _brand.withOpacity(.82),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'GROWTH',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 86,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _brand,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Text(
              'SECURITY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconBubble extends StatelessWidget {
  const IconBubble(
    this.icon, {
    super.key,
    this.color = _brand,
    this.background = _bellySoft,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.action,
    this.danger = false,
  });

  final String title;
  final String action;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _title,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          action,
          style: TextStyle(
            color: danger ? _red : _brand,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _title,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: _brand, size: 15),
              const SizedBox(width: 7),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: _title,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _brand : _border,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _brand : _body,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class ScoreSlider extends StatelessWidget {
  const ScoreSlider({
    super.key,
    required this.title,
    required this.left,
    required this.right,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String left;
  final String right;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _title,
                  fontSize: 18,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              value.round().toString(),
              style: const TextStyle(
                color: _brand,
                fontSize: 42,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Slider(
          min: 1,
          max: 10,
          divisions: 9,
          value: value,
          activeColor: _brand,
          inactiveColor: _bellySoft,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left.toUpperCase(), style: sliderCaption),
            Text(right.toUpperCase(), style: sliderCaption),
          ],
        ),
      ],
    );
  }
}

const sliderCaption = TextStyle(
  color: _body,
  fontSize: 10,
  fontWeight: FontWeight.w900,
  letterSpacing: 1,
);

class MoneyInput extends StatelessWidget {
  const MoneyInput({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
  });

  final String label;
  final double initial;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial.toStringAsFixed(0),
      keyboardType: TextInputType.number,
      decoration: inputDecoration(
        label,
      ).copyWith(prefixIcon: const Icon(Icons.payments_rounded, color: _body)),
      onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
    );
  }
}

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.title,
    required this.items,
    required this.onAdd,
    this.danger = false,
  });

  final String title;
  final List<MoneyItem> items;
  final VoidCallback onAdd;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: sliderCaption),
        const SizedBox(height: 10),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FinancialItemCard(
              item: item,
              danger: danger,
              icon: danger ? Icons.credit_card_rounded : Icons.savings_rounded,
            ),
          ),
        ),
        DashedAction(
          label: danger ? 'Add Liability' : 'Add Asset',
          onTap: onAdd,
          danger: danger,
        ),
      ],
    );
  }
}

class DashedAction extends StatelessWidget {
  const DashedAction({
    super.key,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? _red : _brand;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _brand,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: _body,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

InputDecoration inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _brand, width: 2),
    ),
  );
}

String money(double value) {
  final rounded = value.toStringAsFixed(2);
  final parts = rounded.split('.');
  final chars = parts.first.split('').reversed.toList();
  final grouped = <String>[];
  for (var i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) grouped.add(',');
    grouped.add(chars[i]);
  }
  return '\u20B1 ${grouped.reversed.join()}.${parts.last}';
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

void _pushReplacement(BuildContext context, Widget page) {
  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => page));
}

void _pushAndRemoveAll(BuildContext context, Widget page) {
  Navigator.of(
    context,
  ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => page), (_) => false);
}
