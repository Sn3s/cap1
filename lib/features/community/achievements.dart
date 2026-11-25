part of '../../main.dart';

// ─── Badges & shareable stats ───────────────────────────────────────────────
//
// Badges recognize activity without feeding back into the Shelby Score.
//
// A badge stays earned once it has been celebrated (`AppState.seenBadgeIds`),
// so a dip in a balance never takes a badge away.

class ShelbyBadge {
  const ShelbyBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.color,
    required this.current,
    required this.target,
    required this.unit,
    this.alreadyEarned = false,
    this.unlockRequirement,
    this.earnedDescription,
  });

  final String id;
  final String title;
  final String description;
  final String iconKey;
  final Color color;
  final double current;
  final double target;
  final String unit;
  final bool alreadyEarned;
  final String? unlockRequirement;
  final String? earnedDescription;

  bool get earned => alreadyEarned || current >= target;
  double get progress =>
      earned ? 1 : (target <= 0 ? 0 : (current / target).clamp(0.0, 1.0));
  IconData get icon => _shareIcons[iconKey] ?? Icons.emoji_events_rounded;

  String get progressLabel => earned
      ? 'Earned'
      : '${_trimNumber(current)} of ${_trimNumber(target)} $unit';

  ShareableAchievement toShareable() => ShareableAchievement(
        kind: 'badge',
        title: title,
        value: 'Badge unlocked',
        detail: earnedDescription ?? description,
        colorValue: color.toARGB32(),
        iconKey: iconKey,
      );
}

String _trimNumber(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);

const _streakBadges = [
  (days: 3, id: 'streak_3', title: 'Shell Starter'),
  (days: 7, id: 'streak_7', title: 'Week Warrior'),
  (days: 14, id: 'streak_14', title: 'Fortnight Focus'),
  (days: 30, id: 'streak_30', title: 'Monthly Momentum'),
  (days: 100, id: 'streak_100', title: 'Centurion Shell'),
];

const _emergencyBadges = [
  (months: 1.0, id: 'ef_1', title: 'First Cushion'),
  (months: 3.0, id: 'ef_3', title: 'Safety Net'),
  (months: 6.0, id: 'ef_6', title: 'Fully Shielded'),
];

const _healthBadges = [
  (score: 60.0, id: 'health_60', title: 'Healthy Habits'),
  (score: 80.0, id: 'health_80', title: 'Thriving Turtle'),
];

const _habitBuilderId = 'habit_builder';
const _habitBuilderWeeks = 4;

// The calendar date is captured when the user acts. UTC here is a date-only
// representation, so comparing Mondays works across daylight saving changes.
DateTime _habitWeek(DateTime at) {
  final local = at.toLocal();
  return DateTime.utc(local.year, local.month, local.day - local.weekday + 1);
}

typedef _HabitEvent = ({DateTime recordedAt, DateTime week});

String _habitTransactionKey(String id, {String? linkedUid}) =>
    jsonEncode([linkedUid, id]);

bool _qualifiesForHabit(FakeMayaTransaction tx) =>
    tx.amount != 0 && tx.countsTowardFinancialInsights;

int _habitBuilderProgress(AppState state) {
  if (state._financialHabitEvents.isEmpty) return 0;
  final now = AppClock.now();
  final thisWeek = _habitWeek(now);
  final weeks = <DateTime>{};

  void include(FakeMayaTransaction tx, {String? linkedUid}) {
    if (!_qualifiesForHabit(tx)) return;
    final event = state._financialHabitEvents[
        _habitTransactionKey(tx.transactionId, linkedUid: linkedUid)];
    if (event != null &&
        !event.recordedAt.isAfter(now) &&
        !event.week.isAfter(thisWeek)) {
      weeks.add(event.week);
    }
  }

  for (final tx in state.manualTransactions) {
    include(tx);
  }
  if (state.fakeMayaLink case final link?) {
    for (final tx in link.summary.transactions) {
      include(tx, linkedUid: link.userId);
    }
  }

  // A completed run can be recovered after a restart, even when the
  // celebration had not yet written the earned ID to the profile.
  for (final week in weeks) {
    if (Iterable<int>.generate(_habitBuilderWeeks).every(
      (i) => weeks.contains(week.subtract(Duration(days: 7 * i))),
    )) {
      return _habitBuilderWeeks;
    }
  }

  // An open week without activity is still available; a closed gap ends
  // unearned progress. The fourth explicit action can unlock immediately.
  var week = weeks.contains(thisWeek)
      ? thisWeek
      : thisWeek.subtract(const Duration(days: 7));
  var count = 0;
  while (count < _habitBuilderWeeks && weeks.contains(week)) {
    count++;
    week = week.subtract(const Duration(days: 7));
  }
  return count;
}

