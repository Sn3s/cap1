part of '../../main.dart';

// ─── Badges & shareable stats ───────────────────────────────────────────────
//
// Badges are *derived* from state the app already tracks (log-in streak,
// emergency coverage, Health Score, labelling, investing). They are read-only
// recognition: nothing here feeds back into the Health Score.
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
        detail: description,
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
        description: 'Reached a Financial Health Score of ${b.score.round()}',
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

ShareableAchievement healthScoreShareable(double score, String band) =>
    ShareableAchievement(
      kind: 'score',
      title: 'Financial Health Score',
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
      if (score != null) 'Health ${score.round()}',
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
