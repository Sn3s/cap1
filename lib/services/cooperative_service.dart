part of '../main.dart';

/// Server-controlled repository for sensitive cooperative features. It never
/// accepts a full AppState, transaction list, balance, or income payload.
class CooperativeService {
  CooperativeService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<String> createDecisionRequest({
    required String message,
    required List<String> options,
    required List<String> recipients,
    String? context,
    int closeAfterDays = 7,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const CommunityException('Sign in first.');
    final question = message.trim();
    final cleanOptions = options
        .map((option) => option.trim())
        .where((option) => option.isNotEmpty)
        .toSet()
        .toList();
    if (question.isEmpty || question.length > communityPostMaxLength) {
      throw const CommunityException(
          'Write a decision question up to 250 characters.');
    }
    if (cleanOptions.length < 2 ||
        cleanOptions.length > 4 ||
        cleanOptions.any((option) => option.length > 60)) {
      throw const CommunityException('Choose two to four short options.');
    }
    if (recipients.isEmpty || recipients.length > 10) {
      throw const CommunityException(
          'Choose one to ten trusted-circle members.');
    }
    final ref = _db.collection('decisionRequests').doc();
    await ref.set({
      'authorUid': user.uid,
      'author': {
        'uid': user.uid,
        'displayName': user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'Shelby member',
        if ((user.photoURL ?? '').isNotEmpty) 'photoUrl': user.photoURL,
      },
      'audience': [user.uid, ...recipients.toSet()],
      'message': question,
      'options': cleanOptions,
      if ((context ?? '').trim().isNotEmpty) 'context': context!.trim(),
      'status': 'open',
      'closeAt': Timestamp.fromDate(DateTime.now()
          .add(Duration(days: closeAfterDays.clamp(1, 30).toInt()))),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> respond({
    required String decisionId,
    required String option,
    String comment = '',
    bool allowAiReview = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const CommunityException('Sign in first.');
    final cleanComment = comment.trim();
    if (cleanComment.length > communityPostMaxLength) {
      throw const CommunityException(
          'Keep your perspective under 250 characters.');
    }
    await _db
        .collection('decisionRequests')
        .doc(decisionId)
        .collection('responses')
        .doc(user.uid)
        .set({
      'author': {
        'uid': user.uid,
        'displayName': user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'Shelby member',
        if ((user.photoURL ?? '').isNotEmpty) 'photoUrl': user.photoURL,
      },
      'option': option,
      'comment': cleanComment,
      'allowAiReview': allowAiReview,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> close(String decisionId) => _db
      .collection('decisionRequests')
      .doc(decisionId)
      .update({'status': 'closed', 'closedAt': FieldValue.serverTimestamp()});

  Future<BenchmarkPublishResult> publishBenchmarkContribution({
    required String contributorId,
    required String employment,
    required double emergencyMonths,
    required double savingsRate,
  }) async {
    final cohort = _benchmarkCohort(employment);
    final month = _benchmarkMonth();
    await _db
        .collection('benchmarkContributions')
        .doc('${contributorId}_$month')
        .set({
      'month': month,
      'cohort': cohort,
      'emergencyBand': emergencyMonths >= 3
          ? 'three_plus'
          : emergencyMonths >= 1
              ? 'one_to_three'
              : 'under_one',
      'savingBand': savingsRate >= .2
          ? 'twenty_plus'
          : savingsRate > 0
              ? 'some'
              : 'none',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final aggregate = await _aggregateFor(cohort, month);
    return BenchmarkPublishResult(
      eligible: aggregate.eligibleCount >= benchmarkMinimumCohort,
      cohort: cohort,
      month: month,
    );
  }

  Future<String> reviewWithShellby(String decisionId) async {
    final decision =
        await _db.collection('decisionRequests').doc(decisionId).get();
    if (!decision.exists)
      throw const CommunityException('This request is no longer available.');
    final data = decision.data()!;
    final responses = await decision.reference.collection('responses').get();
    final options = (data['options'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
    final totals = <String, int>{for (final option in options) option: 0};
    final permittedComments = <String>[];
    for (final response in responses.docs) {
      final item = response.data();
      final option = item['option']?.toString();
      if (option != null && totals.containsKey(option))
        totals[option] = totals[option]! + 1;
      if (item['allowAiReview'] == true &&
          (item['comment']?.toString().trim().isNotEmpty ?? false)) {
        permittedComments.add(item['comment'].toString().trim());
      }
    }
    final voteSummary = totals.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('; ');
    final commentSummary = permittedComments.isEmpty
        ? 'No comments were selected for this reflection.'
        : permittedComments.map((comment) => '• $comment').join('\n');
    return 'Perspectives\nVotes: $voteSummary.\n\nTrade-offs\nCompare each option with the priority you stated and the flexibility you want to preserve.\n\nSelected comments\n$commentSummary\n\nQuestions to consider\nWhat would make this choice feel sustainable next month? Is a partial allocation possible?\n\nThis is an on-device reflection, not financial advice. The decision remains yours.';
  }

  Stream<List<DecisionRequest>> decisionsFor(String uid) => _db
      .collection('decisionRequests')
      .where('audience', arrayContains: uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => DecisionRequest.fromMap(doc.id, doc.data()))
          .toList());

  Stream<List<DecisionResponse>> responsesFor(String decisionId) => _db
      .collection('decisionRequests')
      .doc(decisionId)
      .collection('responses')
      .orderBy('updatedAt')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => DecisionResponse.fromMap(doc.id, doc.data()))
          .toList());

  Stream<BenchmarkAggregate> benchmarkForEmployment(String employment) => _db
      .collection('benchmarkContributions')
      .where('month', isEqualTo: _benchmarkMonth())
      .where('cohort', isEqualTo: _benchmarkCohort(employment))
      .snapshots()
      .map((snapshot) => BenchmarkAggregate.fromContributions(
          snapshot.docs.map((doc) => doc.data())));

  Future<BenchmarkAggregate> _aggregateFor(String cohort, String month) async {
    final snapshot = await _db
        .collection('benchmarkContributions')
        .where('month', isEqualTo: month)
        .where('cohort', isEqualTo: cohort)
        .get();
    return BenchmarkAggregate.fromContributions(
        snapshot.docs.map((doc) => doc.data()));
  }
}

const benchmarkMinimumCohort = 3;

String _benchmarkMonth() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
}

String _benchmarkCohort(String employment) {
  var cohort = employment
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  if (cohort.length > 40) cohort = cohort.substring(0, 40);
  return cohort.isEmpty ? 'all' : cohort;
}

class BenchmarkPublishResult {
  const BenchmarkPublishResult(
      {required this.eligible, required this.cohort, required this.month});
  final bool eligible;
  final String cohort;
  final String month;
}

class BenchmarkAggregate {
  const BenchmarkAggregate({
    required this.eligibleCount,
    required this.emergencyBands,
    required this.savingBands,
  });

  final int eligibleCount;
  final Map<String, int> emergencyBands;
  final Map<String, int> savingBands;

  static BenchmarkAggregate fromContributions(
      Iterable<Map<String, dynamic>> contributions) {
    final emergencyBands = <String, int>{};
    final savingBands = <String, int>{};
    var eligibleCount = 0;
    for (final contribution in contributions) {
      final emergency = contribution['emergencyBand']?.toString();
      final saving = contribution['savingBand']?.toString();
      if (!const {'under_one', 'one_to_three', 'three_plus'}
              .contains(emergency) ||
          !const {'none', 'some', 'twenty_plus'}.contains(saving)) continue;
      eligibleCount += 1;
      emergencyBands[emergency!] = (emergencyBands[emergency] ?? 0) + 1;
      savingBands[saving!] = (savingBands[saving] ?? 0) + 1;
    }
    return BenchmarkAggregate(
      eligibleCount: eligibleCount,
      emergencyBands: emergencyBands,
      savingBands: savingBands,
    );
  }
}

class DecisionRequest {
  const DecisionRequest({
    required this.id,
    required this.author,
    required this.message,
    required this.options,
    required this.status,
    required this.closeAt,
    this.context,
  });
  final String id;
  final SocialProfile author;
  final String message;
  final List<String> options;
  final String status;
  final DateTime closeAt;
  final String? context;
  bool get isOpen => status == 'open' && closeAt.isAfter(DateTime.now());

  static DecisionRequest fromMap(String id, Map<String, dynamic> data) =>
      DecisionRequest(
        id: id,
        author: SocialProfile.fromMap(Map<String, dynamic>.from(
            data['author'] as Map? ?? {'uid': data['authorUid']})),
        message: data['message']?.toString() ?? '',
        options: [
          if (data['options'] is List)
            for (final option in data['options'] as List) option.toString(),
        ],
        status: data['status']?.toString() ?? 'open',
        closeAt: _communityDate(data['closeAt']),
        context: data['context']?.toString(),
      );
}

class DecisionResponse {
  const DecisionResponse({
    required this.id,
    required this.author,
    required this.option,
    required this.comment,
  });
  final String id;
  final SocialProfile author;
  final String option;
  final String comment;
  static DecisionResponse fromMap(String id, Map<String, dynamic> data) =>
      DecisionResponse(
        id: id,
        author: SocialProfile.fromMap(
            Map<String, dynamic>.from(data['author'] as Map? ?? const {})),
        option: data['option']?.toString() ?? '',
        comment: data['comment']?.toString() ?? '',
      );
}
