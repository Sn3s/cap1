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
  String? _pendingAccountEmail;
  String? _pendingAccountPassword;
  bool _pendingGoogleAccount = false;
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
  String selectedGoalId = '';
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
  final List<int> notificationReminderMinutes = [20 * 60];
  bool thirdPartyDataLinkingAllowed = false;
  bool automaticDataGatheringAllowed = false;
  bool personalDataConsent = false;
  bool dataRetentionConsent = false;
  bool emotionalLogsEnabled = false;
  bool stressIndicatorsEnabled = false;
  FakeMayaLink? fakeMayaLink;
  double cashOnHandBalance = 0;
  final Map<String, double> manualAccountBalances = {
    'Wallet': 0,
    'Savings': 0,
    'Time Deposit': 0,
    'Goal Savings': 0,
  };
  final Set<String> fakeMayaSyncedAccounts = {};
  final List<FakeMayaTransaction> manualTransactions = [];
  final Map<String, TransactionLabelRule> transactionLabelRules = {};
  final Map<String, String> planAdjustmentActions = {};
  final Map<String, double> anxietyCheckIns = {};
  double allocatedThisCycle = 0;
  final Map<String, CollectionBucketOverride> goalBucketOverrides = {};
  final Set<String> selectedActionIds = {};

  /// Canonical goal ids explicitly added via the Goals page "+ Add Goal"
  /// flow (post-onboarding). The onboarding goal itself is NOT stored here
  /// — it's always derived live from `primaryConcern` — this only tracks
  /// EXTRA goals, so it can't be affected by unrelated action-id overlap
  /// between different goals' catalogs.
  final Set<String> addedGoalIds = {};
  final Map<String, Map<String, String>> actionFieldValues = {};
  final Map<String, double> categorySpendingBudgets = {};
  final Map<String, String> onboardingBaselines = {};
  final List<Map<String, dynamic>> onboardingIncomeLedger = [];
  final List<Map<String, dynamic>> onboardingExpenseLedger = [];

  // ── D1 goal bucket balances ──────────────────────────────────────
  double essentialExpensesBalance = 0;
  double billsObligationsBalance = 0;
  double emergencyFundBalance = 0;
  double investmentBalance = 0;
  double lifestyleFundBalance = 0;
  double lifestyleActivityBalance = 0;
  String? _lastEfWithdrawalStr; // ISO date string, null = no pending withdrawal

  DateTime? get lastEfWithdrawal => _lastEfWithdrawalStr == null
      ? null
      : DateTime.tryParse(_lastEfWithdrawalStr!);

  double get emergencyMonthsCovered => monthlyEssentialExpenseTotal <= 0
      ? 0
      : emergencyFundBalance / monthlyEssentialExpenseTotal;

  double get emergencyFundTarget => monthlyEssentialExpenseTotal > 0
      ? monthlyEssentialExpenseTotal * 3
      : math.max(30000, expenses * 3);

  double get investmentMonthlyTarget => income > 0
      ? income * 0.10
      : math.max(2000, cashFlowPyramidBaseline * 0.10);
  double get investmentPortfolioTarget =>
      math.max(20000, investmentMonthlyTarget * 12);

  final List<Map<String, dynamic>> d1Ledger = [];
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
  bool get hasPendingEmailAccount =>
      (_pendingAccountEmail ?? '').trim().isNotEmpty &&
      (_pendingAccountPassword ?? '').isNotEmpty;
  bool get hasPendingGoogleAccount => _pendingGoogleAccount;
  bool get hasFakeMayaLink => fakeMayaLink != null;
  List<FakeMayaTransaction> get allTransactions => [
        ...manualTransactions,
        if (fakeMayaSyncedAccounts.contains('Wallet'))
          ...?fakeMayaLink?.summary.transactions,
      ];

  double accountBalance(String account) {
    final summary = fakeMayaLink?.summary;
    if (fakeMayaSyncedAccounts.contains(account) && summary != null) {
      return switch (account) {
        'Wallet' => summary.wallet,
        'Savings' => summary.savings,
        'Time Deposit' => summary.timeDeposit,
        'Goal Savings' => summary.goalBalance,
        _ => 0,
      };
    }
    if (account == 'Cash on Hand') return cashOnHandBalance;
    return manualAccountBalances[account] ?? 0;
  }

  bool isAccountSynced(String account) =>
      fakeMayaLink != null && fakeMayaSyncedAccounts.contains(account);
  bool get needsFull => needsTarget > 0 && needsBalance >= needsTarget;
  double get bufferMonthsCovered =>
      needsTarget <= 0 ? 0 : bufferBalance / needsTarget;
  bool get shieldIsSetup => safetyShieldTargetMonths > 0;
  double get safetyShieldMonthlyBase => cashFlowPyramidBaseline > 0
      ? cashFlowPyramidBaseline
      : needsTarget > 0
          ? needsTarget
          : income > 0
              ? income * 0.7
              : 10000;
  double get safetyShieldBalance => accountBalance('Savings');
  double get safetyShieldTarget =>
      safetyShieldMonthlyBase * math.max(1, safetyShieldTargetMonths);
  double get safetyShieldMonthsCovered => safetyShieldMonthlyBase <= 0
      ? 0
      : safetyShieldBalance / safetyShieldMonthlyBase;
  double get totalCashFlowBudget =>
      cashFlowExpenses.fold(0, (s, e) => s + e.budget);
  double cashFlowBudgetForLayer(ExpenseLayer layer) => cashFlowExpenses
      .where((expense) => expense.layer == layer)
      .fold(0, (total, expense) => total + expense.budget);
  double get monthlyExpenseLedgerTotal => onboardingExpenseLedger.fold(
        0,
        (total, expense) =>
            total + ((expense['amount'] as num?)?.toDouble() ?? 0),
      );
  double get monthlyEssentialExpenseTotal => onboardingExpenseLedger
      .where(
        (expense) => expenseLayerForLedger(expense) == ExpenseLayer.basicNeeds,
      )
      .fold(
        0,
        (total, expense) =>
            total + ((expense['amount'] as num?)?.toDouble() ?? 0),
      );
  double get monthlyNonEssentialExpenseTotal =>
      math.max(0, monthlyExpenseLedgerTotal - monthlyEssentialExpenseTotal);
  double get cashFlowPyramidBaseline => monthlyExpenseLedgerTotal > 0
      ? monthlyExpenseLedgerTotal
      : cashFlowBudgetForLayer(ExpenseLayer.basicNeeds);
  double get linkedFakeMayaBalance => fakeMayaLink?.summary.totalBalance ?? 0;
  double get unallocatedFakeMayaWallet => math.max(
        0,
        accountBalance('Wallet') -
            essentialExpensesBalance -
            billsObligationsBalance,
      );
  double get unallocatedFakeMayaSavings => math.max(
        0,
        accountBalance('Savings') - displayedEmergencyFundBalance,
      );

  double get totalAssets =>
      accountBalance('Cash on Hand') +
      accountBalance('Wallet') +
      accountBalance('Savings') +
      accountBalance('Time Deposit') +
      accountBalance('Goal Savings') +
      assets
          .where((item) => !item.description.contains('FakeMaya'))
          .fold(0, (sum, item) => sum + item.value);
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
    _applyFirebaseUser(user);
    await saveProfile();
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
      _applyFirebaseUser(user);
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
    _applyFirebaseUser(user);
    await saveProfile();
    notifyListeners();
  }

  Future<void> createAccountWithEmail({
    required String email,
    required String password,
  }) async {
    await stageEmailAccount(email: email, password: password);
  }

  Future<void> stageEmailAccount({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Enter a valid email address.',
      );
    }
    if (password.length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: 'Password should be at least 6 characters.',
      );
    }

    await _voidMatchingIncompleteEmailAccount(
      email: normalizedEmail,
      password: password,
    );

    this.email = normalizedEmail;
    _pendingAccountEmail = normalizedEmail;
    _pendingAccountPassword = password;
    _pendingGoogleAccount = false;
    notifyListeners();
  }

  Future<void> stageGoogleAccount() async {
    final credential = await FirebaseProfileService.signInWithGoogle(
      forceFreshSession: true,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Google sign-in completed without a Firebase user.',
      );
    }
    final profile = await FirebaseProfileService.loadProfile(user.uid);
    if (profile != null && profile['onboardingComplete'] == true) {
      await signOut();
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message:
            'This Google account already finished onboarding. Please log in or use another account.',
      );
    }
    await FirebaseProfileService.deleteProfile(user.uid);
    _applyFirebaseUser(user);
    _pendingAccountEmail = null;
    _pendingAccountPassword = null;
    _pendingGoogleAccount = true;
    notifyListeners();
  }

  Future<void> _voidMatchingIncompleteEmailAccount({
    required String email,
    required String password,
  }) async {
    UserCredential credential;
    try {
      credential = await FirebaseProfileService.signInWithEmail(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found' ||
          error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        return;
      }
      rethrow;
    }

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Sign-in completed without a Firebase user.',
      );
    }
    final profile = await FirebaseProfileService.loadProfile(user.uid);
    if (profile != null && profile['onboardingComplete'] == true) {
      await signOut();
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message:
            'This email already belongs to an account. Please log in or use another email.',
      );
    }
    await FirebaseProfileService.deleteProfile(user.uid);
    await FirebaseProfileService.deleteCurrentUser();
    uid = null;
    photoUrl = null;
    onboardingComplete = false;
  }

  Future<void> completeOnboardingWithCurrentAccount() async {
    if (isSignedIn) {
      await _voidSignedInIncompleteProfileBeforeCompletion();
    } else if (hasPendingEmailAccount) {
      await _createOrResumePendingEmailAccount();
    }
    await saveProfile(markOnboardingComplete: true);
    _pendingAccountEmail = null;
    _pendingAccountPassword = null;
    _pendingGoogleAccount = false;
    notifyListeners();
  }

  Future<void> _voidSignedInIncompleteProfileBeforeCompletion() async {
    final user = FirebaseProfileService.currentUser;
    if (user == null) return;
    final profile = await FirebaseProfileService.loadProfile(user.uid);
    if (profile != null && profile['onboardingComplete'] == true) {
      await signOut();
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message:
            'This account already finished onboarding. Please log in or use another account.',
      );
    }
    await FirebaseProfileService.deleteProfile(user.uid);
    _applyFirebaseUser(user);
  }

  Future<void> _createOrResumePendingEmailAccount() async {
    final pendingEmail = _pendingAccountEmail!.trim();
    final pendingPassword = _pendingAccountPassword!;
    UserCredential credential;
    try {
      credential = await FirebaseProfileService.createUserWithEmail(
        email: pendingEmail,
        password: pendingPassword,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') rethrow;
      credential = await FirebaseProfileService.signInWithEmail(
        email: pendingEmail,
        password: pendingPassword,
      );
      final existingUser = credential.user;
      if (existingUser == null) {
        throw FirebaseAuthException(
          code: 'missing-user',
          message: 'Sign-in completed without a Firebase user.',
        );
      }
      final profile = await FirebaseProfileService.loadProfile(
        existingUser.uid,
      );
      if (profile != null && profile['onboardingComplete'] == true) {
        await signOut();
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message:
              'This email already belongs to a completed account. Please log in instead.',
        );
      }
      await FirebaseProfileService.deleteProfile(existingUser.uid);
      await FirebaseProfileService.deleteCurrentUser();
      credential = await FirebaseProfileService.createUserWithEmail(
        email: pendingEmail,
        password: pendingPassword,
      );
    }
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Account creation completed without a Firebase user.',
      );
    }
    await user.updateDisplayName(name.trim().isEmpty ? null : name.trim());
    _applyFirebaseUser(user);
  }

  Future<void> seedReflectionDemoUser() async {
    const demoEmail = 'reflection@test.com';
    const demoPassword = 'reflection123456';
    UserCredential credential;
    try {
      credential = await FirebaseProfileService.createUserWithEmail(
        email: demoEmail,
        password: demoPassword,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') rethrow;
      credential = await FirebaseProfileService.signInWithEmail(
        email: demoEmail,
        password: demoPassword,
      );
    }
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Demo account setup finished without a Firebase user.',
      );
    }
    await user.updateDisplayName('Reflection Demo');
    _applyFirebaseUser(user);
    _applyReflectionDemoProfile(user);
    await saveProfile(markOnboardingComplete: true);
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
    name = '';
    email = '';
    _pendingAccountEmail = null;
    _pendingAccountPassword = null;
    _pendingGoogleAccount = false;
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
    if ((user.email ?? '').trim().isNotEmpty) {
      email = user.email!.trim();
    }
    photoUrl = user.photoURL;
  }

  void seedReflectionDemoDataForTesting() {
    _applyReflectionDemoProfile(null);
  }

  void _applyReflectionDemoProfile(User? user) {
    name = 'Reflection Demo';
    email = user?.email ?? 'reflection@test.com';
    primaryConcern = 'Cash Flow & Basic Needs';
    selectedGoalId = 'G1';
    selectedGoal = 'Maintain Available Cash';
    selectedGoalDescription =
        'Maintain enough available cash while steadily funding safety, investments, and everyday enjoyment.';
    selectedGoalMonthlyTarget = 4000;
    selectedActionIds
      ..clear()
      ..addAll(const {
        'A1',
        'A3',
        'A20',
        'A19',
        'A9',
        'A8',
        'A22',
        'A10',
        'A12',
        'A23',
        'A24',
        'A25',
        'A26',
        'A27',
        'A28',
        'A29',
      });
    actionFieldValues
      ..clear()
      ..addAll({
        'A1': {'pct': '55'},
        'A3': {'amt': '4500'},
        'A20': {'amt': '30000'},
        'A19': {'amt': '12000'},
        'A9': {'amt': '4000'},
        'A8': {'pct': '10'},
        'A22': {'months': '3'},
        'A10': {'days': '7'},
        'A12': {'pct': '10'},
        'A23': {'amt': '50000'},
        'A24': {'amt': '1500'},
        'A25': {'amt': '1200'},
        'A26': {'amt': '2100'},
        'A27': {'amt': '1200'},
        'A28': {'amt': '1500'},
        'A29': {'amt': '12000', 'months': '6'},
      });
    onboardingComplete = true;
    confidence = 5;
    employmentStatus = 'Freelance';
    incomeType = 'Variable';
    incomeRhythm = 'Irregular';
    billsRhythm = 'Clustered bill weeks';
    needsTarget = 9000;
    needsPercent = 70;
    basicNeedsMonthlyTarget = 9000;
    basicNeedsAllocationPercent = .70;
    bufferAllocationPercent = .30;
    income = 32000;
    expenses = 9000;
    variableExpenses = 2998;
    debtPayments = 2000;
    savings = 6500;
    monthlySalary = 0;
    irregularIncomeFloor = 24000;
    onboardingIncomeLedger
      ..clear()
      ..add({
        'name': 'Project client work',
        'amount': 32000.0,
        'stable': false,
        'scheduled': false,
        'payDay': null,
      });
    onboardingExpenseLedger
      ..clear()
      ..addAll([
        {
          'name': 'Rent share',
          'amount': 4500.0,
          'essential': true,
          'expenseType': 'basicNeeds',
          'scheduled': true,
          'dueDay': 5,
        },
        {
          'name': 'Utilities',
          'amount': 2200.0,
          'essential': true,
          'expenseType': 'basicNeeds',
          'scheduled': true,
          'dueDay': 15,
        },
        {
          'name': 'Food and drinks',
          'amount': 1500.0,
          'essential': true,
          'expenseType': 'basicNeeds',
          'scheduled': false,
          'dueDay': null,
        },
        {
          'name': 'Transport',
          'amount': 800.0,
          'essential': true,
          'expenseType': 'basicNeeds',
          'scheduled': false,
          'dueDay': null,
        },
        {
          'name': 'Health insurance',
          'amount': 1200.0,
          'essential': false,
          'expenseType': 'emergencyInsurance',
          'scheduled': true,
          'dueDay': 20,
        },
        {
          'name': 'Student loan payment',
          'amount': 2000.0,
          'essential': false,
          'expenseType': 'debtInvestments',
          'scheduled': true,
          'dueDay': 25,
        },
        {
          'name': 'Streaming subscriptions',
          'amount': 700.0,
          'essential': false,
          'expenseType': 'nonEssentials',
          'scheduled': true,
          'dueDay': 12,
        },
        {
          'name': 'Gym membership',
          'amount': 800.0,
          'essential': false,
          'expenseType': 'nonEssentials',
          'scheduled': true,
          'dueDay': 18,
        },
        {
          'name': 'Everyday enjoyment',
          'amount': 1498.0,
          'essential': false,
          'expenseType': 'nonEssentials',
          'scheduled': false,
          'dueDay': null,
        },
      ]);
    onboardingBaselines
      ..clear()
      ..addAll({
        'income_baseline': '32000.00',
        'stable_income': '0.00',
        'variable_income': '32000.00',
        'monthly_expenses': '15198.00',
        'essential_expenses': '9000.00',
        'discretionary_spend': '2998.00',
        'investment_balance': '32000.00',
        'emergency_balance': '23000.00',
      });
    cashFlowExpenses
      ..clear()
      ..addAll([
        CashFlowExpense('Rent share', 4500),
        CashFlowExpense('Utilities', 2200),
        CashFlowExpense('Food and transport', 2300),
        CashFlowExpense(
          'Health insurance',
          1200,
          layer: ExpenseLayer.emergencyInsurance,
        ),
        CashFlowExpense(
          'Student loan payment',
          2000,
          layer: ExpenseLayer.debtInvestments,
        ),
        CashFlowExpense(
          'Streaming subscriptions',
          700,
          layer: ExpenseLayer.nonEssentials,
        ),
        CashFlowExpense(
          'Gym membership',
          800,
          layer: ExpenseLayer.nonEssentials,
        ),
        CashFlowExpense(
          'Everyday enjoyment',
          1498,
          layer: ExpenseLayer.nonEssentials,
        ),
      ]);
    jarLedger.clear();
    d1Ledger.clear();
    essentialExpensesBalance = 3500;
    billsObligationsBalance = 1800;
    emergencyFundBalance = 24000;
    investmentBalance = 32000;
    lifestyleFundBalance = 2800;
    lifestyleActivityBalance = 3500;
    categorySpendingBudgets
      ..clear()
      ..addAll({
        'Food & drink': 4500,
        'Entertainment': 1500,
      });

    final today = DateTime.now();
    final weekStart = today
        .subtract(Duration(days: today.weekday - DateTime.monday))
        .subtract(const Duration(days: 77));
    var needs = 3600.0;
    var buffer = 900.0;
    final transactions = <FakeMayaTransaction>[];
    final incomePlan = <int, double>{
      0: 6200,
      1: 4100,
      3: 7600,
      4: 4800,
      6: 8200,
      8: 5300,
      9: 7000,
      11: 4600,
    };
    final billPlan = <int, List<(String, double)>>{
      1: [('Meralco', 1800), ('Water', 650)],
      3: [('Internet', 1699), ('Rent share', 4500)],
      5: [('Meralco', 2050), ('Water', 720)],
      7: [('Rent share', 4500), ('Internet', 1699)],
      9: [('Meralco', 1900), ('Water', 680)],
      10: [('Clinic visit emergency', 1000), ('Internet', 1699)],
    };
    const categories = [
      'Food & drink',
      'Transport',
      'Bills & utilities',
      'Groceries',
    ];
    for (var week = 0; week < 12; week++) {
      final base = weekStart.add(Duration(days: week * 7));
      final incomeAmount = incomePlan[week];
      if (incomeAmount != null) {
        final toNeeds = math.min<double>(
            incomeAmount * .70, math.max(0, needsTarget - needs));
        final toBuffer = incomeAmount - toNeeds;
        needs += toNeeds;
        buffer += toBuffer;
        jarLedger.add(JarEvent(
          timestamp: base.add(Duration(days: week.isEven ? 0 : 2)),
          type: JarEventType.income,
          needsIn: toNeeds,
          needsOut: 0,
          bufferIn: toBuffer,
          bufferOut: 0,
          sentence:
              '${money(incomeAmount)} irregular income -> ${money(toNeeds)} Needs, ${money(toBuffer)} Buffer',
        ));
        transactions.add(_demoTransaction(
          id: 'income-$week',
          title: 'Cash in',
          detail: 'From: Project client',
          amount: incomeAmount,
          date: base.add(Duration(days: week.isEven ? 0 : 2)),
          category: 'Business income',
          source: 'Basic Needs Fund',
        ));
      }
      for (final bill in billPlan[week] ?? const <(String, double)>[]) {
        final amount = bill.$2;
        final isEmergency = bill.$1.toLowerCase().contains('emergency');
        final paidAt = base.add(const Duration(days: 4));
        if (isEmergency) {
          emergencyFundBalance = math.max(0, emergencyFundBalance - amount);
          d1Ledger.insert(0, {
            'type': 'use_emergency',
            'date': paidAt.toIso8601String(),
            'amount': amount,
            'label': bill.$1,
            'sourceTransactionId': 'emergency-$week-${bill.$1}',
          });
          transactions.add(_demoTransaction(
            id: 'emergency-$week-${bill.$1}',
            title: 'Emergency payment',
            detail: 'To: ${bill.$1}',
            amount: -amount,
            date: paidAt,
            category: 'Health',
            source: 'Emergency Fund',
          ));
          continue;
        }
        final needsOut = math.min<double>(needs, amount);
        final bufferOut =
            math.min<double>(buffer, math.max(0, amount - needsOut));
        needs = math.max(0, needs - needsOut);
        buffer = math.max(0, buffer - bufferOut);
        jarLedger.add(JarEvent(
          timestamp: paidAt,
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: needsOut,
          bufferIn: 0,
          bufferOut: bufferOut,
          sentence:
              '${bill.$1} ${money(amount)} paid from Needs${bufferOut > 0 ? ' + Buffer shortfall' : ''}',
        ));
        transactions.add(_demoTransaction(
          id: 'bill-$week-${bill.$1}',
          title: 'Bill payment',
          detail: 'To: ${bill.$1}',
          amount: -amount,
          date: paidAt,
          category: bill.$1.toLowerCase().contains('rent')
              ? 'Housing'
              : 'Bills & utilities',
          source: 'Basic Needs Fund',
        ));
      }
      for (var day = 1; day <= 5; day += 2) {
        final date = base.add(Duration(days: day));
        final beforeIncome = day >= 5;
        final amount =
            (beforeIncome ? 270 : 430) + ((week * 23 + day * 17) % 90);
        final leaveUnclassified = (week == 2 && day == 3) ||
            (week == 4 && day == 5) ||
            (week == 8 && day == 1) ||
            (week == 10 && day == 3) ||
            (week == 11 && day == 5);
        transactions.add(_demoTransaction(
          id: 'spend-$week-$day',
          title: day == 5 ? 'Sent money' : 'Paid merchant',
          detail: day == 3 ? 'To: Jeep and train' : 'To: Daily merchant',
          amount: -amount.toDouble(),
          date: date,
          category: leaveUnclassified
              ? null
              : categories[(week + day) % categories.length],
          source: leaveUnclassified ? null : 'Basic Needs Fund',
        ));
      }
    }
    final recent = today.subtract(const Duration(days: 2));
    final earlierThisMonth = DateTime(today.year, today.month, 3);
    final activityStart = DateTime(today.year, today.month - 1, 18);
    d1Ledger.insertAll(0, [
      {
        'type': 'essential_deposit',
        'date': earlierThisMonth.toIso8601String(),
        'sourceDate': earlierThisMonth.toIso8601String(),
        'sourceTransactionId': 'income-9',
        'incomeAmount': 7000.0,
        'percentage': 55.0,
        'amount': 3850.0,
        'destination': 'Essential Expenses Fund',
      },
      {
        'type': 'emergency_deposit',
        'date': earlierThisMonth.add(const Duration(days: 1)).toIso8601String(),
        'sourceDate': earlierThisMonth.toIso8601String(),
        'sourceTransactionId': 'income-9',
        'incomeAmount': 7000.0,
        'percentage': 10.0,
        'amount': 700.0,
        'destination': 'Emergency Fund',
      },
      {
        'type': 'emergency_deposit',
        'date': recent.toIso8601String(),
        'amount': 2500.0,
        'destination': 'Emergency Fund',
        'label': 'Monthly Emergency Fund deposit',
      },
      {
        'type': 'investment_deposit',
        'date': earlierThisMonth.add(const Duration(days: 1)).toIso8601String(),
        'sourceDate': earlierThisMonth.toIso8601String(),
        'sourceTransactionId': 'income-9',
        'incomeAmount': 7000.0,
        'percentage': 10.0,
        'amount': 700.0,
        'destination': 'Investment Portfolio',
      },
      {
        'type': 'investment_monthly',
        'date': recent.toIso8601String(),
        'amount': 2800.0,
        'destination': 'Investment Portfolio',
        'label': 'Monthly investment contribution',
      },
      {
        'type': 'investment_gain',
        'date': recent.subtract(const Duration(days: 1)).toIso8601String(),
        'amount': 900.0,
        'balance': 32250.0,
        'destination': 'Investment Portfolio',
        'label': 'Investment earnings',
      },
      {
        'type': 'investment_loss',
        'date': recent.toIso8601String(),
        'amount': 250.0,
        'balance': 32000.0,
        'destination': 'Investment Portfolio',
        'label': 'Investment loss',
      },
      {
        'type': 'lifestyle_subscription_reserve',
        'date': recent.subtract(const Duration(days: 1)).toIso8601String(),
        'amount': 1200.0,
        'destination': 'Lifestyle Fund',
        'label': 'Subscriptions and memberships reserve',
      },
      {
        'type': 'lifestyle_payday',
        'date': earlierThisMonth.add(const Duration(days: 2)).toIso8601String(),
        'sourceDate': earlierThisMonth.toIso8601String(),
        'sourceTransactionId': 'income-9',
        'amount': 1200.0,
        'destination': 'Everyday Enjoyment Fund',
        'label': 'Payday enjoyment contribution',
      },
      {
        'type': 'lifestyle_activity_deposit',
        'date': activityStart.toIso8601String(),
        'amount': 2000.0,
        'destination': 'Hobby or Activity Fund',
        'label': 'Hobby or activity contribution',
      },
      {
        'type': 'lifestyle_activity_deposit',
        'date': recent.toIso8601String(),
        'amount': 1500.0,
        'destination': 'Hobby or Activity Fund',
        'label': 'Hobby or activity contribution',
      },
    ]);
    transactions.addAll([
      _demoTransaction(
        id: 'lifestyle-coffee-current',
        title: 'Paid merchant',
        detail: 'To: Neighborhood coffee shop',
        amount: -320,
        date: recent,
        category: 'Food & drink',
        source: 'Lifestyle Fund',
      ),
      _demoTransaction(
        id: 'lifestyle-movie-current',
        title: 'Paid merchant',
        detail: 'To: Cinema tickets',
        amount: -450,
        date: recent.add(const Duration(hours: 3)),
        category: 'Entertainment',
        source: 'Lifestyle Fund',
      ),
      _demoTransaction(
        id: 'subscription-current',
        title: 'Subscription payment',
        detail: 'To: Streaming service',
        amount: -700,
        date: recent.subtract(const Duration(days: 1)),
        category: 'Entertainment',
        source: 'Lifestyle Fund',
      ),
    ]);
    jarLedger.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    d1Ledger.add({
      'type': 'emergency_deposit',
      'date': weekStart.subtract(const Duration(days: 14)).toIso8601String(),
      'amount': 20800,
      'destination': 'Emergency Fund',
      'label': 'Opening emergency balance',
    });
    needsBalance = needs;
    bufferBalance = buffer;
    emergencyMonths =
        emergencyFundBalance / math.max(1, monthlyEssentialExpenseTotal);
    fakeMayaLink = FakeMayaLink(
      userId: 'reflection-demo-fakemaya',
      email: 'reflection@test.com',
      name: 'Reflection Demo',
      phone: '+63 917 000 0000',
      provider: 'seed',
      accessToken: '',
      refreshToken: '',
      expiresAt: null,
      summary: FakeMayaAccountSummary(
        wallet: 18000,
        savings: emergencyFundBalance,
        timeDeposit: investmentBalance,
        goalName: 'Lifestyle and Activity Funds',
        goalEmoji: '🎨',
        goalBalance: lifestyleFundBalance + lifestyleActivityBalance,
        goalTarget: 12000,
        creditLimit: 0,
        creditUsed: 0,
        transactions: transactions
          ..sort(
              (a, b) => (b.createdAt ?? today).compareTo(a.createdAt ?? today)),
        updatedAt: today,
      ),
    );
    fakeMayaSyncedAccounts
      ..clear()
      ..addAll(manualAccountBalances.keys);
    _syncFakeMayaMoneyItems();
  }

  FakeMayaTransaction _demoTransaction({
    required String id,
    required String title,
    required String detail,
    required double amount,
    required DateTime date,
    String? category,
    String? source,
  }) {
    return FakeMayaTransaction(
      id: id,
      title: title,
      detail: detail,
      age: 'Seeded',
      amountText: '${amount < 0 ? '-' : '+'} ${money(amount.abs())}',
      createdAt: date,
      category: category,
      source: source,
      labeledAt: category == null ? null : date.add(const Duration(hours: 2)),
    );
  }

  Map<String, dynamic> _profileMap(User user) {
    return {
      'uid': user.uid,
      'onboardingComplete': onboardingComplete,
      'name': name.trim().isEmpty ? user.displayName ?? '' : name.trim(),
      'email': (user.email ?? '').trim().isNotEmpty
          ? user.email!.trim()
          : email.trim(),
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
      'notificationReminderMinutes': notificationReminderMinutes,
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
      'cashOnHandBalance': cashOnHandBalance,
      'manualAccountBalances': manualAccountBalances,
      'fakeMayaSyncedAccounts': fakeMayaSyncedAccounts.toList()..sort(),
      'manualTransactions':
          manualTransactions.map((transaction) => transaction.toMap()).toList(),
      'transactionLabelRules': transactionLabelRules.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'planAdjustmentActions': planAdjustmentActions,
      'anxietyCheckIns': anxietyCheckIns,
      'allocatedThisCycle': allocatedThisCycle,
      'goalBucketOverrides':
          goalBucketOverrides.map((key, value) => MapEntry(key, value.toMap())),
      'selectedActionIds': selectedActionIds.toList()..sort(),
      'addedGoalIds': addedGoalIds.toList()..sort(),
      'selectedGoalId': selectedGoalId,
      'actionFieldValues': actionFieldValues,
      'categorySpendingBudgets': categorySpendingBudgets,
      'onboardingBaselines': onboardingBaselines,
      'onboardingIncomeLedger': onboardingIncomeLedger,
      'onboardingExpenseLedger': onboardingExpenseLedger,
      'essentialExpensesBalance': essentialExpensesBalance,
      'billsObligationsBalance': billsObligationsBalance,
      'emergencyFundBalance': emergencyFundBalance,
      'investmentBalance': investmentBalance,
      'lifestyleFundBalance': lifestyleFundBalance,
      'lifestyleActivityBalance': lifestyleActivityBalance,
      'd1Ledger': d1Ledger,
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
        'selectedGoalId': selectedGoalId,
        'actionFieldValues': actionFieldValues,
        'onboardingBaselines': onboardingBaselines,
        'onboardingIncomeLedger': onboardingIncomeLedger,
        'onboardingExpenseLedger': onboardingExpenseLedger,
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
    selectedGoalId = data['selectedGoalId'] as String? ??
        planSetup['selectedGoalId'] as String? ??
        selectedGoalId;
    final savedActionFields = _mapFrom(
      data['actionFieldValues'] ?? planSetup['actionFieldValues'],
    );
    if (savedActionFields != null) {
      actionFieldValues
        ..clear()
        ..addEntries(savedActionFields.entries.map((entry) => MapEntry(
              entry.key,
              Map<String, String>.from(_mapFrom(entry.value) ?? const {}),
            )));
    }
    final savedCategoryBudgets = _mapFrom(data['categorySpendingBudgets']);
    if (savedCategoryBudgets != null) {
      categorySpendingBudgets
        ..clear()
        ..addEntries(savedCategoryBudgets.entries
            .map(
              (entry) => MapEntry(entry.key, _doubleFrom(entry.value, 0)),
            )
            .where((entry) => entry.value > 0));
    }
    final savedBaselines = _mapFrom(
      data['onboardingBaselines'] ?? planSetup['onboardingBaselines'],
    );
    if (savedBaselines != null) {
      onboardingBaselines
        ..clear()
        ..addEntries(savedBaselines.entries.map(
          (entry) => MapEntry(entry.key, entry.value?.toString() ?? ''),
        ));
    }
    final savedIncomeLedger =
        data['onboardingIncomeLedger'] ?? planSetup['onboardingIncomeLedger'];
    if (savedIncomeLedger is Iterable) {
      onboardingIncomeLedger
        ..clear()
        ..addAll(savedIncomeLedger.whereType<Map>().map(
              (entry) => Map<String, dynamic>.from(entry),
            ));
    }
    final savedExpenseLedger =
        data['onboardingExpenseLedger'] ?? planSetup['onboardingExpenseLedger'];
    if (savedExpenseLedger is Iterable) {
      onboardingExpenseLedger
        ..clear()
        ..addAll(savedExpenseLedger.whereType<Map>().map(
              (entry) => Map<String, dynamic>.from(entry),
            ));
    }
    essentialExpensesBalance = _doubleFrom(
      data['essentialExpensesBalance'],
      essentialExpensesBalance,
    );
    billsObligationsBalance = _doubleFrom(
      data['billsObligationsBalance'],
      billsObligationsBalance,
    );
    emergencyFundBalance = _doubleFrom(
      data['emergencyFundBalance'],
      emergencyFundBalance,
    );
    investmentBalance = _doubleFrom(
      data['investmentBalance'],
      investmentBalance,
    );
    lifestyleFundBalance = _doubleFrom(
      data['lifestyleFundBalance'],
      lifestyleFundBalance,
    );
    lifestyleActivityBalance = _doubleFrom(
      data['lifestyleActivityBalance'],
      lifestyleActivityBalance,
    );
    final savedD1Ledger = data['d1Ledger'];
    if (savedD1Ledger is Iterable) {
      d1Ledger
        ..clear()
        ..addAll(savedD1Ledger.whereType<Map>().map(
              (entry) => Map<String, dynamic>.from(entry),
            ));
    }
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
    final reminderData = data['notificationReminderMinutes'];
    if (reminderData is List) {
      notificationReminderMinutes
        ..clear()
        ..addAll(
          reminderData
              .whereType<num>()
              .map((value) => value.toInt().clamp(0, 1439))
              .toSet(),
        )
        ..sort();
    }
    unawaited(
      notificationsAllowed
          ? ShellbyNotificationService.instance
              .scheduleDailyReminders(notificationReminderMinutes)
          : ShellbyNotificationService.instance.cancelReminders(),
    );
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
      data['basicNeedsAllocationPercent'] ??
          planSetup['basicNeedsAllocationPercent'],
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
          jarData.whereType<Map>().map((item) => JarEvent.fromMap(
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
    cashOnHandBalance =
        _doubleFrom(data['cashOnHandBalance'], cashOnHandBalance);
    final savedManualBalances = _mapFrom(data['manualAccountBalances']);
    if (savedManualBalances != null) {
      for (final account in manualAccountBalances.keys) {
        manualAccountBalances[account] =
            _doubleFrom(savedManualBalances[account], 0);
      }
    }
    final savedSyncedAccounts = data['fakeMayaSyncedAccounts'];
    fakeMayaSyncedAccounts
      ..clear()
      ..addAll(
        savedSyncedAccounts is Iterable
            ? savedSyncedAccounts.map((value) => value.toString())
            : fakeMayaLink == null
                ? const <String>[]
                : manualAccountBalances.keys,
      );
    final manualData = data['manualTransactions'];
    manualTransactions
      ..clear()
      ..addAll(
        manualData is List
            ? manualData
                .whereType<Map>()
                .map((item) => FakeMayaTransaction.fromMap(
                      Map<String, dynamic>.from(item),
                    ))
            : const <FakeMayaTransaction>[],
      );
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
    for (final transaction in allTransactions) {
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
    _replaceSet(addedGoalIds, data['addedGoalIds']);
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
    selectedGoalId = '';
    selectedActionIds.clear();
    actionFieldValues.clear();
    onboardingBaselines.clear();
    onboardingIncomeLedger.clear();
    onboardingExpenseLedger.clear();
    emotionalLogsEnabled = false;
    stressIndicatorsEnabled = false;
    consentAi = false;
    consentTrustedCircle = false;
    if (socialStructure == 'Collaborative goal') {
      socialStructure = 'Private only';
    }
    notifyListeners();
  }

  // ── D1 goal bucket actions ────────────────────────────────────────

  Future<void> updateCategorySpendingBudgets(
    Map<String, double> budgets,
  ) async {
    categorySpendingBudgets
      ..clear()
      ..addEntries(budgets.entries.where((entry) => entry.value > 0));
    await saveProfile();
    notifyListeners();
  }

  bool hasEssentialAllocationForIncome(String transactionId) =>
      d1Ledger.any((entry) =>
          entry['type'] == 'essential_deposit' &&
          entry['sourceTransactionId'] == transactionId);

  bool _isEssentialIncomeCandidate(FakeMayaTransaction transaction) {
    if (transaction.amount <= 0 ||
        !transaction.isLabeled ||
        transaction.excludedFromInsights) {
      return false;
    }
    final category = transaction.category?.trim().toLowerCase() ?? '';
    final text =
        '${transaction.title} ${transaction.detail} $category'.toLowerCase();
    return category.contains('salary') ||
        category.contains('income') ||
        category == 'gift' ||
        text.contains('salary') ||
        text.contains('income') ||
        text.contains('payroll') ||
        text.contains('cash in') ||
        text.contains('received') ||
        text.contains('gift');
  }

  List<FakeMayaTransaction> get pendingEssentialIncomeTransactions {
    final now = DateTime.now();
    return allTransactions
        .where((transaction) =>
            _isEssentialIncomeCandidate(transaction) &&
            !hasEssentialAllocationForIncome(transaction.transactionId))
        .where((transaction) {
      final date = transaction.createdAt ?? transaction.labeledAt;
      return date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList()
      ..sort((a, b) =>
          (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          ));
  }

  bool hasEmergencyAllocationForIncome(String transactionId) =>
      d1Ledger.any((entry) =>
          entry['type'] == 'emergency_deposit' &&
          entry['sourceTransactionId'] == transactionId);

  DateTime? get latestEmergencyReplenishmentDate {
    for (final entry in d1Ledger) {
      if (entry['type'] == 'ef_replenish') {
        return DateTime.tryParse(entry['date']?.toString() ?? '');
      }
    }
    return null;
  }

  double get pendingRecordedEmergencyReplenishment {
    var total = 0.0;
    for (final entry in d1Ledger) {
      if (entry['type'] == 'ef_replenish') break;
      if (entry['type'] == 'use_emergency') {
        total += (entry['amount'] as num?)?.toDouble() ?? 0;
      }
    }
    return total;
  }

  List<FakeMayaTransaction> get pendingLabeledEmergencyWithdrawals {
    final replenishedAt = latestEmergencyReplenishmentDate;
    final recordedIds = d1Ledger
        .where((entry) => entry['sourceTransactionId'] != null)
        .map((entry) => entry['sourceTransactionId'].toString())
        .toSet();
    return (fakeMayaLink?.summary.transactions ?? const <FakeMayaTransaction>[])
        .where((transaction) {
      final date = transaction.createdAt ?? transaction.labeledAt;
      return transaction.amount < 0 &&
          transaction.source?.trim().toLowerCase() == 'emergency fund' &&
          !recordedIds.contains(transaction.transactionId) &&
          (replenishedAt == null ||
              date == null ||
              date.isAfter(replenishedAt));
    }).toList();
  }

  double get pendingLabeledEmergencyReplenishment =>
      pendingLabeledEmergencyWithdrawals.fold<double>(
        0,
        (total, transaction) => total + transaction.amount.abs(),
      );

  double get pendingEmergencyReplenishment =>
      pendingRecordedEmergencyReplenishment +
      pendingLabeledEmergencyReplenishment;

  double get displayedEmergencyFundBalance => math.max(
        0,
        emergencyFundBalance - pendingLabeledEmergencyReplenishment,
      );

  DateTime? get latestEmergencyWithdrawalDate {
    DateTime? latest;
    for (final entry in d1Ledger) {
      if (entry['type'] == 'ef_replenish') break;
      if (entry['type'] == 'use_emergency') {
        final date = DateTime.tryParse(entry['date']?.toString() ?? '');
        if (date != null && (latest == null || date.isAfter(latest)))
          latest = date;
      }
    }
    for (final transaction in pendingLabeledEmergencyWithdrawals) {
      final date = transaction.createdAt ?? transaction.labeledAt;
      if (date != null && (latest == null || date.isAfter(latest)))
        latest = date;
    }
    return latest;
  }

  Future<void> depositIncomeToEssentialFund({
    required String transactionId,
    required double incomeAmount,
    required DateTime incomeDate,
    double percentage = 50,
  }) async {
    if (incomeAmount <= 0 || hasEssentialAllocationForIncome(transactionId)) {
      return;
    }
    final amount = incomeAmount * percentage.clamp(0, 100) / 100;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    essentialExpensesBalance += amount;
    d1Ledger.insert(0, {
      'type': 'essential_deposit',
      'date': DateTime.now().toIso8601String(),
      'sourceDate': incomeDate.toIso8601String(),
      'sourceTransactionId': transactionId,
      'incomeAmount': incomeAmount,
      'percentage': percentage,
      'amount': amount,
      'destination': 'Essential Expenses Fund',
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> depositPendingIncomeToEssentialFund({
    required Iterable<FakeMayaTransaction> incomes,
    double percentage = 50,
  }) async {
    final pending = incomes
        .where((income) =>
            income.createdAt != null &&
            income.amount > 0 &&
            !hasEssentialAllocationForIncome(income.transactionId))
        .toList();
    if (pending.isEmpty) return;
    final clampedPercentage = percentage.clamp(0, 100).toDouble();
    final totalIncome =
        pending.fold<double>(0, (total, income) => total + income.amount);
    final totalAllocation = totalIncome * clampedPercentage / 100;
    if (totalAllocation <= 0) return;
    if (fakeMayaLink != null && totalAllocation > unallocatedFakeMayaWallet) {
      return;
    }
    essentialExpensesBalance += totalAllocation;
    for (final income in pending) {
      d1Ledger.insert(0, {
        'type': 'essential_deposit',
        'date': DateTime.now().toIso8601String(),
        'sourceDate': income.createdAt!.toIso8601String(),
        'sourceTransactionId': income.transactionId,
        'incomeAmount': income.amount,
        'percentage': clampedPercentage,
        'amount': income.amount * clampedPercentage / 100,
        'destination': 'Essential Expenses Fund',
      });
    }
    if (isSignedIn) await saveProfile();
    notifyListeners();
  }

  Future<void> depositIncomeToEmergencyFund({
    required String transactionId,
    required double incomeAmount,
    required DateTime incomeDate,
    double percentage = 10,
  }) async {
    if (incomeAmount <= 0 || hasEmergencyAllocationForIncome(transactionId)) {
      return;
    }
    final amount = incomeAmount * percentage.clamp(0, 100) / 100;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.savings);
    emergencyFundBalance += amount;
    d1Ledger.insert(0, {
      'type': 'emergency_deposit',
      'date': DateTime.now().toIso8601String(),
      'sourceDate': incomeDate.toIso8601String(),
      'sourceTransactionId': transactionId,
      'incomeAmount': incomeAmount,
      'percentage': percentage,
      'amount': amount,
      'destination': 'Emergency Fund',
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> depositMonthlyEmergencyFund(double amount) async {
    if (amount <= 0) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.savings);
    emergencyFundBalance += amount;
    d1Ledger.insert(0, {
      'type': 'emergency_deposit',
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'destination': 'Emergency Fund',
      'label': 'Monthly Emergency Fund deposit',
    });
    await saveProfile();
    notifyListeners();
  }

  bool hasInvestmentAllocationForIncome(String transactionId) =>
      d1Ledger.any((entry) =>
          entry['type'] == 'investment_deposit' &&
          entry['sourceTransactionId'] == transactionId);

  String get currentInvestmentSweepMonthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  bool get hasInvestmentSweepForCurrentMonth => d1Ledger.any((entry) =>
      entry['type'] == 'investment_sweep' &&
      entry['monthKey'] == currentInvestmentSweepMonthKey);

  double get investedThisMonth {
    final now = DateTime.now();
    var total = 0.0;
    for (final entry in d1Ledger) {
      final type = entry['type'];
      if (type != 'investment_deposit' &&
          type != 'investment_sweep' &&
          type != 'investment_monthly' &&
          type != 'investment_windfall') {
        continue;
      }
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      if (date != null && date.year == now.year && date.month == now.month) {
        total += (entry['amount'] as num?)?.toDouble() ?? 0;
      }
    }
    return total;
  }

  double get investmentEarningsThisMonth =>
      _investmentPerformanceTotalForCurrentMonth('investment_gain');

  double get investmentLossesThisMonth =>
      _investmentPerformanceTotalForCurrentMonth('investment_loss');

  double get investmentNetReturnThisMonth =>
      investmentEarningsThisMonth - investmentLossesThisMonth;

  double _investmentPerformanceTotalForCurrentMonth(String type) {
    final now = DateTime.now();
    var total = 0.0;
    for (final entry in d1Ledger) {
      if (entry['type'] != type) continue;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      if (date != null && date.year == now.year && date.month == now.month) {
        total += (entry['amount'] as num?)?.toDouble() ?? 0;
      }
    }
    return total;
  }

  /// A12: invest X% of every income received into selected investment accounts.
  Future<void> depositIncomeToInvestment({
    required String transactionId,
    required double incomeAmount,
    required DateTime incomeDate,
    double percentage = 10,
  }) async {
    if (incomeAmount <= 0 || hasInvestmentAllocationForIncome(transactionId)) {
      return;
    }
    final amount = incomeAmount * percentage.clamp(0, 100) / 100;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.timeDeposit);
    investmentBalance += amount;
    d1Ledger.insert(0, {
      'type': 'investment_deposit',
      'date': DateTime.now().toIso8601String(),
      'sourceDate': incomeDate.toIso8601String(),
      'sourceTransactionId': transactionId,
      'incomeAmount': incomeAmount,
      'percentage': percentage,
      'amount': amount,
      'destination': 'Investment Portfolio',
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> depositMonthlyInvestment(double amount) async {
    if (amount <= 0) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.timeDeposit);
    investmentBalance += amount;
    d1Ledger.insert(0, {
      'type': 'investment_monthly',
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'destination': 'Investment Portfolio',
      'label': 'Monthly investment contribution',
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> recordInvestmentPerformance({
    required double amount,
    required bool isGain,
  }) async {
    if (amount <= 0) return;
    final appliedAmount = isGain ? amount : math.min(amount, investmentBalance);
    if (appliedAmount <= 0) return;
    investmentBalance += isGain ? appliedAmount : -appliedAmount;
    d1Ledger.insert(0, {
      'type': isGain ? 'investment_gain' : 'investment_loss',
      'date': DateTime.now().toIso8601String(),
      'amount': appliedAmount,
      'balance': investmentBalance,
      'destination': 'Investment Portfolio',
      'label': isGain ? 'Investment earnings' : 'Investment loss',
    });
    await saveProfile();
    notifyListeners();
  }

  bool hasInvestmentWindfallAllocation(String transactionId) =>
      d1Ledger.any((entry) =>
          entry['type'] == 'investment_windfall' &&
          entry['sourceTransactionId'] == transactionId);

  Future<void> depositWindfallToInvestment({
    required String transactionId,
    required double cashInAmount,
    required DateTime cashInDate,
    double percentage = 50,
  }) async {
    if (cashInAmount <= 0 || hasInvestmentWindfallAllocation(transactionId)) {
      return;
    }
    final amount = cashInAmount * percentage.clamp(0, 100) / 100;
    if (amount <= 0) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.timeDeposit);
    investmentBalance += amount;
    d1Ledger.insert(0, {
      'type': 'investment_windfall',
      'date': DateTime.now().toIso8601String(),
      'sourceDate': cashInDate.toIso8601String(),
      'sourceTransactionId': transactionId,
      'cashInAmount': cashInAmount,
      'percentage': percentage,
      'amount': amount,
      'destination': 'Investment Portfolio',
    });
    await saveProfile();
    notifyListeners();
  }

  DateTime? get lastInvestmentReviewDate {
    DateTime? latest;
    for (final entry in d1Ledger) {
      if (entry['type'] != 'investment_review') continue;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      if (date == null) continue;
      if (latest == null || date.isAfter(latest)) latest = date;
    }
    return latest;
  }

  Future<void> markInvestmentPortfolioReviewed(
      {required int intervalDays}) async {
    d1Ledger.insert(0, {
      'type': 'investment_review',
      'date': DateTime.now().toIso8601String(),
      'intervalDays': intervalDays,
      'balance': investmentBalance,
      'destination': 'Investment Portfolio',
      'label': 'Portfolio reviewed',
    });
    await saveProfile();
    notifyListeners();
  }

  /// A14: transfer X% of unspent monthly funds toward investments at month end.
  Future<void> sweepUnspentFundsToInvestment({double percentage = 50}) async {
    if (hasInvestmentSweepForCurrentMonth) return;
    final unspent = math.max(0.0, monthlySurplus);
    final amount = unspent * percentage.clamp(0, 100) / 100;
    if (amount <= 0) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.timeDeposit);
    investmentBalance += amount;
    d1Ledger.insert(0, {
      'type': 'investment_sweep',
      'date': DateTime.now().toIso8601String(),
      'monthKey': currentInvestmentSweepMonthKey,
      'unspentAmount': unspent,
      'percentage': percentage,
      'amount': amount,
      'destination': 'Investment Portfolio',
    });
    await saveProfile();
    notifyListeners();
  }

  double get lifestyleReservedThisMonth =>
      _currentMonthLedgerTotal({'lifestyle_subscription_reserve'});

  double get lifestylePaydayContributionsThisMonth =>
      _currentMonthLedgerTotal({'lifestyle_payday'});

  double get lifestyleActivityContributionsThisMonth =>
      _currentMonthLedgerTotal({'lifestyle_activity_deposit'});

  double _currentMonthLedgerTotal(Set<String> types) {
    final now = DateTime.now();
    return d1Ledger.where((entry) {
      if (!types.contains(entry['type'])) return false;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      return date != null && date.year == now.year && date.month == now.month;
    }).fold<double>(
      0,
      (total, entry) => total + ((entry['amount'] as num?)?.toDouble() ?? 0),
    );
  }

  bool hasLifestylePaydayAllocation(String transactionId) => d1Ledger.any(
        (entry) =>
            entry['type'] == 'lifestyle_payday' &&
            entry['sourceTransactionId'] == transactionId,
      );

  DateTime? get lifestyleActivityStartedAt {
    DateTime? earliest;
    for (final entry in d1Ledger) {
      if (entry['type'] != 'lifestyle_activity_deposit') continue;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      if (date != null && (earliest == null || date.isBefore(earliest))) {
        earliest = date;
      }
    }
    return earliest;
  }

  Future<void> depositLifestyleSubscriptionReserve(double amount) async {
    if (amount <= 0) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.personalGoal);
    lifestyleFundBalance += amount;
    d1Ledger.insert(0, {
      'type': 'lifestyle_subscription_reserve',
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'destination': 'Lifestyle Fund',
      'label': 'Subscriptions and memberships reserve',
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> depositLifestylePayday({
    required String transactionId,
    required double amount,
    required DateTime incomeDate,
  }) async {
    if (amount <= 0 || hasLifestylePaydayAllocation(transactionId)) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.personalGoal);
    lifestyleFundBalance += amount;
    d1Ledger.insert(0, {
      'type': 'lifestyle_payday',
      'date': DateTime.now().toIso8601String(),
      'sourceDate': incomeDate.toIso8601String(),
      'sourceTransactionId': transactionId,
      'amount': amount,
      'destination': 'Everyday Enjoyment Fund',
      'label': 'Payday enjoyment contribution',
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> depositLifestyleActivity(double amount) async {
    if (amount <= 0) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.personalGoal);
    lifestyleActivityBalance += amount;
    d1Ledger.insert(0, {
      'type': 'lifestyle_activity_deposit',
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'destination': 'Hobby or Activity Fund',
      'label': 'Hobby or activity contribution',
    });
    await saveProfile();
    notifyListeners();
  }

  void logD1Income({
    required double amount,
    required double essentialPct,
    required double billsAmt,
    required double emergencyPct,
  }) {
    final essential = amount * essentialPct / 100;
    final bills = math.min(billsAmt, amount);
    final emergency = amount * emergencyPct / 100;
    essentialExpensesBalance += essential;
    billsObligationsBalance += bills;
    emergencyFundBalance += emergency;
    d1Ledger.insert(0, {
      'type': 'income',
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'essential': essential,
      'bills': bills,
      'emergency': emergency,
    });
    notifyListeners();
  }

  Future<void> useD1BucketFunds(String bucket, double amount) async {
    if (amount <= 0) return;
    switch (bucket) {
      case 'essential':
        essentialExpensesBalance =
            math.max(0, essentialExpensesBalance - amount);
      case 'bills':
        billsObligationsBalance = math.max(0, billsObligationsBalance - amount);
      case 'emergency':
        emergencyFundBalance = math.max(0, emergencyFundBalance - amount);
        _lastEfWithdrawalStr = DateTime.now().toIso8601String();
    }
    d1Ledger.insert(0, {
      'type': 'use_$bucket',
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> replenishD1EmergencyFund(double amount) async {
    if (amount <= 0 || amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(amount, FakeMayaGoalAccount.savings);
    emergencyFundBalance += math.min(
      amount,
      pendingRecordedEmergencyReplenishment,
    );
    _lastEfWithdrawalStr = null;
    d1Ledger.insert(0, {
      'type': 'ef_replenish',
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> _moveFakeMayaWalletTo(
      double amount, FakeMayaGoalAccount account) async {
    final link = fakeMayaLink;
    if (link == null || amount <= 0) return;
    final session = await FakeMayaService.allocateFromWallet(
      link: link,
      amount: amount,
      account: account,
    );
    final savedById = {
      for (final transaction in link.summary.transactions)
        transaction.transactionId: transaction,
    };
    final transactions = session.summary.transactions.map((transaction) {
      final saved = savedById[transaction.transactionId];
      return saved != null && saved.isLabeled
          ? transaction.withLabelFrom(saved)
          : transaction;
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
      summary: session.summary.copyWith(transactions: transactions),
    ));
    _syncFakeMayaMoneyItems();
  }

  void acceptAppPermissions({required bool notificationGranted}) {
    notificationsAllowed = notificationGranted;
    thirdPartyDataLinkingAllowed = true;
    automaticDataGatheringAllowed = true;
    notifyListeners();
  }

  Future<bool> enableTransactionReminders() async {
    final granted =
        await ShellbyNotificationService.instance.requestPermission();
    notificationsAllowed = granted;
    if (granted) {
      await ShellbyNotificationService.instance
          .scheduleDailyReminders(notificationReminderMinutes);
    }
    if (isSignedIn) await saveProfile();
    notifyListeners();
    return granted;
  }

  Future<void> setTransactionRemindersEnabled(bool enabled) async {
    if (enabled) {
      await enableTransactionReminders();
      return;
    }
    notificationsAllowed = false;
    await ShellbyNotificationService.instance.cancelReminders();
    if (isSignedIn) await saveProfile();
    notifyListeners();
  }

  Future<void> setNotificationReminderTimes(List<int> minutes) async {
    notificationReminderMinutes
      ..clear()
      ..addAll(minutes.map((value) => value.clamp(0, 1439)).toSet())
      ..sort();
    if (notificationsAllowed) {
      await ShellbyNotificationService.instance
          .scheduleDailyReminders(notificationReminderMinutes);
    }
    if (isSignedIn) await saveProfile();
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
      ..addAll(actionIds);
    emotionalLogsEnabled = enableEmotionalLogs;
    stressIndicatorsEnabled = enableStressIndicators;
    notifyListeners();
  }

  /// Additive variant used when a goal is added after onboarding (e.g. via
  /// "+ Add Goal" on the Goals page) — unlike [configureGoalActions], this
  /// must NOT clear existing selections or it would wipe out the actions
  /// belonging to goals the user already has.
  void addActionsForGoal(Iterable<String> actionIds) {
    selectedActionIds.addAll(actionIds);
    notifyListeners();
  }

  /// Explicitly marks a canonical goal as added via "+ Add Goal". Kept
  /// separate from action-selection overlap checks so that goals sharing
  /// an action id with another goal's catalog can't falsely appear added.
  void addUnlockedGoal(String goalId) {
    addedGoalIds.add(goalId);
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
    cashFlowExpenses
      ..clear()
      ..addAll(expenses);
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
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 3),
          type: JarEventType.income,
          needsIn: 7000,
          needsOut: 0,
          bufferIn: 3000,
          bufferOut: 0,
          sentence:
              '${money(10000)} in → ${money(7000)} Needs · ${money(3000)} Buffer · ${money(1000)} → Shield'),
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 10),
          type: JarEventType.income,
          needsIn: 5000,
          needsOut: 0,
          bufferIn: 4000,
          bufferOut: 0,
          sentence:
              '${money(9000)} in → ${money(5000)} Needs (full!) · ${money(4000)} Buffer · ${money(900)} → Shield'),
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 15),
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: 3500,
          bufferIn: 0,
          bufferOut: 0,
          sentence: '${money(3500)} bill paid from Needs'),
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 22),
          type: JarEventType.income,
          needsIn: 3500,
          needsOut: 0,
          bufferIn: 4500,
          bufferOut: 0,
          sentence:
              '${money(8000)} in → ${money(3500)} Needs · ${money(4500)} Buffer · ${money(800)} → Shield'),
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 28),
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: 12000,
          bufferIn: 0,
          bufferOut: 3000,
          sentence:
              '${money(15000)} bill → ${money(12000)} Needs + ${money(3000)} Buffer (tapped!)'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 2),
          type: JarEventType.income,
          needsIn: 8400,
          needsOut: 0,
          bufferIn: 3600,
          bufferOut: 0,
          sentence:
              '${money(12000)} in → ${money(8400)} Needs · ${money(3600)} Buffer · ${money(1200)} → Shield'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 8),
          type: JarEventType.income,
          needsIn: 3600,
          needsOut: 0,
          bufferIn: 6400,
          bufferOut: 0,
          sentence:
              '${money(10000)} in → ${money(3600)} Needs (full!) · ${money(6400)} Buffer · ${money(1000)} → Shield · Case 1'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 12),
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: 4500,
          bufferIn: 0,
          bufferOut: 0,
          sentence: '${money(4500)} bill paid from Needs'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 18),
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: 7500,
          bufferIn: 0,
          bufferOut: 9000,
          sentence:
              '${money(16500)} emergency bill → Needs + Buffer tapped (₱9K from Buffer)'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 22),
          type: JarEventType.income,
          needsIn: 6300,
          needsOut: 0,
          bufferIn: 2700,
          bufferOut: 0,
          sentence:
              '${money(9000)} in → ${money(6300)} Needs · ${money(2700)} Buffer · ${money(900)} → Shield'),
    ];

    needsBalance = 0;
    bufferBalance = 0;
    for (final e in jarEvents) {
      needsBalance = math.min(
          math.max(0, needsBalance + e.needsIn - e.needsOut), needsTarget);
      bufferBalance = math.max(0, bufferBalance + e.bufferIn - e.bufferOut);
    }
    jarLedger
      ..clear()
      ..addAll(jarEvents.reversed);

    // Shield — partially funded at ~4,700 (< 1 month of 12K target).
    // Shows cross-alert: buffer was tapped AND shield is low.
    shieldTrackedBalance = 4700;
    shieldLedger
      ..clear()
      ..addAll([
        ShieldEvent(
            timestamp: DateTime(lm.year, lm.month, 5),
            amount: 1000,
            sentence: '+${money(1000)} deposited to Safety Shield'),
        ShieldEvent(
            timestamp: DateTime(lm.year, lm.month, 12),
            amount: 900,
            sentence: '+${money(900)} deposited to Safety Shield'),
        ShieldEvent(
            timestamp: DateTime(lm.year, lm.month, 25),
            amount: 800,
            sentence: '+${money(800)} deposited to Safety Shield'),
        ShieldEvent(
            timestamp: DateTime(cm.year, cm.month, 4),
            amount: 1200,
            sentence: '+${money(1200)} deposited to Safety Shield'),
        ShieldEvent(
            timestamp: DateTime(cm.year, cm.month, 10),
            amount: 800,
            sentence: '+${money(800)} deposited to Safety Shield'),
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
    final cm = DateTime(now.year, now.month); // current month

    // Events in chronological order (oldest first). Replayed to compute balances.
    final events = [
      // ── Last month ──────────────────────────────────────────────────────
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 3),
          type: JarEventType.income,
          needsIn: 7000,
          needsOut: 0,
          bufferIn: 3000,
          bufferOut: 0,
          sentence:
              '${money(10000)} in → ${money(7000)} Needs, ${money(3000)} Buffer'),
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 10),
          type: JarEventType.income,
          needsIn: 5000,
          needsOut: 0,
          bufferIn: 4000,
          bufferOut: 0,
          sentence:
              '${money(9000)} in → ${money(5000)} Needs, ${money(4000)} Buffer · Needs full! 🎉'),
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 15),
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: 3500,
          bufferIn: 0,
          bufferOut: 0,
          sentence: '${money(3500)} bill paid from Needs'),
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 22),
          type: JarEventType.income,
          needsIn: 3500,
          needsOut: 0,
          bufferIn: 4500,
          bufferOut: 0,
          sentence:
              '${money(8000)} in → ${money(3500)} Needs (filled!), ${money(4500)} Buffer'),
      JarEvent(
          timestamp: DateTime(lm.year, lm.month, 28),
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: 12000,
          bufferIn: 0,
          bufferOut: 3000,
          sentence:
              '${money(15000)} bill → ${money(12000)} Needs + ${money(3000)} Buffer'),
      // ── Current month ───────────────────────────────────────────────────
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 2),
          type: JarEventType.income,
          needsIn: 8400,
          needsOut: 0,
          bufferIn: 3600,
          bufferOut: 0,
          sentence:
              '${money(12000)} in → ${money(8400)} Needs, ${money(3600)} Buffer'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 8),
          type: JarEventType.income,
          needsIn: 3600,
          needsOut: 0,
          bufferIn: 6400,
          bufferOut: 0,
          sentence:
              '${money(10000)} in → ${money(3600)} Needs (filled!), ${money(6400)} Buffer · Case 1'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 12),
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: 4500,
          bufferIn: 0,
          bufferOut: 0,
          sentence: '${money(4500)} bill paid from Needs'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 18),
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: 7500,
          bufferIn: 0,
          bufferOut: 9000,
          sentence:
              '${money(16500)} bill → ${money(7500)} Needs + ${money(9000)} Buffer · shortfall'),
      JarEvent(
          timestamp: DateTime(cm.year, cm.month, 22),
          type: JarEventType.income,
          needsIn: 6300,
          needsOut: 0,
          bufferIn: 2700,
          bufferOut: 0,
          sentence:
              '${money(9000)} in → ${money(6300)} Needs, ${money(2700)} Buffer'),
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
    final idx = jarLedger.indexWhere((e) => e.type == JarEventType.income);
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
    Iterable<String>? syncedAccounts,
  }) async {
    final session = await FakeMayaService.signInWithEmail(
      email: email,
      password: password,
    );
    fakeMayaLink = FakeMayaLink.fromSession(session);
    fakeMayaSyncedAccounts
      ..clear()
      ..addAll(syncedAccounts ?? manualAccountBalances.keys);
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
    required String source,
    String? subcategory,
    String? tag,
    String? note,
    bool excludedFromInsights = false,
  }) async {
    final manualIndex = manualTransactions.indexWhere(
      (transaction) => transaction.transactionId == transactionId,
    );
    if (manualIndex >= 0) {
      final labeled = manualTransactions[manualIndex].copyWithLabel(
        category: category,
        source: source,
        subcategory: subcategory,
        tag: tag,
        note: note,
        excludedFromInsights: excludedFromInsights,
      );
      manualTransactions[manualIndex] = labeled;
      if (excludedFromInsights) {
        transactionLabelRules.remove(labeled.patternKey);
      } else {
        transactionLabelRules[labeled.patternKey] =
            TransactionLabelRule.fromTransaction(labeled);
      }
      if (isSignedIn) await saveProfile();
      notifyListeners();
      return;
    }
    final link = fakeMayaLink;
    if (link == null) return;
    final target = link.summary.transactions
        .where((transaction) => transaction.transactionId == transactionId)
        .firstOrNull;
    if (target == null) return;
    final labeledTarget = target.copyWithLabel(
      category: category,
      source: source,
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
    // Auto-record bills funded from Basic Needs in the two-jar goal.
    if (source.trim().toLowerCase() == 'basic needs fund' &&
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

  Future<void> addManualCashTransaction({
    required String title,
    required String detail,
    required double amount,
    required DateTime occurredAt,
    required String category,
    required String source,
    String? subcategory,
    String? tag,
    String? note,
    String account = 'Cash on Hand',
  }) async {
    if (amount == 0) return;
    final balance = accountBalance(account);
    if (amount < 0 && amount.abs() > balance) {
      throw StateError('Not enough money in $account for this transaction.');
    }
    final id = 'manual-${occurredAt.microsecondsSinceEpoch}';
    manualTransactions.add(
      FakeMayaTransaction(
        id: id,
        title: title.trim(),
        detail: detail.trim().isEmpty ? 'Manual entry' : detail.trim(),
        age: 'Just now',
        amountText: '${amount < 0 ? '-' : '+'} ${money(amount.abs())}',
        createdAt: occurredAt,
        category: category,
        source: source,
        account: account,
        subcategory: subcategory,
        tag: tag,
        note: note,
        labeledAt: DateTime.now(),
      ),
    );
    if (account == 'Cash on Hand') {
      cashOnHandBalance += amount;
    } else {
      manualAccountBalances[account] =
          (manualAccountBalances[account] ?? 0) + amount;
    }
    if (isSignedIn) await saveProfile();
    notifyListeners();
  }

  Future<void> unlinkFakeMayaAccount() async {
    fakeMayaLink = null;
    fakeMayaSyncedAccounts.clear();
    _removeFakeMayaMoneyItems();
    await saveProfile();
    notifyListeners();
  }

  Future<void> setAccountFakeMayaSync(String account, bool synced) async {
    if (synced && fakeMayaLink == null) return;
    if (synced) {
      fakeMayaSyncedAccounts.add(account);
    } else {
      fakeMayaSyncedAccounts.remove(account);
    }
    _syncFakeMayaMoneyItems();
    if (isSignedIn) await saveProfile();
    notifyListeners();
  }

  void _syncFakeMayaMoneyItems() {
    _removeFakeMayaMoneyItems();
    final link = fakeMayaLink;
    if (link == null) return;
    assets.addAll(
      link.summary
          .toMoneyItems()
          .where((item) => fakeMayaSyncedAccounts.contains(item.name)),
    );
    savings = accountBalance('Savings') +
        accountBalance('Time Deposit') +
        accountBalance('Goal Savings');
  }

  void _removeFakeMayaMoneyItems() {
    assets.removeWhere((item) => item.description.contains('FakeMaya'));
  }
}

class TransactionLabelRule {
  const TransactionLabelRule({
    required this.category,
    required this.source,
    this.subcategory,
    this.tag,
    this.note,
  });

  final String category;
  final String source;
  final String? subcategory;
  final String? tag;
  final String? note;

  factory TransactionLabelRule.fromTransaction(
    FakeMayaTransaction transaction,
  ) {
    return TransactionLabelRule(
      category: transaction.category!,
      source: transaction.automaticDestination ??
          transaction.source ??
          'Basic Needs Fund',
      subcategory: transaction.subcategory,
      tag: transaction.tag,
    );
  }

  FakeMayaTransaction applyTo(FakeMayaTransaction transaction) {
    return transaction.copyWithLabel(
      category: category,
      source: transaction.automaticDestination ?? source,
      subcategory: subcategory,
      tag: tag,
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category,
        'source': source,
        'subcategory': subcategory,
        'tag': tag,
        'note': note,
      };

  factory TransactionLabelRule.fromMap(Map<String, dynamic> data) {
    return TransactionLabelRule(
      category: data['category'] as String? ?? 'Other expense',
      source: data['source'] as String? ?? 'Basic Needs Fund',
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

class ActionStageResult {
  const ActionStageResult({
    required this.summary,
    required this.firstChange,
    required this.suggestions,
  });

  final String summary;
  final String firstChange;
  final List<ActionStageSuggestion> suggestions;
}

class ActionStageSuggestion {
  const ActionStageSuggestion({
    required this.option,
    required this.actionId,
    required this.actionText,
    required this.priority,
    required this.reason,
    required this.target,
    required this.replacementActionId,
  });

  final String option;
  final String actionId;
  final String actionText;
  final int priority;
  final String reason;
  final Map<String, String> target;
  final String? replacementActionId;
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

enum ExpenseLayer {
  basicNeeds,
  emergencyInsurance,
  debtInvestments,
  nonEssentials,
}

extension ExpenseLayerDetails on ExpenseLayer {
  String get label => switch (this) {
        ExpenseLayer.basicNeeds => 'Basic Needs',
        ExpenseLayer.emergencyInsurance => 'Emergency / Insurance',
        ExpenseLayer.debtInvestments => 'Debt / Investments',
        ExpenseLayer.nonEssentials => 'Non-Essentials',
      };

  String get examples => switch (this) {
        ExpenseLayer.basicNeeds => 'Electricity, water, rent, food, transport',
        ExpenseLayer.emergencyInsurance =>
          'Insurance premiums, hospital and medical bills',
        ExpenseLayer.debtInvestments =>
          'Credit card, loan payments, investment contributions',
        ExpenseLayer.nonEssentials =>
          'Subscriptions, memberships, entertainment',
      };
}

ExpenseLayer? expenseLayerFromValue(Object? value) {
  final name = value?.toString();
  return ExpenseLayer.values.where((layer) => layer.name == name).firstOrNull;
}

ExpenseLayer expenseLayerForLedger(Map<String, dynamic> expense) {
  return expenseLayerFromValue(expense['expenseType'] ?? expense['layer']) ??
      ((expense['essential'] as bool? ?? false)
          ? ExpenseLayer.basicNeeds
          : ExpenseLayer.nonEssentials);
}

class CashFlowExpense {
  CashFlowExpense(
    this.name,
    this.budget, {
    this.layer = ExpenseLayer.basicNeeds,
  });
  String name;
  double budget;
  ExpenseLayer layer;

  Map<String, dynamic> toMap() => {
        'name': name,
        'budget': budget,
        'expenseType': layer.name,
      };

  static CashFlowExpense fromMap(Map<String, dynamic> m) {
    return CashFlowExpense(
      m['name'] as String? ?? '',
      (m['budget'] as num?)?.toDouble() ?? 0,
      layer: expenseLayerFromValue(m['expenseType'] ?? m['layer']) ??
          ExpenseLayer.basicNeeds,
    );
  }
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
        timestamp: DateTime.tryParse(data['timestamp'] as String? ?? '') ??
            DateTime.now(),
        amount: _num(data['amount']),
        sentence: data['sentence'] as String? ?? '',
      );

  static double _num(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}
