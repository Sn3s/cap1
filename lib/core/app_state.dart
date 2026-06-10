part of '../main.dart';

class AppState extends ChangeNotifier {
  String? uid;
  String name = '';
  String email = '';
  String? photoUrl;
  bool onboardingComplete = false;
  String age = '';
  String occupation = '';
  String industry = 'Technology';
  String employmentStatus = 'Full-time';
  String incomeType = 'Fixed';
  String incomeRhythm = 'Monthly';
  String billsRhythm = 'Predictable dates';
  String checkInRhythm = 'Weekly';
  String location = 'Urban';
  String responsibility = 'Mostly myself';
  String primaryConcern = 'Cash Flow & Basic Needs';
  String motivation = '';
  String reflectedMotivation = '';
  String chatSurfaceSummary = '';
  String chatGoalFocusSummary = '';
  String chatTimeframeSummary = '';
  String chatDifficultySummary = '';
  String chatSituationsSummary = '';
  String chatChallengesSummary = '';
  String selectedGoal = 'Cash Flow Stability Plan';
  String selectedGoalDescription =
      'Map income, fixed costs, and spending patterns so your monthly budget has a clear baseline.';
  double selectedGoalMonthlyTarget = 0;
  String socialStructure = 'Private only';
  double confidence = 5;
  double anxiety = 5;
  double avoidance = 5;
  double peerPressure = 5;
  double income = 8240;
  double expenses = 3120.5;
  double variableExpenses = 1800;
  double savings = 1200;
  double emergencyMonths = 1.5;
  double debtPayments = 650;
  double investments = 12000;
  double subscriptions = 145;
  bool consentBaseline = true;
  bool consentAi = true;
  bool consentBenchmarking = false;
  bool consentCommunity = false;
  bool consentTrustedCircle = false;
  bool emotionalLogsEnabled = false;
  bool stressIndicatorsEnabled = false;
  final Set<String> selectedActionIds = {'ACT1'};
  final Set<String> trackingVariables = {
    'Income',
    'Expenses',
    'Savings progress',
    'Assets and liabilities',
  };
  final Set<String> interferingVariables = {
    'Family obligations',
    'Debt due dates',
  };
  final List<MoneyItem> assets = [
    MoneyItem('Checking Account', 'Primary savings', 2400),
    MoneyItem('Investment Portfolio', 'Vanguard ETF', 12000),
  ];
  final List<MoneyItem> liabilities = [
    MoneyItem('Student Loan', 'Federal Direct', 18500),
    MoneyItem('Credit Card', 'Visa Gold', 850),
  ];
  final List<ChatMessage> messages = [
    ChatMessage(
      false,
      "I'm Shellby. If you could achieve one financial milestone in the next 12 months, what would it be?",
    ),
  ];

  bool get isSignedIn => uid != null;

  double get totalAssets => assets.fold(0, (sum, item) => sum + item.value);
  double get totalLiabilities =>
      liabilities.fold(0, (sum, item) => sum + item.value);
  double get netWorth => totalAssets - totalLiabilities + 24500.40;
  double get monthlySurplus =>
      income - expenses - variableExpenses - debtPayments;
  double get savingsRate =>
      income <= 0 ? 0 : (savings / income * 100).clamp(0, 100);
  double get debtToIncome =>
      income <= 0 ? 0 : (debtPayments / income * 100).clamp(0, 100);
  double get requiredMonthlyContribution {
    if (selectedGoalMonthlyTarget > 0) return selectedGoalMonthlyTarget;
    if (selectedGoal == 'Debt Payoff Map') {
      return math.max(400, debtPayments * .8);
    }
    if (selectedGoal == 'Starter Investing Habit' ||
        selectedGoal == 'Net Worth Growth Plan') {
      return math.max(500, income * .12);
    }
    if (selectedGoal == 'Cash Flow Stability Plan' ||
        selectedGoal == 'Expense Tracking Routine' ||
        selectedGoal == 'Spending Trigger Tracker') {
      return 0;
    }
    return math.max(500, expenses / 6);
  }

