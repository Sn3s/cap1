part of '../main.dart';

/// Server-controlled repository for sensitive cooperative features. It never
/// accepts a full AppState, transaction list, balance, or income payload.
class CooperativeService {
  CooperativeService({FirebaseFunctions? functions, FirebaseFirestore? db})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1'),
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _db;

  Future<String> createDecisionRequest({
    required String message,
    required List<String> options,
    required List<String> recipients,
    String? context,
    int closeAfterDays = 7,
  }) async {
    final result =
        await _functions.httpsCallable('createDecisionRequest').call({
      'message': message,
      'options': options,
      'recipients': recipients,
      if ((context ?? '').trim().isNotEmpty) 'context': context!.trim(),
      'closeAfterDays': closeAfterDays,
    });
    return (result.data as Map)['id'].toString();
  }

  Future<void> respond({
    required String decisionId,
    required String option,
    String comment = '',
    bool allowAiReview = false,
  }) =>
      _functions.httpsCallable('respondToDecisionRequest').call({
        'decisionId': decisionId,
        'option': option,
        'comment': comment,
        'allowAiReview': allowAiReview,
      });

  Future<void> close(String decisionId) => _functions
      .httpsCallable('closeDecisionRequest')
      .call({'decisionId': decisionId});

  Future<BenchmarkPublishResult> publishBenchmarkContribution() async {
    final result =
        await _functions.httpsCallable('publishBenchmarkContribution').call();
    final data = result.data as Map;
    return BenchmarkPublishResult(
      eligible: data['eligible'] == true,
      cohort: data['cohort']?.toString() ?? 'all',
      month: data['month']?.toString() ?? '',
    );
  }

  Future<String> reviewWithShellby(String decisionId) async {
    final result = await _functions
        .httpsCallable('reviewDecisionFeedback')
        .call({'decisionId': decisionId});
    return (result.data as Map)['summary']?.toString() ?? '';
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
}

class BenchmarkPublishResult {
  const BenchmarkPublishResult(
      {required this.eligible, required this.cohort, required this.month});
  final bool eligible;
  final String cohort;
  final String month;
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
