part of '../main.dart';

/// A small, user-controlled weekly step derived from the plan and the same
/// transaction/action data used elsewhere in Shelby. Challenges never move
/// money, alter a Health Score, or ask Gemini to decide whether a user passed.
enum WeeklyChallengeKind {
  labelRecentTransactions,
  improveActionScore,
  reviewRecurringPayment,
}

enum WeeklyChallengeStatus { active, completed, skipped, expired }

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.kind,
    required this.title,
    required this.reason,
    required this.progressLabel,
    required this.target,
    required this.startedAt,
    required this.endsAt,
    this.goalId,
    this.actionId,
    this.referenceKey,
    this.status = WeeklyChallengeStatus.active,
    this.completedAt,
  });

  final String id;
  final WeeklyChallengeKind kind;
  final String title;
  final String reason;
  final String progressLabel;
  final int target;
  final DateTime startedAt;
  final DateTime endsAt;
  final String? goalId;
  final String? actionId;
  final String? referenceKey;
  final WeeklyChallengeStatus status;
  final DateTime? completedAt;

  bool get isPastDue => DateTime.now().isAfter(endsAt);

  WeeklyChallengeStatus effectiveStatus(DateTime now) {
    if (status != WeeklyChallengeStatus.active) return status;
    return now.isAfter(endsAt) ? WeeklyChallengeStatus.expired : status;
  }

  WeeklyChallenge copyWith({
    WeeklyChallengeStatus? status,
    DateTime? completedAt,
  }) =>
      WeeklyChallenge(
        id: id,
        kind: kind,
        title: title,
        reason: reason,
        progressLabel: progressLabel,
        target: target,
        startedAt: startedAt,
        endsAt: endsAt,
        goalId: goalId,
        actionId: actionId,
        referenceKey: referenceKey,
        status: status ?? this.status,
        completedAt: completedAt ?? this.completedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'reason': reason,
        'progressLabel': progressLabel,
        'target': target,
        'startedAt': startedAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
        'goalId': goalId,
        'actionId': actionId,
        'referenceKey': referenceKey,
        'status': status.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  static WeeklyChallenge? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final data = Map<String, dynamic>.from(raw);
    final kind = WeeklyChallengeKind.values
        .where((value) => value.name == data['kind']?.toString())
        .firstOrNull;
    final status = WeeklyChallengeStatus.values
        .where((value) => value.name == data['status']?.toString())
        .firstOrNull;
    final startedAt = DateTime.tryParse(data['startedAt']?.toString() ?? '');
    final endsAt = DateTime.tryParse(data['endsAt']?.toString() ?? '');
    final target = (data['target'] as num?)?.toInt() ?? 0;
    if (kind == null ||
        status == null ||
        startedAt == null ||
        endsAt == null ||
        target <= 0) {
      return null;
    }
    return WeeklyChallenge(
      id: data['id']?.toString() ?? '',
      kind: kind,
      title: data['title']?.toString() ?? '',
      reason: data['reason']?.toString() ?? '',
      progressLabel: data['progressLabel']?.toString() ?? 'progress',
      target: target,
      startedAt: startedAt,
      endsAt: endsAt,
      goalId: data['goalId']?.toString(),
      actionId: data['actionId']?.toString(),
      referenceKey: data['referenceKey']?.toString(),
      status: status,
      completedAt: DateTime.tryParse(data['completedAt']?.toString() ?? ''),
    );
  }
}

DateTime _challengeWeekStart(DateTime now) =>
    DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));

extension WeeklyChallengeState on AppState {
  /// One active weekly commitment at a time keeps the feature supportive,
  /// rather than adding another competing to-do list to a financial plan.
  WeeklyChallenge? get activeWeeklyChallenge => weeklyChallenges
      .where((challenge) =>
          challenge.effectiveStatus(AppClock.now()) ==
          WeeklyChallengeStatus.active)
      .lastOrNull;

  int weeklyChallengeProgress(WeeklyChallenge challenge) {
    switch (challenge.kind) {
      case WeeklyChallengeKind.labelRecentTransactions:
        return allTransactions.where((transaction) {
          final labelledAt = transaction.labeledAt;
          return transaction.isLabeled &&
              labelledAt != null &&
              !labelledAt.isBefore(challenge.startedAt);
        }).length;
      case WeeklyChallengeKind.improveActionScore:
        return _currentActionScorePercent(this, challenge.actionId ?? '') ?? 0;
      case WeeklyChallengeKind.reviewRecurringPayment:
        final key = challenge.referenceKey;
        return key != null &&
                handledRecurringTransactionSuggestionKeys.contains(key)
            ? 1
            : 0;
    }
  }