  double get feasibilityScore {
    final surplusFit = monthlySurplus <= 0
        ? 20
        : (monthlySurplus / requiredMonthlyContribution * 65).clamp(10, 65);
    final confidenceFit = confidence * 2;
    final anxietyPenalty = anxiety * 1.2;
    return (surplusFit + confidenceFit + emergencyMonths * 4 - anxietyPenalty)
        .clamp(0, 100);
  }

  double get healthScore => (45 +
          savingsRate * .35 +
          emergencyMonths * 4 +
          confidence * 2.2 -
          anxiety * .9 -
          debtToIncome * .25 +
          (location == 'Urban' ? 2 : 4))
      .clamp(0, 100);

  Future<bool> restoreSignedInUser() async {
    final user = FirebaseProfileService.currentUser;
    if (user == null) return false;
    _applyFirebaseUser(user);
    final profile = await FirebaseProfileService.loadProfile(user.uid);
    if (profile == null || profile['onboardingComplete'] != true) {
      await signOut();
      return false;
    }
    _applyProfileMap(profile);
    notifyListeners();
    return true;
  }

  Future<void> signInWithGoogle({
    bool requireCompletedProfile = false,
    bool saveAfterSignIn = true,
    bool forceFreshGoogleSession = false,
  }) async {
    final credential = await FirebaseProfileService.signInWithGoogle(
      forceFreshSession: forceFreshGoogleSession,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Google sign-in completed without a Firebase user.',
      );
    }
    _applyFirebaseUser(user);
    final profile = await FirebaseProfileService.loadProfile(user.uid);
    if (requireCompletedProfile &&
        (profile == null || profile['onboardingComplete'] != true)) {
      await signOut();
      throw FirebaseAuthException(
        code: 'incomplete-onboarding',
        message:
            'This account has not finished onboarding yet. Please create the account again and complete onboarding first.',
      );
    }
    if (profile != null) {
      _applyProfileMap(profile);
    }
    if (saveAfterSignIn) {
      await saveProfile();
    }
    notifyListeners();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseProfileService.signInWithEmail(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Sign-in completed without a Firebase user.',
      );
    }
    _applyFirebaseUser(user);
    final profile = await FirebaseProfileService.loadProfile(user.uid);
    if (profile == null || profile['onboardingComplete'] != true) {
      await signOut();
      throw FirebaseAuthException(
        code: 'incomplete-onboarding',
        message:
            'This account has not finished onboarding yet. Please create the account again and complete onboarding first.',
      );
    }
    _applyProfileMap(profile);
    notifyListeners();
  }

  Future<void> createAccountWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseProfileService.createUserWithEmail(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Account creation completed without a Firebase user.',
      );
    }
    await user.updateDisplayName(name.trim().isEmpty ? null : name.trim());
    _applyFirebaseUser(user);
    await saveProfile();
    notifyListeners();
  }

  Future<void> saveProfile({bool markOnboardingComplete = false}) async {
    final user = FirebaseProfileService.currentUser;
    if (user == null) return;
    uid = user.uid;
    if (markOnboardingComplete) {
      onboardingComplete = true;
    }
    await FirebaseProfileService.saveProfile(
      user: user,
      profile: _profileMap(user),
    );
  }

  Future<void> signOut() async {
    await FirebaseProfileService.signOut();
    uid = null;
    photoUrl = null;
    onboardingComplete = false;
    notifyListeners();
  }

  void _applyFirebaseUser(User user) {
    uid = user.uid;
    if (name.trim().isEmpty && (user.displayName ?? '').trim().isNotEmpty) {
      name = user.displayName!.trim();
    }
    if (email.trim().isEmpty && (user.email ?? '').trim().isNotEmpty) {
      email = user.email!.trim();
    }
    photoUrl = user.photoURL;
  }

  Map<String, dynamic> _profileMap(User user) {
    return {
      'uid': user.uid,
      'onboardingComplete': onboardingComplete,
      'name': name.trim().isEmpty ? user.displayName ?? '' : name.trim(),
      'email': email.trim().isEmpty ? user.email ?? '' : email.trim(),
      'photoUrl': photoUrl ?? user.photoURL,
      'age': age,
      'occupation': occupation,
      'industry': industry,
      'employmentStatus': employmentStatus,
      'incomeType': incomeType,
      'incomeRhythm': incomeRhythm,
      'billsRhythm': billsRhythm,
      'checkInRhythm': checkInRhythm,
      'location': location,
      'responsibility': responsibility,
      'primaryConcern': primaryConcern,
      'motivation': motivation,
      'reflectedMotivation': reflectedMotivation,
      'chatSurfaceSummary': chatSurfaceSummary,
      'chatGoalFocusSummary': chatGoalFocusSummary,
      'chatTimeframeSummary': chatTimeframeSummary,
      'chatDifficultySummary': chatDifficultySummary,
      'chatSituationsSummary': chatSituationsSummary,
      'chatChallengesSummary': chatChallengesSummary,
      'selectedGoal': selectedGoal,
      'selectedGoalDescription': selectedGoalDescription,
      'selectedGoalMonthlyTarget': selectedGoalMonthlyTarget,
      'socialStructure': socialStructure,
      'confidence': confidence,
      'anxiety': anxiety,
      'avoidance': avoidance,
      'peerPressure': peerPressure,
      'income': income,
      'expenses': expenses,
      'variableExpenses': variableExpenses,
      'savings': savings,
      'emergencyMonths': emergencyMonths,
      'debtPayments': debtPayments,
      'investments': investments,
      'subscriptions': subscriptions,
      'consentBaseline': consentBaseline,
      'consentAi': consentAi,
      'consentBenchmarking': consentBenchmarking,
      'consentCommunity': consentCommunity,
      'consentTrustedCircle': consentTrustedCircle,
      'emotionalLogsEnabled': emotionalLogsEnabled,
      'stressIndicatorsEnabled': stressIndicatorsEnabled,
      'selectedActionIds': selectedActionIds.toList()..sort(),
      'trackingVariables': trackingVariables.toList()..sort(),
      'interferingVariables': interferingVariables.toList()..sort(),
      'assets': assets.map((item) => item.toMap()).toList(),
      'liabilities': liabilities.map((item) => item.toMap()).toList(),
      'healthScore': healthScore,
      'feasibilityScore': feasibilityScore,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  void _applyProfileMap(Map<String, dynamic> data) {
    uid = data['uid'] as String? ?? uid;
    onboardingComplete =
        data['onboardingComplete'] as bool? ?? onboardingComplete;
    name = data['name'] as String? ?? name;
    email = data['email'] as String? ?? email;
    photoUrl = data['photoUrl'] as String? ?? photoUrl;
    age = data['age'] as String? ?? age;
    occupation = data['occupation'] as String? ?? occupation;
    industry = data['industry'] as String? ?? industry;
    employmentStatus = data['employmentStatus'] as String? ?? employmentStatus;
    incomeType = data['incomeType'] as String? ?? incomeType;
    incomeRhythm = data['incomeRhythm'] as String? ?? incomeRhythm;
    billsRhythm = data['billsRhythm'] as String? ?? billsRhythm;
    checkInRhythm = data['checkInRhythm'] as String? ?? checkInRhythm;
    location = data['location'] as String? ?? location;
    responsibility = data['responsibility'] as String? ?? responsibility;
    primaryConcern = data['primaryConcern'] as String? ?? primaryConcern;
    motivation = data['motivation'] as String? ?? motivation;
    reflectedMotivation =
        data['reflectedMotivation'] as String? ?? reflectedMotivation;
    chatSurfaceSummary =
        data['chatSurfaceSummary'] as String? ?? chatSurfaceSummary;
    chatGoalFocusSummary =
        data['chatGoalFocusSummary'] as String? ?? chatGoalFocusSummary;
    chatTimeframeSummary =
        data['chatTimeframeSummary'] as String? ?? chatTimeframeSummary;
    chatDifficultySummary =
        data['chatDifficultySummary'] as String? ?? chatDifficultySummary;
    chatSituationsSummary =
        data['chatSituationsSummary'] as String? ?? chatSituationsSummary;
    chatChallengesSummary =
        data['chatChallengesSummary'] as String? ?? chatChallengesSummary;
    selectedGoal = data['selectedGoal'] as String? ?? selectedGoal;
    selectedGoalDescription =
        data['selectedGoalDescription'] as String? ?? selectedGoalDescription;
    selectedGoalMonthlyTarget = _doubleFrom(
        data['selectedGoalMonthlyTarget'], selectedGoalMonthlyTarget);
    socialStructure = data['socialStructure'] as String? ?? socialStructure;
    confidence = _doubleFrom(data['confidence'], confidence);
    anxiety = _doubleFrom(data['anxiety'], anxiety);
    avoidance = _doubleFrom(data['avoidance'], avoidance);
    peerPressure = _doubleFrom(data['peerPressure'], peerPressure);
    income = _doubleFrom(data['income'], income);
    expenses = _doubleFrom(data['expenses'], expenses);
    variableExpenses = _doubleFrom(data['variableExpenses'], variableExpenses);
    savings = _doubleFrom(data['savings'], savings);
    emergencyMonths = _doubleFrom(data['emergencyMonths'], emergencyMonths);
    debtPayments = _doubleFrom(data['debtPayments'], debtPayments);
    investments = _doubleFrom(data['investments'], investments);
    subscriptions = _doubleFrom(data['subscriptions'], subscriptions);
    consentBaseline = data['consentBaseline'] as bool? ?? consentBaseline;
    consentAi = data['consentAi'] as bool? ?? consentAi;
    consentBenchmarking =
        data['consentBenchmarking'] as bool? ?? consentBenchmarking;
    consentCommunity = data['consentCommunity'] as bool? ?? consentCommunity;
    consentTrustedCircle =
        data['consentTrustedCircle'] as bool? ?? consentTrustedCircle;
    emotionalLogsEnabled =
        data['emotionalLogsEnabled'] as bool? ?? emotionalLogsEnabled;
    stressIndicatorsEnabled =
        data['stressIndicatorsEnabled'] as bool? ?? stressIndicatorsEnabled;
    _replaceSet(selectedActionIds, data['selectedActionIds']);
    _replaceSet(trackingVariables, data['trackingVariables']);
    _replaceSet(interferingVariables, data['interferingVariables']);
    _replaceMoneyItems(assets, data['assets']);
    _replaceMoneyItems(liabilities, data['liabilities']);
  }

  double _doubleFrom(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  void _replaceSet(Set<String> target, Object? value) {
    if (value is! Iterable) return;
    target
      ..clear()
      ..addAll(value.whereType<String>());
  }

  void _replaceMoneyItems(List<MoneyItem> target, Object? value) {
    if (value is! Iterable) return;
    target
      ..clear()
      ..addAll(
        value.whereType<Map>().map(
              (item) => MoneyItem.fromMap(Map<String, dynamic>.from(item)),
            ),
      );
  }

  void updateConfidence(double value) {
    confidence = value;
    notifyListeners();
  }

  void updateAnxiety(double value) {
    anxiety = value;
    notifyListeners();
  }

  void updateAvoidance(double value) {
    avoidance = value;
    notifyListeners();
  }

  void updatePeerPressure(double value) {
    peerPressure = value;
    notifyListeners();
  }

  void setMotivation(String value) {
    motivation = value.trim();
    reflectedMotivation = motivation.isEmpty
        ? 'You want a clearer financial plan that feels realistic for your life.'
        : motivation;
    notifyListeners();
  }

  void setGuidedChatSummary({
    required String surface,
    required String goalFocus,
    required String timeframe,
    required String difficulty,
    required String situations,
    required String challenges,
  }) {
    chatSurfaceSummary = surface.trim();
    chatGoalFocusSummary = goalFocus.trim();
    chatTimeframeSummary = timeframe.trim();
    chatDifficultySummary = difficulty.trim();
    chatSituationsSummary = situations.trim();
    chatChallengesSummary = challenges.trim();
    notifyListeners();
  }

  void resetGuidedPathDetails() {
    motivation = '';
    reflectedMotivation = '';
    chatSurfaceSummary = '';
    chatGoalFocusSummary = '';
    chatTimeframeSummary = '';
    chatDifficultySummary = '';
    chatSituationsSummary = '';
    chatChallengesSummary = '';
    final branch = _branchForLayer(primaryConcern);
    selectedGoal = branch.defaultGoalTitle;
    selectedGoalDescription = branch.defaultGoalDescription;
    selectedGoalMonthlyTarget = 0;
    selectedActionIds
      ..clear()
      ..add('ACT1');
    emotionalLogsEnabled = false;
    stressIndicatorsEnabled = false;
    consentAi = false;
    consentTrustedCircle = false;
    if (socialStructure == 'Collaborative goal') {
      socialStructure = 'Private only';
    }
    notifyListeners();
  }

  void setRecommendedGoal({
    required String title,
    required String description,
    required double monthlyTarget,
  }) {
    selectedGoal = title;
    selectedGoalDescription = description;
    selectedGoalMonthlyTarget = monthlyTarget;
    notifyListeners();
  }

  void choosePresetGoal(String title, String description) {
    selectedGoal = title;
    selectedGoalDescription = description;
    selectedGoalMonthlyTarget = 0;
    notifyListeners();
  }

  void configureGoalActions({
    required Iterable<String> actionIds,
    bool enableEmotionalLogs = false,
    bool enableStressIndicators = false,
  }) {
    selectedActionIds
      ..clear()
      ..add('ACT1')
      ..addAll(actionIds);
    emotionalLogsEnabled = enableEmotionalLogs;
    stressIndicatorsEnabled = enableStressIndicators;
    consentAi = selectedActionIds.contains('ACT5');
    consentTrustedCircle = selectedActionIds.contains('ACT4');
    if (selectedActionIds.contains('ACT4')) {
      socialStructure = 'Collaborative goal';
    } else if (socialStructure == 'Collaborative goal') {
      socialStructure = 'Private only';
    }
    notifyListeners();
  }

  void toggleTrackingVariable(String value) {
    if (trackingVariables.contains(value)) {
      trackingVariables.remove(value);
    } else {
      trackingVariables.add(value);
    }
    notifyListeners();
  }

  void toggleInterferingVariable(String value) {
    if (interferingVariables.contains(value)) {
      interferingVariables.remove(value);
    } else {
      interferingVariables.add(value);
    }
    notifyListeners();
  }

  void sendDiscoveryMessage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    messages.add(ChatMessage(true, trimmed));
    messages.add(
      const ChatMessage(
        false,
        "That's a powerful vision. Is this primarily about creating a long-term safety net, or fueling significant growth right now?",
      ),
    );
    notifyListeners();
  }

  void addAsset() {
    assets.add(MoneyItem('New Asset', 'Tap to refine later', 0));
    notifyListeners();
  }

  void addLiability() {
    liabilities.add(MoneyItem('New Liability', 'Tap to refine later', 0));
    notifyListeners();
  }

  void addMoneyItem(MoneyItem item, {required bool isLiability}) {
    if (isLiability) {
      liabilities.add(item);
    } else {
      assets.add(item);
    }
    notifyListeners();
  }

  void updateMoneyItem(
    MoneyItem item, {
    required String name,
    required String description,
    required double value,
  }) {
    item.name = name.trim().isEmpty ? 'Untitled' : name.trim();
    item.description =
        description.trim().isEmpty ? 'No description yet' : description.trim();
    item.value = value;
    notifyListeners();
  }

  void removeAsset(MoneyItem item) {
    assets.remove(item);
    notifyListeners();
  }

  void removeLiability(MoneyItem item) {
    liabilities.remove(item);
    notifyListeners();
  }
}

class MoneyItem {
  MoneyItem(this.name, this.description, this.value);

  String name;
  String description;
  double value;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'value': value,
    };
  }

  factory MoneyItem.fromMap(Map<String, dynamic> data) {
    final rawValue = data['value'];
    return MoneyItem(
      data['name'] as String? ?? 'Untitled',
      data['description'] as String? ?? 'No description yet',
      rawValue is num ? rawValue.toDouble() : 0,
    );
  }
}

class ChatMessage {
  const ChatMessage(this.fromUser, this.text);

  final bool fromUser;
  final String text;
}

class MotivationCoachResult {
  const MotivationCoachResult({
    required this.reply,
    required this.conclusion,
    required this.isComplete,
  });

  final String reply;
  final String conclusion;
  final bool isComplete;
}

class GoalCoachResult {
  const GoalCoachResult({
    required this.reply,
    required this.title,
    required this.description,
    required this.monthlyTarget,
  });

  final String reply;
  final String title;
  final String description;
  final double monthlyTarget;
}
