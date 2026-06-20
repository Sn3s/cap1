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
  double monthlySalary = 0;
  int salaryWeekOfMonth = 1;
  int salaryWeekday = DateTime.friday;
  bool consentBaseline = true;
  bool consentAi = true;
  bool consentBenchmarking = false;
  bool consentCommunity = false;
  bool consentTrustedCircle = false;
  bool notificationsAllowed = false;
  bool thirdPartyDataLinkingAllowed = false;
  bool automaticDataGatheringAllowed = false;
  bool personalDataConsent = false;
  bool dataRetentionConsent = false;
  bool emotionalLogsEnabled = false;
  bool stressIndicatorsEnabled = false;
  FakeMayaLink? fakeMayaLink;
  final Map<String, TransactionLabelRule> transactionLabelRules = {};
  final Map<String, String> planAdjustmentActions = {};
  final Map<String, double> anxietyCheckIns = {};
  double allocatedThisCycle = 0;
  final Map<String, CollectionBucketOverride> goalBucketOverrides = {};
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
  bool get hasFakeMayaLink => fakeMayaLink != null;
  double get linkedFakeMayaBalance => fakeMayaLink?.summary.totalBalance ?? 0;

  double get totalAssets => assets.fold(0, (sum, item) => sum + item.value);
  double get totalLiabilities =>
      liabilities.fold(0, (sum, item) => sum + item.value);
  double get netWorth => totalAssets - totalLiabilities + 24500.40;
  double get monthlySurplus =>
      income - expenses - variableExpenses - debtPayments;
  String get currentAnxietyWeekKey {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-'
        '${monday.day.toString().padLeft(2, '0')}';
  }

  bool get hasCurrentWeekAnxietyCheckIn =>
      anxietyCheckIns.containsKey(currentAnxietyWeekKey);
  double get savingsRate =>
      income <= 0 ? 0 : (savings / income * 100).clamp(0, 100);
  double get debtToIncome =>
      income <= 0 ? 0 : (debtPayments / income * 100).clamp(0, 100);
  double get requiredMonthlyContribution {
    if (monthlySalary > 0) return monthlySalary * .10;
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
    fakeMayaLink = null;
    _removeFakeMayaMoneyItems();
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
      'notificationsAllowed': notificationsAllowed,
      'thirdPartyDataLinkingAllowed': thirdPartyDataLinkingAllowed,
      'automaticDataGatheringAllowed': automaticDataGatheringAllowed,
      'personalDataConsent': personalDataConsent,
      'dataRetentionConsent': dataRetentionConsent,
      'emotionalLogsEnabled': emotionalLogsEnabled,
      'stressIndicatorsEnabled': stressIndicatorsEnabled,
      'monthlySalary': monthlySalary,
      'salaryWeekOfMonth': salaryWeekOfMonth,
      'salaryWeekday': salaryWeekday,
      'fakeMayaLink': fakeMayaLink?.toMap(),
      'transactionLabelRules': transactionLabelRules.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'planAdjustmentActions': planAdjustmentActions,
      'anxietyCheckIns': anxietyCheckIns,
      'allocatedThisCycle': allocatedThisCycle,
      'goalBucketOverrides':
          goalBucketOverrides.map((key, value) => MapEntry(key, value.toMap())),
      'selectedActionIds': selectedActionIds.toList()..sort(),
      'onboardingSelections': _onboardingSelectionsMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _onboardingSelectionsMap() {
    return {
      'profileContext': {
        'age': age,
        'occupation': occupation,
        'industry': industry,
      },
      'moneyRhythm': {
        'employmentStatus': employmentStatus,
        'incomeType': incomeType,
        'incomeRhythm': incomeRhythm,
        'billsRhythm': billsRhythm,
        'responsibility': responsibility,
        'checkInRhythm': checkInRhythm,
      },
      'conversationChoices': {
        'primaryConcern': primaryConcern,
        'motivation': motivation,
        'reflectedMotivation': reflectedMotivation,
        'surface': chatSurfaceSummary,
        'goalFocus': chatGoalFocusSummary,
        'timeframe': chatTimeframeSummary,
        'difficulty': chatDifficultySummary,
        'situations': chatSituationsSummary,
        'challenges': chatChallengesSummary,
      },
      'planSetup': {
        'selectedGoal': selectedGoal,
        'selectedGoalDescription': selectedGoalDescription,
        'selectedGoalMonthlyTarget': selectedGoalMonthlyTarget,
        'selectedActionIds': selectedActionIds.toList()..sort(),
        'emotionalLogsEnabled': emotionalLogsEnabled,
        'stressIndicatorsEnabled': stressIndicatorsEnabled,
      },
      'permissionsAndConsent': {
        'notificationsAllowed': notificationsAllowed,
        'thirdPartyDataLinkingAllowed': thirdPartyDataLinkingAllowed,
        'automaticDataGatheringAllowed': automaticDataGatheringAllowed,
        'personalDataConsent': personalDataConsent,
        'dataRetentionConsent': dataRetentionConsent,
      },
    };
  }

  void _applyProfileMap(Map<String, dynamic> data) {
    final onboardingSelections =
        _mapFrom(data['onboardingSelections']) ?? const <String, dynamic>{};
    final profileContext = _mapFrom(onboardingSelections['profileContext']) ??
        const <String, dynamic>{};
    final moneyRhythm = _mapFrom(onboardingSelections['moneyRhythm']) ??
        const <String, dynamic>{};
    final conversationChoices =
        _mapFrom(onboardingSelections['conversationChoices']) ??
            const <String, dynamic>{};
    final planSetup = _mapFrom(onboardingSelections['planSetup']) ??
        const <String, dynamic>{};
    final permissionsAndConsent =
        _mapFrom(onboardingSelections['permissionsAndConsent']) ??
            const <String, dynamic>{};
    uid = data['uid'] as String? ?? uid;
    onboardingComplete =
        data['onboardingComplete'] as bool? ?? onboardingComplete;
    name = data['name'] as String? ?? name;
    email = data['email'] as String? ?? email;
    photoUrl = data['photoUrl'] as String? ?? photoUrl;
    age = data['age'] as String? ?? profileContext['age'] as String? ?? age;
    occupation = data['occupation'] as String? ??
        profileContext['occupation'] as String? ??
        occupation;
    industry = data['industry'] as String? ??
        profileContext['industry'] as String? ??
        industry;
    employmentStatus = data['employmentStatus'] as String? ??
        moneyRhythm['employmentStatus'] as String? ??
        employmentStatus;
    incomeType = data['incomeType'] as String? ??
        moneyRhythm['incomeType'] as String? ??
        incomeType;
    incomeRhythm = data['incomeRhythm'] as String? ??
        moneyRhythm['incomeRhythm'] as String? ??
        incomeRhythm;
    billsRhythm = data['billsRhythm'] as String? ??
        moneyRhythm['billsRhythm'] as String? ??
        billsRhythm;
    checkInRhythm = data['checkInRhythm'] as String? ??
        moneyRhythm['checkInRhythm'] as String? ??
        checkInRhythm;
    responsibility = data['responsibility'] as String? ??
        moneyRhythm['responsibility'] as String? ??
        responsibility;
    primaryConcern = data['primaryConcern'] as String? ??
        conversationChoices['primaryConcern'] as String? ??
        primaryConcern;
    motivation = data['motivation'] as String? ??
        conversationChoices['motivation'] as String? ??
        motivation;
    reflectedMotivation = data['reflectedMotivation'] as String? ??
        conversationChoices['reflectedMotivation'] as String? ??
        reflectedMotivation;
    chatSurfaceSummary = data['chatSurfaceSummary'] as String? ??
        conversationChoices['surface'] as String? ??
        chatSurfaceSummary;
    chatGoalFocusSummary = data['chatGoalFocusSummary'] as String? ??
        conversationChoices['goalFocus'] as String? ??
        chatGoalFocusSummary;
    chatTimeframeSummary = data['chatTimeframeSummary'] as String? ??
        conversationChoices['timeframe'] as String? ??
        chatTimeframeSummary;
    chatDifficultySummary = data['chatDifficultySummary'] as String? ??
        conversationChoices['difficulty'] as String? ??
        chatDifficultySummary;
    chatSituationsSummary = data['chatSituationsSummary'] as String? ??
        conversationChoices['situations'] as String? ??
        chatSituationsSummary;
    chatChallengesSummary = data['chatChallengesSummary'] as String? ??
        conversationChoices['challenges'] as String? ??
        chatChallengesSummary;
    selectedGoal = data['selectedGoal'] as String? ??
        planSetup['selectedGoal'] as String? ??
        selectedGoal;
    selectedGoalDescription = data['selectedGoalDescription'] as String? ??
        planSetup['selectedGoalDescription'] as String? ??
        selectedGoalDescription;
    selectedGoalMonthlyTarget = _doubleFrom(
      data['selectedGoalMonthlyTarget'] ??
          planSetup['selectedGoalMonthlyTarget'],
      selectedGoalMonthlyTarget,
    );
    notificationsAllowed = data['notificationsAllowed'] as bool? ??
        permissionsAndConsent['notificationsAllowed'] as bool? ??
        notificationsAllowed;
    thirdPartyDataLinkingAllowed =
        data['thirdPartyDataLinkingAllowed'] as bool? ??
            permissionsAndConsent['thirdPartyDataLinkingAllowed'] as bool? ??
            thirdPartyDataLinkingAllowed;
    automaticDataGatheringAllowed =
        data['automaticDataGatheringAllowed'] as bool? ??
            permissionsAndConsent['automaticDataGatheringAllowed'] as bool? ??
            automaticDataGatheringAllowed;
    personalDataConsent = data['personalDataConsent'] as bool? ??
        permissionsAndConsent['personalDataConsent'] as bool? ??
        personalDataConsent;
    dataRetentionConsent = data['dataRetentionConsent'] as bool? ??
        permissionsAndConsent['dataRetentionConsent'] as bool? ??
        dataRetentionConsent;
    emotionalLogsEnabled = data['emotionalLogsEnabled'] as bool? ??
        planSetup['emotionalLogsEnabled'] as bool? ??
        emotionalLogsEnabled;
    stressIndicatorsEnabled = data['stressIndicatorsEnabled'] as bool? ??
        planSetup['stressIndicatorsEnabled'] as bool? ??
        stressIndicatorsEnabled;
    monthlySalary = _doubleFrom(data['monthlySalary'], monthlySalary);
    salaryWeekOfMonth =
        (data['salaryWeekOfMonth'] as num?)?.toInt() ?? salaryWeekOfMonth;
    salaryWeekday = (data['salaryWeekday'] as num?)?.toInt() ?? salaryWeekday;
    final fakeMayaData = _mapFrom(data['fakeMayaLink']);
    fakeMayaLink =
        fakeMayaData == null ? null : FakeMayaLink.fromMap(fakeMayaData);
    final labelRuleData = _mapFrom(data['transactionLabelRules']);
    transactionLabelRules.clear();
    if (labelRuleData != null) {
      for (final entry in labelRuleData.entries) {
        final value = _mapFrom(entry.value);
        if (value != null) {
          transactionLabelRules[entry.key] =
              TransactionLabelRule.fromMap(value);
        }
      }
    }
    final adjustmentData = _mapFrom(data['planAdjustmentActions']);
    planAdjustmentActions
      ..clear()
      ..addAll(
        adjustmentData?.map(
              (key, value) => MapEntry(key, value?.toString() ?? ''),
            ) ??
            const {},
      );
    final anxietyData = _mapFrom(data['anxietyCheckIns']);
    anxietyCheckIns
      ..clear()
      ..addAll(
        anxietyData?.map(
              (key, value) => MapEntry(key, _doubleFrom(value, 0)),
            ) ??
            const {},
      );
    for (final transaction
        in fakeMayaLink?.summary.transactions ?? <FakeMayaTransaction>[]) {
      if (transaction.isLabeled && !transaction.excludedFromInsights) {
        transactionLabelRules.putIfAbsent(
          transaction.patternKey,
          () => TransactionLabelRule.fromTransaction(transaction),
        );
      }
    }
    _syncFakeMayaMoneyItems();
    allocatedThisCycle = _doubleFrom(
      data['allocatedThisCycle'],
      allocatedThisCycle,
    );
    final bucketData = _mapFrom(data['goalBucketOverrides']);
    if (bucketData != null) {
      goalBucketOverrides
        ..clear()
        ..addEntries(
          bucketData.entries.map(
            (entry) => MapEntry(
              entry.key,
              CollectionBucketOverride.fromMap(
                _mapFrom(entry.value) ?? const <String, dynamic>{},
              ),
            ),
          ),
        );
    }
    _replaceSet(
      selectedActionIds,
      data['selectedActionIds'] ?? planSetup['selectedActionIds'],
    );
  }

  double _doubleFrom(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Map<String, dynamic>? _mapFrom(Object? value) {
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  void _replaceSet(Set<String> target, Object? value) {
    if (value is! Iterable) return;
    target
      ..clear()
      ..addAll(value.whereType<String>());
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

  void updateGuidedChatSummary({
    String? surface,
    String? goalFocus,
    String? timeframe,
    String? difficulty,
    String? situations,
    String? challenges,
  }) {
    if (surface != null) chatSurfaceSummary = surface.trim();
    if (goalFocus != null) chatGoalFocusSummary = goalFocus.trim();
    if (timeframe != null) chatTimeframeSummary = timeframe.trim();
    if (difficulty != null) chatDifficultySummary = difficulty.trim();
    if (situations != null) chatSituationsSummary = situations.trim();
    if (challenges != null) chatChallengesSummary = challenges.trim();
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

  void acceptAppPermissions({required bool notificationGranted}) {
    notificationsAllowed = notificationGranted;
    thirdPartyDataLinkingAllowed = true;
    automaticDataGatheringAllowed = true;
    notifyListeners();
  }

  void acceptPersonalDataConsent() {
    personalDataConsent = true;
    consentBaseline = true;
    notifyListeners();
  }

  void acceptDataRetentionConsent() {
    dataRetentionConsent = true;
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

  void setMonthlySalarySchedule({
    required double amount,
    required int weekOfMonth,
    required int weekday,
  }) {
    monthlySalary = amount;
    salaryWeekOfMonth = weekOfMonth.clamp(1, 4);
    salaryWeekday = weekday.clamp(DateTime.monday, DateTime.sunday);
    notifyListeners();
  }

  void updateGoalBucketOverride(CollectionBucketOverride bucket) {
    goalBucketOverrides[bucket.id] = bucket;
    notifyListeners();
  }

  void recordPlanAdjustment({
    required String transactionId,
    required String action,
  }) {
    planAdjustmentActions[transactionId] = action;
    notifyListeners();
  }

  void recordWeeklyAnxietyCheckIn(double value) {
    anxietyCheckIns[currentAnxietyWeekKey] = value.clamp(1, 5).toDouble();
    notifyListeners();
  }

  Future<void> allocateToGoalBucket({
    required CollectionBucketOverride bucket,
    required double amount,
  }) async {
    if (amount <= 0) return;
    final linkedAccount = switch (bucket.id) {
      'fakemaya-savings' => FakeMayaGoalAccount.savings,
      'fakemaya-time-deposit' => FakeMayaGoalAccount.timeDeposit,
      'fakemaya-personal-goal' => FakeMayaGoalAccount.personalGoal,
      _ => null,
    };
    if (linkedAccount != null && fakeMayaLink != null) {
      final session = await FakeMayaService.allocateFromWallet(
        link: fakeMayaLink!,
        amount: amount,
        account: linkedAccount,
      );
      fakeMayaLink = FakeMayaLink.fromSession(session);
      _syncFakeMayaMoneyItems();
    } else {
      goalBucketOverrides[bucket.id] = bucket.copyWith(
        current: bucket.current + amount,
      );
    }
    allocatedThisCycle += amount;
    await saveProfile();
    notifyListeners();
  }

  Future<void> linkFakeMayaAccount({
    required String email,
    required String password,
  }) async {
    final session = await FakeMayaService.signInWithEmail(
      email: email,
      password: password,
    );
    fakeMayaLink = FakeMayaLink.fromSession(session);
    thirdPartyDataLinkingAllowed = true;
    automaticDataGatheringAllowed = true;
    _syncFakeMayaMoneyItems();
    await saveProfile();
    notifyListeners();
  }

  Future<void> refreshFakeMayaAccount() async {
    final link = fakeMayaLink;
    if (link == null) return;
    final session = await FakeMayaService.refreshSession(link);
    final savedById = {
      for (final transaction in link.summary.transactions)
        transaction.transactionId: transaction,
    };
    final mergedTransactions = session.summary.transactions.map((transaction) {
      final saved = savedById[transaction.transactionId];
      if (saved != null && saved.isLabeled) {
        return transaction.withLabelFrom(saved);
      }
      final rule = transactionLabelRules[transaction.patternKey];
      return rule == null ? transaction : rule.applyTo(transaction);
    }).toList();
    fakeMayaLink = FakeMayaLink(
      userId: session.userId,
      email: session.email,
      name: session.name,
      phone: session.phone,
      provider: session.provider,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      summary: session.summary.copyWith(transactions: mergedTransactions),
    );
    _syncFakeMayaMoneyItems();
    await saveProfile();
    notifyListeners();
  }

  Future<void> labelFakeMayaTransaction({
    required String transactionId,
    required String category,
    String? subcategory,
    String? tag,
    String? note,
    bool excludedFromInsights = false,
  }) async {
    final link = fakeMayaLink;
    if (link == null) return;
    final target = link.summary.transactions
        .where((transaction) => transaction.transactionId == transactionId)
        .firstOrNull;
    if (target == null) return;
    final labeledTarget = target.copyWithLabel(
      category: category,
      subcategory: subcategory,
      tag: tag,
      note: note,
      excludedFromInsights: excludedFromInsights,
    );
    final rule = TransactionLabelRule.fromTransaction(labeledTarget);
    if (excludedFromInsights) {
      transactionLabelRules.remove(target.patternKey);
    } else {
      transactionLabelRules[target.patternKey] = rule;
    }
    final transactions = link.summary.transactions.map((transaction) {
      if (transaction.transactionId == transactionId) return labeledTarget;
      if (!excludedFromInsights &&
          !transaction.isLabeled &&
          transaction.patternKey == target.patternKey) {
        return rule.applyTo(transaction);
      }
      return transaction;
    }).toList();
    fakeMayaLink = FakeMayaLink(
      userId: link.userId,
      email: link.email,
      name: link.name,
      phone: link.phone,
      provider: link.provider,
      accessToken: link.accessToken,
      refreshToken: link.refreshToken,
      expiresAt: link.expiresAt,
      summary: link.summary.copyWith(transactions: transactions),
    );
    await saveProfile();
    notifyListeners();
  }

  Future<void> unlinkFakeMayaAccount() async {
    fakeMayaLink = null;
    _removeFakeMayaMoneyItems();
    await saveProfile();
    notifyListeners();
  }

  void _syncFakeMayaMoneyItems() {
    _removeFakeMayaMoneyItems();
    final link = fakeMayaLink;
    if (link == null) return;
    assets.addAll(link.summary.toMoneyItems());
    savings = link.summary.savings +
        link.summary.timeDeposit +
        link.summary.goalBalance;
  }

  void _removeFakeMayaMoneyItems() {
    assets.removeWhere((item) => item.description == 'Linked from FakeMaya');
  }
}

class TransactionLabelRule {
  const TransactionLabelRule({
    required this.category,
    this.subcategory,
    this.tag,
    this.note,
  });

  final String category;
  final String? subcategory;
  final String? tag;
  final String? note;

  factory TransactionLabelRule.fromTransaction(
    FakeMayaTransaction transaction,
  ) {
    return TransactionLabelRule(
      category: transaction.category!,
      subcategory: transaction.subcategory,
      tag: transaction.tag,
    );
  }

  FakeMayaTransaction applyTo(FakeMayaTransaction transaction) {
    return transaction.copyWithLabel(
      category: category,
      subcategory: subcategory,
      tag: tag,
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category,
        'subcategory': subcategory,
        'tag': tag,
        'note': note,
      };

  factory TransactionLabelRule.fromMap(Map<String, dynamic> data) {
    return TransactionLabelRule(
      category: data['category'] as String? ?? 'Other expense',
      subcategory: data['subcategory'] as String?,
      tag: data['tag'] as String?,
      note: data['note'] as String?,
    );
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

class CollectionBucketOverride {
  const CollectionBucketOverride({
    required this.id,
    required this.name,
    required this.role,
    required this.emoji,
    required this.current,
    required this.target,
    required this.monthly,
  });

  final String id;
  final String name;
  final String role;
  final String emoji;
  final double current;
  final double target;
  final double monthly;

  CollectionBucketOverride copyWith({
    String? name,
    String? role,
    String? emoji,
    double? current,
    double? target,
    double? monthly,
  }) {
    return CollectionBucketOverride(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      emoji: emoji ?? this.emoji,
      current: current ?? this.current,
      target: target ?? this.target,
      monthly: monthly ?? this.monthly,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'emoji': emoji,
      'current': current,
      'target': target,
      'monthly': monthly,
    };
  }

  factory CollectionBucketOverride.fromMap(Map<String, dynamic> data) {
    return CollectionBucketOverride(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? 'Goal bucket',
      role: data['role'] as String? ?? 'Milestone bucket',
      emoji: data['emoji'] as String? ?? '🎯',
      current: _numberFrom(data['current'], 0),
      target: _numberFrom(data['target'], 0),
      monthly: _numberFrom(data['monthly'], 0),
    );
  }

  static double _numberFrom(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
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