  bool weeklyChallengeIsComplete(WeeklyChallenge challenge) =>
      weeklyChallengeProgress(challenge) >= challenge.target;

  /// Returns a transparent deterministic recommendation. The caller displays
  /// it; it is saved only after the user explicitly accepts it.
  WeeklyChallenge? recommendWeeklyChallenge({DateTime? now}) {
    if (activeWeeklyChallenge != null) return null;
    final current = now ?? AppClock.now();
    final start = _challengeWeekStart(current);
    final end = start.add(const Duration(days: 7));
    final activeGoal = selectedGoalId.isNotEmpty ? selectedGoalId : null;
    final unlabelled = allTransactions
        .where((transaction) =>
            !transaction.isLabeled &&
            (transaction.createdAt ?? transaction.labeledAt) != null)
        .length;
    if (unlabelled >= 3) {
      final target = math.min(5, unlabelled);
      return WeeklyChallenge(
        id: 'label-${start.toIso8601String()}',
        kind: WeeklyChallengeKind.labelRecentTransactions,
        title: 'Label $target recent transactions',
        reason:
            'You have $unlabelled records that cannot yet reliably support your goal progress or Insights.',
        progressLabel: 'labelled records',
        target: target,
        startedAt: start,
        endsAt: end,
        goalId: activeGoal,
      );
    }

    final recurring = detectRecurringTransactionSuggestions(allTransactions)
        .where((suggestion) =>
            !handledRecurringTransactionSuggestionKeys.contains(suggestion.key))
        .firstOrNull;
    if (recurring != null) {
      return WeeklyChallenge(
        id: 'recurring-${recurring.key}-$start',
        kind: WeeklyChallengeKind.reviewRecurringPayment,
        title: 'Review ${recurring.merchantName}',
        reason:
            'Shelby detected a ${recurring.frequency.toLowerCase()} payment. Confirm it, edit it, or dismiss it so your plan stays current.',
        progressLabel: 'payment reviewed',
        target: 1,
        startedAt: start,
        endsAt: end,
        goalId: activeGoal,
        referenceKey: recurring.key,
      );
    }

    final scores = _currentMonthActionScores(this);
    final candidates = selectedActionIds
        .map((id) => MapEntry(id, scores[id]))
        .where(
            (entry) => entry.value != null && (entry.value!.pattern.isNotEmpty))
        .map((entry) =>
            MapEntry(entry.key, _actionOverallScore(entry.value!) ?? 100))
        .where((entry) => entry.value < 70)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final candidate = candidates.firstOrNull;
    if (candidate != null) {
      final goalId = _d1GoalMetas
          .where((goal) =>
              goal.actions.any((action) => action.id == candidate.key))
          .firstOrNull
          ?.id;
      return WeeklyChallenge(
        id: 'action-${candidate.key}-$start',
        kind: WeeklyChallengeKind.improveActionScore,
        title: 'Bring one action back on track',
        reason:
            'This action is currently ${candidate.value}% this month. A small focused step this week can support your goal.',
        progressLabel: 'action score',
        target: 70,
        startedAt: start,
        endsAt: end,
        goalId: goalId,
        actionId: candidate.key,
      );
    }
    return null;
  }

  Future<void> acceptWeeklyChallenge(WeeklyChallenge challenge) async {
    if (activeWeeklyChallenge != null) return;
    weeklyChallenges.add(challenge);
    await saveWeeklyChallengeChange();
  }

  Future<void> completeWeeklyChallenge(String challengeId) async {
    final index =
        weeklyChallenges.indexWhere((challenge) => challenge.id == challengeId);
    if (index < 0 ||
        weeklyChallenges[index].effectiveStatus(AppClock.now()) !=
            WeeklyChallengeStatus.active ||
        !weeklyChallengeIsComplete(weeklyChallenges[index])) {
      return;
    }
    weeklyChallenges[index] = weeklyChallenges[index].copyWith(
      status: WeeklyChallengeStatus.completed,
      completedAt: AppClock.now(),
    );
    await saveWeeklyChallengeChange();
  }

  Future<void> skipWeeklyChallenge(String challengeId) async {
    final index =
        weeklyChallenges.indexWhere((challenge) => challenge.id == challengeId);
    if (index < 0 ||
        weeklyChallenges[index].effectiveStatus(AppClock.now()) !=
            WeeklyChallengeStatus.active) {
      return;
    }
    weeklyChallenges[index] =
        weeklyChallenges[index].copyWith(status: WeeklyChallengeStatus.skipped);
    await saveWeeklyChallengeChange();
  }
}
