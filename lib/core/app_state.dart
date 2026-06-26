// CHANGELOG (two-jar system):
// - Added JarEvent, JarEventType, JarSource, JarSplitResult classes.
// - Added needsTarget, needsBalance, bufferBalance, needsPercent, jarLedger fields.
// - Added setupTwoJars, onIncomeEvent, onBillEvent, undoLastIncomeSplit, needsFull,
//   bufferMonthsCovered. Persisted via Firestore profile map.
// - Added withdrawFromSavings to FakeMayaService (emergency shortfall path).
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
  double income = 0;
  double expenses = 0;
  double variableExpenses = 0;
  double savings = 0;
  double emergencyMonths = 0;
  double debtPayments = 0;
  double investments = 0;
  double subscriptions = 0;
  double monthlySalary = 0;
  double irregularIncomeFloor = 0;
  double basicNeedsMonthlyTarget = 0;
  double basicNeedsAllocationPercent = 0.50;
  double bufferAllocationPercent = 0.20;
  // Two-jar system (Irregular Income Buffer)
  double needsTarget = 0;
  double needsBalance = 0;
  double bufferBalance = 0;
  int needsPercent = 70;
  final List<JarEvent> jarLedger = [];
  // Financial pyramid
  final List<CashFlowExpense> cashFlowExpenses = [];
  double financialSafetyBalance = 0;
  // Safety Shield goal
  double safetyShieldAllocationPercent = 0;
  int safetyShieldTargetMonths = 0;
  double shieldTrackedBalance = 0;
  final List<ShieldEvent> shieldLedger = [];
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
  final List<MoneyItem> assets = [];
  final List<MoneyItem> liabilities = [];
  final List<ChatMessage> messages = [
    ChatMessage(
      false,
      "I'm Shellby. If you could achieve one financial milestone in the next 12 months, what would it be?",
    ),
  ];

  bool get isSignedIn => uid != null;
  bool get hasFakeMayaLink => fakeMayaLink != null;
  bool get needsFull => needsTarget > 0 && needsBalance >= needsTarget;
  double get bufferMonthsCovered =>
      needsTarget <= 0 ? 0 : bufferBalance / needsTarget;
  bool get shieldIsSetup => safetyShieldTargetMonths > 0;
  double get safetyShieldMonthlyBase =>
      totalCashFlowBudget > 0
          ? totalCashFlowBudget
          : needsTarget > 0
              ? needsTarget
              : income > 0
                  ? income * 0.7
                  : 10000;
  double get safetyShieldBalance =>
      hasFakeMayaLink ? (fakeMayaLink!.summary.savings) : shieldTrackedBalance;
  double get safetyShieldTarget =>
      safetyShieldMonthlyBase * math.max(1, safetyShieldTargetMonths);
  double get safetyShieldMonthsCovered =>
      safetyShieldMonthlyBase <= 0 ? 0 : safetyShieldBalance / safetyShieldMonthlyBase;
  double get totalCashFlowBudget =>
      cashFlowExpenses.fold(0, (s, e) => s + e.budget);
  double get linkedFakeMayaBalance => fakeMayaLink?.summary.totalBalance ?? 0;

  double get totalAssets => assets.fold(0, (sum, item) => sum + item.value);
  double get totalLiabilities =>
      liabilities.fold(0, (sum, item) => sum + item.value);
  double get netWorth => totalAssets - totalLiabilities;
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
      'irregularIncomeFloor': irregularIncomeFloor,
      'basicNeedsMonthlyTarget': basicNeedsMonthlyTarget,
      'basicNeedsAllocationPercent': basicNeedsAllocationPercent,
      'bufferAllocationPercent': bufferAllocationPercent,
      'salaryWeekOfMonth': salaryWeekOfMonth,
      'salaryWeekday': salaryWeekday,
      'needsTarget': needsTarget,
      'needsBalance': needsBalance,
      'bufferBalance': bufferBalance,
      'needsPercent': needsPercent,
      'jarLedger': jarLedger.map((e) => e.toMap()).toList(),
      'cashFlowExpenses': cashFlowExpenses.map((e) => e.toMap()).toList(),
      'financialSafetyBalance': financialSafetyBalance,
      'safetyShieldAllocationPercent': safetyShieldAllocationPercent,
      'safetyShieldTargetMonths': safetyShieldTargetMonths,
      'shieldTrackedBalance': shieldTrackedBalance,
      'shieldLedger': shieldLedger.map((e) => e.toMap()).toList(),
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
        'irregularIncomeFloor': irregularIncomeFloor,
        'basicNeedsMonthlyTarget': basicNeedsMonthlyTarget,
        'basicNeedsAllocationPercent': basicNeedsAllocationPercent,
        'bufferAllocationPercent': bufferAllocationPercent,
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
    irregularIncomeFloor = _doubleFrom(
      data['irregularIncomeFloor'] ?? planSetup['irregularIncomeFloor'],
      irregularIncomeFloor,
    );
    basicNeedsMonthlyTarget = _doubleFrom(
      data['basicNeedsMonthlyTarget'] ?? planSetup['basicNeedsMonthlyTarget'],
      basicNeedsMonthlyTarget,
    );
    basicNeedsAllocationPercent = _doubleFrom(
      data['basicNeedsAllocationPercent'] ?? planSetup['basicNeedsAllocationPercent'],
      basicNeedsAllocationPercent,
    );
    bufferAllocationPercent = _doubleFrom(
      data['bufferAllocationPercent'] ?? planSetup['bufferAllocationPercent'],
      bufferAllocationPercent,
    );
    salaryWeekOfMonth =
        (data['salaryWeekOfMonth'] as num?)?.toInt() ?? salaryWeekOfMonth;
    salaryWeekday = (data['salaryWeekday'] as num?)?.toInt() ?? salaryWeekday;
    needsTarget = _doubleFrom(data['needsTarget'], needsTarget);
    needsBalance = _doubleFrom(data['needsBalance'], needsBalance);
    bufferBalance = _doubleFrom(data['bufferBalance'], bufferBalance);
    needsPercent = (data['needsPercent'] as num?)?.toInt() ?? needsPercent;
    final jarData = data['jarLedger'];
    if (jarData is List) {
      jarLedger
        ..clear()
        ..addAll(
          jarData
              .whereType<Map>()
              .map((item) => JarEvent.fromMap(
                    Map<String, dynamic>.from(item),
                  )),
        );
    }
    final expensesData = data['cashFlowExpenses'];
    if (expensesData is List) {
      cashFlowExpenses
        ..clear()
        ..addAll(expensesData
            .whereType<Map>()
            .map((m) => CashFlowExpense.fromMap(Map<String, dynamic>.from(m))));
    }
    financialSafetyBalance =
        _doubleFrom(data['financialSafetyBalance'], financialSafetyBalance);
    safetyShieldAllocationPercent = _doubleFrom(
        data['safetyShieldAllocationPercent'], safetyShieldAllocationPercent);
    safetyShieldTargetMonths =
        (data['safetyShieldTargetMonths'] as num?)?.toInt() ??
            safetyShieldTargetMonths;
    shieldTrackedBalance =
        _doubleFrom(data['shieldTrackedBalance'], shieldTrackedBalance);
    final shieldData = data['shieldLedger'];
    if (shieldData is List) {
      shieldLedger
        ..clear()
        ..addAll(shieldData
            .whereType<Map<String, dynamic>>()
            .map(ShieldEvent.fromMap));
    }
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

  void setIrregularIncomeFloor(double amount) {
    irregularIncomeFloor = math.max(0, amount);
    notifyListeners();
  }

  void setBasicNeedsConfig({
    required double monthlyTarget,
    required double needsPercent,
    required double bufferPercent,
  }) {
    basicNeedsMonthlyTarget = math.max(0, monthlyTarget);
    basicNeedsAllocationPercent = needsPercent.clamp(0.0, 1.0);
    bufferAllocationPercent = bufferPercent.clamp(0.0, 1.0);
    notifyListeners();
  }

  void recordWeeklyAnxietyCheckIn(double value) {
    anxietyCheckIns[currentAnxietyWeekKey] = value.clamp(1, 5).toDouble();
    notifyListeners();
  }

  Future<void> updateCashFlowExpenses(List<CashFlowExpense> expenses) async {
    cashFlowExpenses..clear()..addAll(expenses);
    notifyListeners();
    await saveProfile();
  }

  Future<void> updateFinancialSafetyBalance(double amount) async {
    financialSafetyBalance = math.max(0, amount);
    notifyListeners();
    await saveProfile();
  }

  Future<void> setupSafetyShield({
    required double allocationPercent,
    required int targetMonths,
  }) async {
    safetyShieldAllocationPercent = allocationPercent.clamp(0.0, 1.0);
    safetyShieldTargetMonths = targetMonths.clamp(1, 12);
    await saveProfile();
    notifyListeners();
  }

  Future<void> updateShieldConfig({
    required double allocationPercent,
    required int targetMonths,
  }) async {
    safetyShieldAllocationPercent = allocationPercent.clamp(0.0, 1.0);
    safetyShieldTargetMonths = targetMonths.clamp(1, 12);
    await saveProfile();
    notifyListeners();
  }

  Future<void> logShieldDeposit(double amount) async {
    if (amount <= 0) return;
    shieldTrackedBalance += amount;
    shieldLedger.insert(
      0,
      ShieldEvent(
        timestamp: DateTime.now(),
        amount: amount,
        sentence: '+${money(amount)} deposited to Safety Shield',
      ),
    );
    await saveProfile();
    notifyListeners();
  }

  // Moves money from FakeMaya wallet → savings for the emergency fund.
  // Falls back to manual tracking when FakeMaya is not linked.
  Future<void> allocateToSafetyShield(double amount) async {
    if (amount <= 0) return;
    final link = fakeMayaLink;
    if (link != null) {
      final session = await FakeMayaService.allocateFromWallet(
        link: link,
        amount: amount,
        account: FakeMayaGoalAccount.savings,
      );
      final savedById = {
        for (final t in link.summary.transactions) t.transactionId: t,
      };
      final merged = session.summary.transactions.map((t) {
        final saved = savedById[t.transactionId];
        return (saved != null && saved.isLabeled) ? t.withLabelFrom(saved) : t;
      }).toList();
      fakeMayaLink = FakeMayaLink.fromSession(FakeMayaSession(
        userId: session.userId,
        email: session.email,
        name: session.name,
        phone: session.phone,
        provider: session.provider,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresAt: session.expiresAt,
        summary: session.summary.copyWith(transactions: merged),
      ));
      _syncFakeMayaMoneyItems();
    }
    shieldLedger.insert(
      0,
      ShieldEvent(
        timestamp: DateTime.now(),
        amount: amount,
        sentence: link != null
            ? '+${money(amount)} moved wallet → Safety Shield savings'
            : '+${money(amount)} deposited to Safety Shield',
      ),
    );
    if (link == null) shieldTrackedBalance += amount;
    await saveProfile();
    notifyListeners();
  }

  Future<void> seedDemoCombinedGoals() async {
    // IIB setup — same as seedDemoTwoJarData but with Shield layered in.
    selectedGoal = 'Irregular Income Buffer';
    needsTarget = 12000;
    needsPercent = 70;

    // Safety Shield setup — 10% of income, target 3 months.
    safetyShieldAllocationPercent = 0.10;
    safetyShieldTargetMonths = 3;

    final now = DateTime.now();
    final lm = DateTime(now.year, now.month - 1);
    final cm = DateTime(now.year, now.month);

    // IIB jar events — same scenario as seedDemoTwoJarData, keeps buffer dip.
    final jarEvents = [
      JarEvent(timestamp: DateTime(lm.year, lm.month, 3),  type: JarEventType.income,   needsIn: 7000,  needsOut: 0,     bufferIn: 3000, bufferOut: 0,    sentence: '${money(10000)} in → ${money(7000)} Needs · ${money(3000)} Buffer · ${money(1000)} → Shield'),
      JarEvent(timestamp: DateTime(lm.year, lm.month, 10), type: JarEventType.income,   needsIn: 5000,  needsOut: 0,     bufferIn: 4000, bufferOut: 0,    sentence: '${money(9000)} in → ${money(5000)} Needs (full!) · ${money(4000)} Buffer · ${money(900)} → Shield'),
      JarEvent(timestamp: DateTime(lm.year, lm.month, 15), type: JarEventType.billPaid, needsIn: 0,     needsOut: 3500,  bufferIn: 0,    bufferOut: 0,    sentence: '${money(3500)} bill paid from Needs'),
      JarEvent(timestamp: DateTime(lm.year, lm.month, 22), type: JarEventType.income,   needsIn: 3500,  needsOut: 0,     bufferIn: 4500, bufferOut: 0,    sentence: '${money(8000)} in → ${money(3500)} Needs · ${money(4500)} Buffer · ${money(800)} → Shield'),
      JarEvent(timestamp: DateTime(lm.year, lm.month, 28), type: JarEventType.billPaid, needsIn: 0,     needsOut: 12000, bufferIn: 0,    bufferOut: 3000, sentence: '${money(15000)} bill → ${money(12000)} Needs + ${money(3000)} Buffer (tapped!)'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 2),  type: JarEventType.income,   needsIn: 8400,  needsOut: 0,     bufferIn: 3600, bufferOut: 0,    sentence: '${money(12000)} in → ${money(8400)} Needs · ${money(3600)} Buffer · ${money(1200)} → Shield'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 8),  type: JarEventType.income,   needsIn: 3600,  needsOut: 0,     bufferIn: 6400, bufferOut: 0,    sentence: '${money(10000)} in → ${money(3600)} Needs (full!) · ${money(6400)} Buffer · ${money(1000)} → Shield · Case 1'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 12), type: JarEventType.billPaid, needsIn: 0,     needsOut: 4500,  bufferIn: 0,    bufferOut: 0,    sentence: '${money(4500)} bill paid from Needs'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 18), type: JarEventType.billPaid, needsIn: 0,     needsOut: 7500,  bufferIn: 0,    bufferOut: 9000, sentence: '${money(16500)} emergency bill → Needs + Buffer tapped (₱9K from Buffer)'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 22), type: JarEventType.income,   needsIn: 6300,  needsOut: 0,     bufferIn: 2700, bufferOut: 0,    sentence: '${money(9000)} in → ${money(6300)} Needs · ${money(2700)} Buffer · ${money(900)} → Shield'),
    ];

    needsBalance = 0;
    bufferBalance = 0;
    for (final e in jarEvents) {
      needsBalance = math.min(math.max(0, needsBalance + e.needsIn - e.needsOut), needsTarget);
      bufferBalance = math.max(0, bufferBalance + e.bufferIn - e.bufferOut);
    }
    jarLedger..clear()..addAll(jarEvents.reversed);

    // Shield — partially funded at ~4,700 (< 1 month of 12K target).
    // Shows cross-alert: buffer was tapped AND shield is low.
    shieldTrackedBalance = 4700;
    shieldLedger
      ..clear()
      ..addAll([
        ShieldEvent(timestamp: DateTime(lm.year, lm.month, 5),  amount: 1000, sentence: '+${money(1000)} deposited to Safety Shield'),
        ShieldEvent(timestamp: DateTime(lm.year, lm.month, 12), amount: 900,  sentence: '+${money(900)} deposited to Safety Shield'),
        ShieldEvent(timestamp: DateTime(lm.year, lm.month, 25), amount: 800,  sentence: '+${money(800)} deposited to Safety Shield'),
        ShieldEvent(timestamp: DateTime(cm.year, cm.month, 4),  amount: 1200, sentence: '+${money(1200)} deposited to Safety Shield'),
        ShieldEvent(timestamp: DateTime(cm.year, cm.month, 10), amount: 800,  sentence: '+${money(800)} deposited to Safety Shield'),
      ]);

    await saveProfile();
    notifyListeners();
  }

  Future<void> setupTwoJars({
    required double needsTarget,
    required int needsPercent,
  }) async {
    this.needsTarget = math.max(0, needsTarget);
    this.needsPercent = needsPercent.clamp(0, 100);
    needsBalance = 0;
    bufferBalance = 0;
    jarLedger.clear();
    await saveProfile();
    notifyListeners();
  }

  // Updates config without clearing balances or ledger.
  Future<void> updateJarConfig({
    required double needsTarget,
    required int needsPercent,
  }) async {
    this.needsTarget = math.max(0, needsTarget);
    this.needsPercent = needsPercent.clamp(0, 100);
    await saveProfile();
    notifyListeners();
  }

  // Case 2: buffer has surplus → fill needs from buffer.
  Future<void> transferBufferToNeeds() async {
    final room = math.max(0.0, needsTarget - needsBalance);
    if (room <= 0 || bufferBalance <= 0) return;
    final transfer = math.min(room, bufferBalance);
    needsBalance = math.min(needsBalance + transfer, needsTarget);
    bufferBalance = math.max(0, bufferBalance - transfer);
    jarLedger.insert(
      0,
      JarEvent(
        timestamp: DateTime.now(),
        type: JarEventType.transfer,
        needsIn: transfer,
        needsOut: 0,
        bufferIn: 0,
        bufferOut: transfer,
        sentence: '${money(transfer)} moved Buffer → Needs',
      ),
    );
    await saveProfile();
    notifyListeners();
  }

  // Injects two months of demo events so the full goal scenario is visible.
  Future<void> seedDemoTwoJarData() async {
    selectedGoal = 'Irregular Income Buffer';
    needsTarget = 12000;
    needsPercent = 70;

    final now = DateTime.now();
    final lm = DateTime(now.year, now.month - 1); // last month
    final cm = DateTime(now.year, now.month);     // current month

    // Events in chronological order (oldest first). Replayed to compute balances.
    final events = [
      // ── Last month ──────────────────────────────────────────────────────
      JarEvent(timestamp: DateTime(lm.year, lm.month, 3),  type: JarEventType.income,   needsIn: 7000,  needsOut: 0,     bufferIn: 3000, bufferOut: 0,    sentence: '${money(10000)} in → ${money(7000)} Needs, ${money(3000)} Buffer'),
      JarEvent(timestamp: DateTime(lm.year, lm.month, 10), type: JarEventType.income,   needsIn: 5000,  needsOut: 0,     bufferIn: 4000, bufferOut: 0,    sentence: '${money(9000)} in → ${money(5000)} Needs, ${money(4000)} Buffer · Needs full! 🎉'),
      JarEvent(timestamp: DateTime(lm.year, lm.month, 15), type: JarEventType.billPaid, needsIn: 0,     needsOut: 3500,  bufferIn: 0,    bufferOut: 0,    sentence: '${money(3500)} bill paid from Needs'),
      JarEvent(timestamp: DateTime(lm.year, lm.month, 22), type: JarEventType.income,   needsIn: 3500,  needsOut: 0,     bufferIn: 4500, bufferOut: 0,    sentence: '${money(8000)} in → ${money(3500)} Needs (filled!), ${money(4500)} Buffer'),
      JarEvent(timestamp: DateTime(lm.year, lm.month, 28), type: JarEventType.billPaid, needsIn: 0,     needsOut: 12000, bufferIn: 0,    bufferOut: 3000, sentence: '${money(15000)} bill → ${money(12000)} Needs + ${money(3000)} Buffer'),
      // ── Current month ───────────────────────────────────────────────────
      JarEvent(timestamp: DateTime(cm.year, cm.month, 2),  type: JarEventType.income,   needsIn: 8400,  needsOut: 0,     bufferIn: 3600, bufferOut: 0,    sentence: '${money(12000)} in → ${money(8400)} Needs, ${money(3600)} Buffer'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 8),  type: JarEventType.income,   needsIn: 3600,  needsOut: 0,     bufferIn: 6400, bufferOut: 0,    sentence: '${money(10000)} in → ${money(3600)} Needs (filled!), ${money(6400)} Buffer · Case 1'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 12), type: JarEventType.billPaid, needsIn: 0,     needsOut: 4500,  bufferIn: 0,    bufferOut: 0,    sentence: '${money(4500)} bill paid from Needs'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 18), type: JarEventType.billPaid, needsIn: 0,     needsOut: 7500,  bufferIn: 0,    bufferOut: 9000, sentence: '${money(16500)} bill → ${money(7500)} Needs + ${money(9000)} Buffer · shortfall'),
      JarEvent(timestamp: DateTime(cm.year, cm.month, 22), type: JarEventType.income,   needsIn: 6300,  needsOut: 0,     bufferIn: 2700, bufferOut: 0,    sentence: '${money(9000)} in → ${money(6300)} Needs, ${money(2700)} Buffer'),
    ];

    // Replay to get final balances.
    needsBalance = 0;
    bufferBalance = 0;
    for (final e in events) {
      needsBalance = math.min(
        math.max(0, needsBalance + e.needsIn - e.needsOut),
        needsTarget,
      );
      bufferBalance = math.max(0, bufferBalance + e.bufferIn - e.bufferOut);
    }

    jarLedger
      ..clear()
      ..addAll(events.reversed); // newest-first
    await saveProfile();
    notifyListeners();
  }

  JarSplitResult onIncomeEvent(double amount, {String? sourceLabel}) {
    final needsShare = amount * needsPercent / 100;
    final bufferShare = amount - needsShare;
    final roomInNeeds = math.max(0.0, needsTarget - needsBalance);
    final toNeeds = math.min(needsShare, roomInNeeds);
    final toBuffer = bufferShare + (needsShare - toNeeds);
    needsBalance = math.min(needsBalance + toNeeds, needsTarget);
    bufferBalance += toBuffer;
    final label = sourceLabel != null ? ' ($sourceLabel)' : '';
    final sentence =
        '${money(amount)} in$label → ${money(toNeeds)} Needs, ${money(toBuffer)} Buffer';
    jarLedger.insert(
      0,
      JarEvent(
        timestamp: DateTime.now(),
        type: JarEventType.income,
        needsIn: toNeeds,
        needsOut: 0,
        bufferIn: toBuffer,
        bufferOut: 0,
        sentence: sentence,
      ),
    );
    saveProfile();
    notifyListeners();
    return JarSplitResult(
      toNeeds: toNeeds,
      toBuffer: toBuffer,
      overflow: toNeeds < needsShare,
    );
  }

  Future<void> onBillEvent(
    double amount, {
    required JarSource shortfallSource,
    String? label,
  }) async {
    final double needsOut;
    double bufferOut = 0;
    final String prefix = label != null ? '$label · ' : '';
    final String sentence;

    if (needsBalance >= amount) {
      needsOut = amount;
      needsBalance -= amount;
      sentence = '$prefix${money(amount)} paid from Needs';
    } else {
      needsOut = needsBalance;
      final remainder = amount - needsOut;
      needsBalance = 0;
      if (shortfallSource == JarSource.buffer) {
        bufferOut = math.min(remainder, bufferBalance);
        bufferBalance = math.max(0, bufferBalance - remainder);
        sentence =
            '$prefix${money(amount)} → ${money(needsOut)} Needs + ${money(remainder)} Buffer';
      } else {
        if (fakeMayaLink != null) {
          try {
            final session = await FakeMayaService.withdrawFromSavings(
              link: fakeMayaLink!,
              amount: remainder,
            );
            fakeMayaLink = FakeMayaLink.fromSession(session);
            _syncFakeMayaMoneyItems();
          } catch (_) {}
        }
        sentence =
            '$prefix${money(amount)} → ${money(needsOut)} Needs + ${money(remainder)} Emergency';
      }
    }

    jarLedger.insert(
      0,
      JarEvent(
        timestamp: DateTime.now(),
        type: JarEventType.billPaid,
        needsIn: 0,
        needsOut: needsOut,
        bufferIn: 0,
        bufferOut: bufferOut,
        sentence: sentence,
      ),
    );
    await saveProfile();
    notifyListeners();
  }

  void undoLastIncomeSplit() {
    final idx =
        jarLedger.indexWhere((e) => e.type == JarEventType.income);
    if (idx < 0) return;
    final event = jarLedger[idx];
    needsBalance = math.max(0, needsBalance - event.needsIn);
    bufferBalance = math.max(0, bufferBalance - event.bufferIn);
    jarLedger.removeAt(idx);
    saveProfile();
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
      return transaction;
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
    // Auto-record bill when labeled "Basic Needs" in the two-jar goal.
    if (category.trim().toLowerCase() == 'basic needs' &&
        selectedGoal == 'Irregular Income Buffer' &&
        needsTarget > 0 &&
        target.amount < 0) {
      await onBillEvent(
        target.amount.abs(),
        shortfallSource: JarSource.buffer,
        label: target.title,
      );
      return; // onBillEvent already calls saveProfile + notifyListeners
    }
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

// ─── Two-jar system types ─────────────────────────────────────────────────────

enum JarEventType { income, billPaid, transfer }

enum JarSource { buffer, emergency }

class JarSplitResult {
  const JarSplitResult({
    required this.toNeeds,
    required this.toBuffer,
    required this.overflow,
  });

  final double toNeeds;
  final double toBuffer;
  // true when needsShare > room, meaning Needs hit its target on this income event
  final bool overflow;
}

class JarEvent {
  JarEvent({
    required this.timestamp,
    required this.type,
    required this.needsIn,
    required this.needsOut,
    required this.bufferIn,
    required this.bufferOut,
    required this.sentence,
  });

  final DateTime timestamp;
  final JarEventType type;
  final double needsIn;
  final double needsOut;
  final double bufferIn;
  final double bufferOut;
  final String sentence;

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        'needsIn': needsIn,
        'needsOut': needsOut,
        'bufferIn': bufferIn,
        'bufferOut': bufferOut,
        'sentence': sentence,
      };

  factory JarEvent.fromMap(Map<String, dynamic> data) {
    final typeStr = data['type'] as String? ?? 'income';
    return JarEvent(
      timestamp: DateTime.tryParse(data['timestamp'] as String? ?? '') ??
          DateTime.now(),
      type: JarEventType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => JarEventType.income,
      ),
      needsIn: _num(data['needsIn']),
      needsOut: _num(data['needsOut']),
      bufferIn: _num(data['bufferIn']),
      bufferOut: _num(data['bufferOut']),
      sentence: data['sentence'] as String? ?? '',
    );
  }

  static double _num(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class CashFlowExpense {
  CashFlowExpense(this.name, this.budget);
  String name;
  double budget;

  Map<String, dynamic> toMap() => {'name': name, 'budget': budget};

  static CashFlowExpense fromMap(Map<String, dynamic> m) =>
      CashFlowExpense(m['name'] as String? ?? '', (m['budget'] as num?)?.toDouble() ?? 0);
}

class ShieldEvent {
  ShieldEvent({
    required this.timestamp,
    required this.amount,
    required this.sentence,
  });

  final DateTime timestamp;
  final double amount;
  final String sentence;

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'amount': amount,
        'sentence': sentence,
      };

  factory ShieldEvent.fromMap(Map<String, dynamic> data) => ShieldEvent(
        timestamp:
            DateTime.tryParse(data['timestamp'] as String? ?? '') ?? DateTime.now(),
        amount: _num(data['amount']),
        sentence: data['sentence'] as String? ?? '',
      );

  static double _num(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}
