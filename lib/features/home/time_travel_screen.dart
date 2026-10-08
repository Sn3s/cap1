part of '../../main.dart';

/// Developer tool for shifting [AppClock] to test time-sensitive features
/// (weekly check-ins, month rollovers, deadlines, streaks, etc.).
class TimeTravelScreen extends StatefulWidget {
  const TimeTravelScreen({super.key});

  @override
  State<TimeTravelScreen> createState() => _TimeTravelScreenState();
}

class _TimeTravelScreenState extends State<TimeTravelScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = AppClock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    await AppClock.setNow(DateTime(
      picked.year,
      picked.month,
      picked.day,
      now.hour,
      now.minute,
      now.second,
    ));
  }

  Future<void> _pickTime() async {
    final now = AppClock.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (picked == null) return;
    await AppClock.setNow(
      DateTime(now.year, now.month, now.day, picked.hour, picked.minute),
    );
  }

  Future<void> _shiftMonths(int months) {
    final now = AppClock.now();
    // Clamp the day so e.g. Jan 31 + 1 month lands on the last day of Feb.
    final lastDay = DateTime(now.year, now.month + months + 1, 0).day;
    return AppClock.setNow(DateTime(
      now.year,
      now.month + months,
      math.min(now.day, lastDay),
      now.hour,
      now.minute,
      now.second,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final now = AppClock.now();
    final overridden = AppClock.isOverridden;
    final shifts = <(String, Future<void> Function())>[
      ('-1 day', () => AppClock.shift(const Duration(days: -1))),
      ('+1 hour', () => AppClock.shift(const Duration(hours: 1))),
      ('+1 day', () => AppClock.shift(const Duration(days: 1))),
      ('+1 week', () => AppClock.shift(const Duration(days: 7))),
      ('+1 month', () => _shiftMonths(1)),
      ('Next Monday', () {
        final daysAhead = 8 - now.weekday;
        final target = DateTime(now.year, now.month, now.day + daysAhead, 9);
        return AppClock.setNow(target);
      }),
      ('Start of next month', () {
        return AppClock.setNow(DateTime(now.year, now.month + 1, 1, 9));
      }),
    ];
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _SelectionsHeader(
              title: 'Time travel',
              subtitle: 'DEVELOPER',
              onBack: () => Navigator.maybePop(context),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          overridden ? 'SIMULATED TIME' : 'REAL TIME',
                          style: TextStyle(
                            color: overridden ? _purple : _body,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _timeTravelDate(now),
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: _title,
                          ),
                        ),
                        Text(
                          _timeTravelClock(now),
                          style: GoogleFonts.fredoka(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: overridden ? _purple : _title,
                          ),
                        ),
                        if (overridden) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Offset: ${_timeTravelOffset(AppClock.offset.value)}',
                            style: const TextStyle(
                              color: _body,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Set date',
                          icon: Icons.calendar_month_rounded,
                          onPressed: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SecondaryButton(
                          label: 'Set time',
                          icon: Icons.schedule_rounded,
                          onPressed: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Quick jumps',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _title,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (label, action) in shifts)
                        ActionChip(
                          label: Text(label),
                          onPressed: action,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Back to real time',
                    icon: Icons.restore_rounded,
                    enabled: overridden,
                    onPressed: AppClock.reset,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Shifts the date and time the app uses everywhere. '
                    'The clock keeps ticking from the simulated time and the '
                    'setting is kept after restarting the app. '
                    'Scheduled phone notifications still follow the real clock.',
                    style: TextStyle(color: _body, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _timeTravelWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _timeTravelMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _timeTravelDate(DateTime value) =>
    '${_timeTravelWeekdays[value.weekday - 1]}, '
    '${_timeTravelMonths[value.month - 1]} ${value.day}, ${value.year}';

String _timeTravelClock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final second = value.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second ${value.hour < 12 ? 'AM' : 'PM'}';
}

String _timeTravelOffset(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final abs = offset.abs();
  final days = abs.inDays;
  final hours = abs.inHours % 24;
  final minutes = abs.inMinutes % 60;
  return '$sign${days}d ${hours}h ${minutes}m';
}