List<ShelbyBadge> computeBadges(AppState state) {
  final seen = state.seenBadgeIds;
  final streak = math.max(state.longestLoginStreak, state.loginStreak);
  final months = state.emergencyMonthsCovered;
  final score = state.healthScore ?? 0;
  final labeled = state.allTransactions.where((tx) => tx.isLabeled).length;
  return [
    for (final b in _streakBadges)
      ShelbyBadge(
        id: b.id,
        title: b.title,
        description: 'Opened Shelby ${b.days} days in a row',
        iconKey: 'fire',
        color: const Color(0xFFFF7A1A),
        current: streak.toDouble(),
        target: b.days.toDouble(),
        unit: 'days',
        alreadyEarned: seen.contains(b.id),
      ),
    for (final b in _emergencyBadges)
      ShelbyBadge(
        id: b.id,
        title: b.title,
        description:
            'Emergency fund covers ${_trimNumber(b.months)} month${b.months == 1 ? '' : 's'} of essentials',
        iconKey: 'shield',
        color: _red,
        current: months.isFinite ? months : 0,
        target: b.months,
        unit: 'months',
        alreadyEarned: seen.contains(b.id),
      ),
    for (final b in _healthBadges)
      ShelbyBadge(
        id: b.id,
        title: b.title,
        description: 'Reached a Shelby Score of ${b.score.round()}',
        iconKey: 'score',
        color: _purple,
        current: score,
        target: b.score,
        unit: 'pts',
        alreadyEarned: seen.contains(b.id),
      ),
    ShelbyBadge(
      id: 'labels_25',
      title: 'Tidy Tracker',
      description: 'Labelled 25 transactions',
      iconKey: 'label',
      color: _brand,
      current: labeled.toDouble(),
      target: 25,
      unit: 'labels',
      alreadyEarned: seen.contains('labels_25'),
    ),
    ShelbyBadge(
      id: 'invest_first',
      title: 'First Investment',
      description: 'Put money to work in your investment fund',
      iconKey: 'trending',
      color: const Color(0xFF6AA8F0),
      current: state.investmentPortfolioValue > 0 ? 1 : 0,
      target: 1,
      unit: 'step',
      alreadyEarned: seen.contains('invest_first'),
    ),
    ShelbyBadge(
      id: _habitBuilderId,
      title: 'Habit Builder',
      description: 'Build better money habits, one action at a time.',
      unlockRequirement:
          'For four weeks in a row, log a transaction or label an unlabelled FakeMaya transaction.',
      earnedDescription:
          'You kept track of your money for four weeks in a row.',
      iconKey: 'habit',
      color: _purple,
      current: seen.contains(_habitBuilderId)
          ? _habitBuilderWeeks.toDouble()
          : _habitBuilderProgress(state).toDouble(),
      target: _habitBuilderWeeks.toDouble(),
      unit: 'weeks',
      alreadyEarned: seen.contains(_habitBuilderId),
    ),
  ];
}

// ── Shareable stat builders (one per "Share it!" entry point) ─────────────

ShareableAchievement streakShareable(int streak) => ShareableAchievement(
      kind: 'streak',
      title: 'Log-in streak',
      value: '$streak-day streak',
      detail: 'Checking in with my money every day',
      colorValue: 0xFFFF7A1A,
      iconKey: 'fire',
    );

/// A goal's motivation streak (on-time actions in a row), never amounts.
ShareableAchievement goalStreakShareable(String goalTitle, int streak) =>
    ShareableAchievement(
      kind: 'streak',
      title: goalTitle,
      value: '$streak on-time streak',
      detail: 'Doing my ${goalTitle.toLowerCase()} actions on time',
      colorValue: 0xFFFF7A1A,
      iconKey: 'fire',
    );

ShareableAchievement healthScoreShareable(double score, String band) =>
    ShareableAchievement(
      kind: 'score',
      title: _shelbyScoreTitle,
      value: '${score.round()} / 100',
      detail: band,
      colorValue: _purple.toARGB32(),
      iconKey: 'score',
    );

ShareableAchievement scorecardShareable(AppState state) {
  final score = state.healthScore;
  final earned = computeBadges(state).where((badge) => badge.earned).length;
  return ShareableAchievement(
    kind: 'scorecard',
    title: 'My Shelby scorecard',
    value: [
      if (score != null) '$_shelbyScoreTitle ${score.round()}',
      '${state.loginStreak}-day streak',
    ].join(' · '),
    detail: '$earned badge${earned == 1 ? '' : 's'} earned so far',
    colorValue: _brand.toARGB32(),
    iconKey: 'star',
  );
}

ShareableAchievement emergencyShareable(double months) => ShareableAchievement(
      kind: 'goal',
      title: 'Emergency Fund',
      value: '${months.toStringAsFixed(1)} months covered',
      detail: 'Building my safety net',
      colorValue: _red.toARGB32(),
      iconKey: 'shield',
    );

ShareableAchievement milestoneShareable(String title, String subtitle) =>
    ShareableAchievement(
      kind: 'milestone',
      title: 'Milestone reached',
      value: title,
      detail: subtitle,
      colorValue: _red.toARGB32(),
      iconKey: 'trophy',
    );

ShareableAchievement wealthGrowthShareable(double changePercent) =>
    ShareableAchievement(
      kind: 'goal',
      title: 'Accumulating Wealth',
      value: '+${changePercent.toStringAsFixed(1)}% in 14 days',
      detail: 'My investments are growing',
      colorValue: _purple.toARGB32(),
      iconKey: 'trending',
    );

ShareableAchievement freedomOnTrackShareable() => const ShareableAchievement(
      kind: 'goal',
      title: 'Financial Freedom',
      value: 'On track',
      detail: 'Enjoying life on my terms, within plan',
      colorValue: 0xFF6AA8F0,
      iconKey: 'celebration',
    );
