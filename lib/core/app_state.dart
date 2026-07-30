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
  String industry = '';
  String employmentStatus = '';
  String incomeType = '';
  String incomeRhythm = '';
  String billsRhythm = '';
  String checkInRhythm = '';
  String location = '';
  String responsibility = '';
  String primaryConcern = '';
  String motivation = '';
  String reflectedMotivation = '';
  String chatSurfaceSummary = '';
  String chatGoalFocusSummary = '';
  String chatTimeframeSummary = '';
  String chatDifficultySummary = '';
  String chatSituationsSummary = '';
  String chatChallengesSummary = '';
  String selectedGoalId = '';
  String selectedGoal = '';
  String selectedGoalDescription = '';
  double selectedGoalMonthlyTarget = 0;
  String socialStructure = '';
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
  bool consentAi = false;
  bool consentBenchmarking = false;
  bool consentCommunity = false;
  bool consentTrustedCircle = false;
  bool notificationsAllowed = false;
  final List<int> notificationReminderMinutes = [20 * 60];
  bool thirdPartyDataLinkingAllowed = false;
  bool automaticDataGatheringAllowed = false;

  /// Granted the moment a user links FakeMaya — the blanket permission to
  /// auto-create matching personal-goal buckets in their Maya account as
  /// they add goals in Shellby. Individual bucket creations are still
  /// reconfirmed per motivation (see [confirmedFakeMayaBucketMotivations]).
  bool fakeMayaBucketCreationAllowed = false;

  /// Motivations the user has already agreed to create a FakeMaya bucket
  /// for, so we don't re-ask every time the same goal/motivation is
  /// revisited. Populated by `ensureFakeMayaBucketForMotivation`.
  final Set<String> confirmedFakeMayaBucketMotivations = {};
  bool personalDataConsent = false;
  bool dataRetentionConsent = false;
  bool emotionalLogsEnabled = false;
  bool stressIndicatorsEnabled = false;
  FakeMayaLink? fakeMayaLink;
  bool mockDataEnabled = false;
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
  final List<Map<String, dynamic>> billObligations = [];
  // Up to 3 named hobby/activity targets for A29 (each: id, name, target,
  // months, createdAt). Per-hobby saved balances are derived from d1Ledger
  // 'lifestyle_hobby_deposit' entries tagged with a matching hobbyId, the
  // same "derive from the ledger" pattern used across the rest of AppState.
  final List<Map<String, dynamic>> lifestyleHobbies = [];

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
  double get investmentPortfolioValue =>
      investmentBalance + (fakeMayaLink?.summary.investmentHoldingsValue ?? 0);
  List<Map<String, dynamic>> get openBillObligations => billObligations
      .where((bill) => _billRemaining(bill) > 0)
      .toList()
    ..sort((a, b) {
      final aDue =
          DateTime.tryParse(a['dueDate']?.toString() ?? '') ?? DateTime(9999);
      final bDue =
          DateTime.tryParse(b['dueDate']?.toString() ?? '') ?? DateTime(9999);
      return aDue.compareTo(bDue);
    });
  List<Map<String, dynamic>> get openBasicNeedsBillObligations =>
      openBillObligations
          .where(
              (bill) => expenseLayerForLedger(bill) == ExpenseLayer.basicNeeds)
          .toList();
  double get openBasicNeedsBillNeed => openBasicNeedsBillObligations.fold(
        0,
        (total, bill) => total + _billRemaining(bill),
      );

  final List<Map<String, dynamic>> d1Ledger = [];
  final Set<String> trackingVariables = {};
  final Set<String> interferingVariables = {};
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
        if (fakeMayaLink?.summary.creditBillTransaction != null)
          fakeMayaLink!.summary.creditBillTransaction!,
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
  bool accountExistsInFakeMaya(String account) {
    final summary = fakeMayaLink?.summary;
    if (summary == null) return true;
    return switch (account) {
      'Goal Savings' => summary.personalGoals.isNotEmpty,
      _ => true,
    };
  }

  bool fakeMayaBucketExists(String bucketId) {
    final summary = fakeMayaLink?.summary;
    if (summary == null) return true;
    return summary.personalGoalById(bucketId) != null;
  }

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
  // Emergency Fund deposits go straight into their own FakeMaya personal-goal
  // bucket (see `depositIncomeToEmergencyFund`), not into Savings, so no
  // Emergency Fund amount needs to be backed out here anymore.
  double get unallocatedFakeMayaSavings => accountBalance('Savings');

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
    await _refreshLinkedAccountsAfterSignIn();
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
      if (onboardingComplete) await _refreshLinkedAccountsAfterSignIn();
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
    await _refreshLinkedAccountsAfterSignIn();
    await saveProfile();
    notifyListeners();
  }

  Future<void> _refreshLinkedAccountsAfterSignIn() async {
    _syncFakeMayaMoneyItems();
    if (fakeMayaLink == null) return;
    try {
      await refreshFakeMayaAccount();
    } on FakeMayaException catch (error) {
      debugPrint('FakeMaya refresh after login failed: $error');
      _syncFakeMayaMoneyItems();
    } catch (error) {
      debugPrint('Linked account refresh after login failed: $error');
      _syncFakeMayaMoneyItems();
    }
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

  Future<void> beginFreshOnboardingDraft() async {
    if (isSignedIn && !onboardingComplete) {
      await FirebaseProfileService.signOut();
    }
    _resetOnboardingDraftState();
    notifyListeners();
  }

  Future<void> saveProfile({bool markOnboardingComplete = false}) async {
    final user = FirebaseProfileService.currentUser;
    if (user == null) return;
    if (!markOnboardingComplete && !onboardingComplete) return;
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
    _resetOnboardingDraftState();
    _removeFakeMayaMoneyItems();
    notifyListeners();
  }

  void _resetOnboardingDraftState() {
    uid = null;
    name = '';
    email = '';
    _pendingAccountEmail = null;
    _pendingAccountPassword = null;
    _pendingGoogleAccount = false;
    photoUrl = null;
    mockDataEnabled = false;
    onboardingComplete = false;
    age = '';
    occupation = '';
    industry = '';
    employmentStatus = '';
    incomeType = '';
    incomeRhythm = '';
    billsRhythm = '';
    checkInRhythm = '';
    location = '';
    responsibility = '';
    primaryConcern = '';
    motivation = '';
    reflectedMotivation = '';
    chatSurfaceSummary = '';
    chatGoalFocusSummary = '';
    chatTimeframeSummary = '';
    chatDifficultySummary = '';
    chatSituationsSummary = '';
    chatChallengesSummary = '';
    selectedGoalId = '';
    selectedGoal = '';
    selectedGoalDescription = '';
    selectedGoalMonthlyTarget = 0;
    socialStructure = '';
    confidence = 5;
    anxiety = 5;
    avoidance = 5;
    peerPressure = 5;
    income = 0;
    expenses = 0;
    variableExpenses = 0;
    savings = 0;
    emergencyMonths = 0;
    debtPayments = 0;
    investments = 0;
    subscriptions = 0;
    monthlySalary = 0;
    irregularIncomeFloor = 0;
    basicNeedsMonthlyTarget = 0;
    basicNeedsAllocationPercent = 0.50;
    bufferAllocationPercent = 0.20;
    needsTarget = 0;
    needsBalance = 0;
    bufferBalance = 0;
    needsPercent = 70;
    jarLedger.clear();
    cashFlowExpenses.clear();
    financialSafetyBalance = 0;
    safetyShieldAllocationPercent = 0;
    safetyShieldTargetMonths = 0;
    shieldTrackedBalance = 0;
    shieldLedger.clear();
    salaryWeekOfMonth = 1;
    salaryWeekday = DateTime.friday;
    consentBaseline = true;
    consentAi = false;
    consentBenchmarking = false;
    consentCommunity = false;
    consentTrustedCircle = false;
    notificationsAllowed = false;
    notificationReminderMinutes
      ..clear()
      ..add(20 * 60);
    thirdPartyDataLinkingAllowed = false;
    automaticDataGatheringAllowed = false;
    fakeMayaBucketCreationAllowed = false;
    confirmedFakeMayaBucketMotivations.clear();
    personalDataConsent = false;
    dataRetentionConsent = false;
    emotionalLogsEnabled = false;
    stressIndicatorsEnabled = false;
    fakeMayaLink = null;
    cashOnHandBalance = 0;
    manualAccountBalances
      ..clear()
      ..addAll({
        'Wallet': 0,
        'Savings': 0,
        'Time Deposit': 0,
        'Goal Savings': 0,
      });
    fakeMayaSyncedAccounts.clear();
    manualTransactions.clear();
    transactionLabelRules.clear();
    planAdjustmentActions.clear();
    anxietyCheckIns.clear();
    allocatedThisCycle = 0;
    goalBucketOverrides.clear();
    selectedActionIds.clear();
    addedGoalIds.clear();
    actionFieldValues.clear();
    categorySpendingBudgets.clear();
    onboardingBaselines.clear();
    onboardingIncomeLedger.clear();
    onboardingExpenseLedger.clear();
    essentialExpensesBalance = 0;
    billsObligationsBalance = 0;
    emergencyFundBalance = 0;
    investmentBalance = 0;
    lifestyleFundBalance = 0;
    lifestyleActivityBalance = 0;
    _lastEfWithdrawalStr = null;
    billObligations.clear();
    lifestyleHobbies.clear();
    messages
      ..clear()
      ..add(
        ChatMessage(
          false,
          "I'm Shellby. If you could achieve one financial milestone in the next 12 months, what would it be?",
        ),
      );
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

  void seedEmergencyFundMockDataForTesting() {
    email = 'emergency@gmail.com';
    _applyEmergencyFundMockProfile(null);
  }

  void seedCashFlowMockDataForTesting() {
    email = 'cashflow@gmail.com';
    _applyCashFlowMockProfile(null);
  }

  void seedAccumulatingWealthMockDataForTesting() {
    email = 'accumulating@gmail.com';
    _applyAccumulatingWealthMockProfile(null);
  }

  void seedFinancialFreedomMockDataForTesting() {
    email = 'freedom@gmail.com';
    _applyFinancialFreedomMockProfile(null);
  }

  void seedMainMockDataForTesting() {
    email = 'main@gmail.com';
    _applyMainMockProfile(null);
  }

  bool get canOverwriteWithMockData {
    final normalizedEmail = email.trim().toLowerCase();
    return normalizedEmail == 'cashflow@gmail.com' ||
        normalizedEmail == 'emergency@gmail.com' ||
        normalizedEmail == 'accumulating@gmail.com' ||
        normalizedEmail == 'freedom@gmail.com' ||
        normalizedEmail == 'main@gmail.com' ||
        selectedGoalId == 'G1' ||
        selectedGoalId == 'G3' ||
        selectedGoalId == 'G5' ||
        selectedGoalId == 'G8';
  }

  Future<void> overwriteWithMockData() async {
    await setMockDataEnabled(true);
  }

  Future<void> setMockDataEnabled(bool enabled) async {
    if (!canOverwriteWithMockData) {
      throw StateError(
          'Mock overwrite is only available for supported saved goal accounts right now.');
    }
    if (!enabled) {
      mockDataEnabled = false;
      await saveProfile();
      notifyListeners();
      return;
    }
    final user = FirebaseProfileService.currentUser;
    final normalizedEmail = (user?.email ?? email).trim().toLowerCase();
    if (normalizedEmail == 'main@gmail.com') {
      _applyMainMockProfile(user);
    } else if (normalizedEmail == 'cashflow@gmail.com' ||
        selectedGoalId == 'G1') {
      _applyCashFlowMockProfile(user);
    } else if (normalizedEmail == 'accumulating@gmail.com' ||
        selectedGoalId == 'G5') {
      _applyAccumulatingWealthMockProfile(user);
    } else if (normalizedEmail == 'freedom@gmail.com' ||
        selectedGoalId == 'G8') {
      _applyFinancialFreedomMockProfile(user);
    } else {
      _applyEmergencyFundMockProfile(user);
    }
    mockDataEnabled = true;
    await saveProfile(markOnboardingComplete: true);
    notifyListeners();
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
        'A26': {'amt': '2100'},
        'A27': {'amt': '1200'},
        'A28': {'amt': '1500'},
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
    lifestyleFundBalance = 13400;
    lifestyleActivityBalance = 0;
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
    final freedomWeekStart = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
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
      // Personal Lifestyle Fund: 6 months of subscription-reserve + payday
      // contributions, so the Financial Freedom insights page's monthly
      // contributions chart has a real trend instead of one data point.
      for (final entry in const [
        (155, 1000.0, 900.0),
        (125, 1100.0, 1000.0),
        (95, 1200.0, 1100.0),
        (65, 1150.0, 1050.0),
        (35, 1300.0, 1200.0),
      ]) ...[
        {
          'type': 'lifestyle_subscription_reserve',
          'date': today.subtract(Duration(days: entry.$1)).toIso8601String(),
          'amount': entry.$2,
          'destination': 'Personal Lifestyle Fund',
          'label': 'Subscriptions and memberships reserve',
        },
        {
          'type': 'lifestyle_payday',
          'date':
              today.subtract(Duration(days: entry.$1 - 2)).toIso8601String(),
          'amount': entry.$3,
          'destination': 'Personal Lifestyle Fund',
          'label': 'Payday enjoyment contribution',
        },
      ],
      {
        'type': 'lifestyle_subscription_reserve',
        'date': recent.subtract(const Duration(days: 1)).toIso8601String(),
        'amount': 1200.0,
        'destination': 'Personal Lifestyle Fund',
        'label': 'Subscriptions and memberships reserve',
      },
      {
        'type': 'lifestyle_payday',
        'date': earlierThisMonth.add(const Duration(days: 2)).toIso8601String(),
        'sourceDate': earlierThisMonth.toIso8601String(),
        'sourceTransactionId': 'income-9',
        'amount': 1200.0,
        'destination': 'Personal Lifestyle Fund',
        'label': 'Payday enjoyment contribution',
      },
      // Hobby/activity targets: 3 named hobbies at different progress
      // levels (near-complete, mid-way, just started) so the Target Funds
      // card has explorable variety.
      for (final entry in const [
        ('hobby_demo_1', 150, 3000.0),
        ('hobby_demo_1', 100, 3500.0),
        ('hobby_demo_1', 50, 2500.0),
        ('hobby_demo_1', 10, 2000.0),
        ('hobby_demo_2', 90, 3000.0),
        ('hobby_demo_2', 45, 2500.0),
        ('hobby_demo_2', 15, 2500.0),
        ('hobby_demo_3', 20, 700.0),
        ('hobby_demo_3', 5, 500.0),
      ])
        {
          'type': 'lifestyle_hobby_deposit',
          'date': today.subtract(Duration(days: entry.$2)).toIso8601String(),
          'hobbyId': entry.$1,
          'amount': entry.$3,
          'destination': 'Personal Lifestyle Fund',
          'label': 'Hobby or activity contribution',
        },
    ]);
    lifestyleHobbies
      ..clear()
      ..addAll([
        {
          'id': 'hobby_demo_1',
          'name': 'Photography Gear',
          'target': 15000.0,
          'months': 6,
          'createdAt':
              today.subtract(const Duration(days: 160)).toIso8601String(),
        },
        {
          'id': 'hobby_demo_2',
          'name': 'Weekend Trips',
          'target': 20000.0,
          'months': 12,
          'createdAt':
              today.subtract(const Duration(days: 95)).toIso8601String(),
        },
        {
          'id': 'hobby_demo_3',
          'name': 'Guitar Lessons',
          'target': 6000.0,
          'months': 4,
          'createdAt':
              today.subtract(const Duration(days: 25)).toIso8601String(),
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
      // Prior weeks' everyday-enjoyment spending, mixing under- and
      // over-limit weeks so the weekly spend trend bars on the Financial
      // Freedom insights page have real variation to show.
      _demoTransaction(
        id: 'lifestyle-week1-dinner',
        title: 'Paid merchant',
        detail: 'To: Weekend restaurant',
        amount: -2100,
        date: freedomWeekStart.subtract(const Duration(days: 4)),
        category: 'Entertainment',
        source: 'Lifestyle Fund',
      ),
      _demoTransaction(
        id: 'lifestyle-week2-concert',
        title: 'Paid merchant',
        detail: 'To: Concert tickets',
        amount: -700,
        date: freedomWeekStart.subtract(const Duration(days: 11)),
        category: 'Entertainment',
        source: 'Lifestyle Fund',
      ),
      _demoTransaction(
        id: 'lifestyle-week2-cafe',
        title: 'Paid merchant',
        detail: 'To: Cafe',
        amount: -500,
        date: freedomWeekStart.subtract(const Duration(days: 9)),
        category: 'Food & drink',
        source: 'Lifestyle Fund',
      ),
      _demoTransaction(
        id: 'lifestyle-week3-hobby',
        title: 'Paid merchant',
        detail: 'To: Hobby supplies',
        amount: -900,
        date: freedomWeekStart.subtract(const Duration(days: 18)),
        category: 'Entertainment',
        source: 'Lifestyle Fund',
      ),
      _demoTransaction(
        id: 'lifestyle-week4-travel',
        title: 'Paid merchant',
        detail: 'To: Weekend trip',
        amount: -1700,
        date: freedomWeekStart.subtract(const Duration(days: 25)),
        category: 'Travel',
        source: 'Lifestyle Fund',
      ),
    ]);
    // Emergency Fund: three weeks of recent weekly contributions, so the
    // Emergency Fund insights page (weekly movement chart, coverage
    // milestones, months-covered stat) has visible recent data to show.
    final efWeek3 = today.subtract(const Duration(days: 20));
    final efWeek2 = today.subtract(const Duration(days: 13));
    final efWeek1 = today.subtract(const Duration(days: 6));
    const efWeek3Amount = 1000.0;
    const efWeek2Amount = 1400.0;
    const efWeek1Amount = 1100.0;
    emergencyFundBalance += efWeek3Amount + efWeek2Amount + efWeek1Amount;
    d1Ledger.insertAll(0, [
      {
        'type': 'emergency_deposit',
        'date': efWeek1.toIso8601String(),
        'amount': efWeek1Amount,
        'destination': 'Emergency Fund',
        'label': 'Weekly Emergency Fund contribution',
      },
      {
        'type': 'emergency_deposit',
        'date': efWeek2.toIso8601String(),
        'amount': efWeek2Amount,
        'destination': 'Emergency Fund',
        'label': 'Weekly Emergency Fund contribution',
      },
      {
        'type': 'emergency_deposit',
        'date': efWeek3.toIso8601String(),
        'amount': efWeek3Amount,
        'destination': 'Emergency Fund',
        'label': 'Weekly Emergency Fund contribution',
      },
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
    // Accumulating Wealth: a 6-month annual-return tracking window (started
    // behind the configured 12% target, so both the "ahead" and "behind"
    // states are explorable) plus BTC/NVDA holdings with enough buy/sell
    // history for cost-basis and unrealized-gain math to have real data to
    // work with on the Accumulating Wealth insights page.
    actionFieldValues['A30'] = {'pct': '12'};
    d1Ledger.addAll([
      {
        'type': 'investment_return_baseline',
        'date': today.subtract(const Duration(days: 180)).toIso8601String(),
        'balance': 27500.0,
        'destination': 'Investment Portfolio',
        'label': 'Started annual return tracking',
      },
      {
        'type': 'investment_gain',
        'date': today.subtract(const Duration(days: 150)).toIso8601String(),
        'amount': 800.0,
        'balance': 28300.0,
        'destination': 'Investment Portfolio',
        'label': 'Investment earnings',
      },
      {
        'type': 'investment_loss',
        'date': today.subtract(const Duration(days: 120)).toIso8601String(),
        'amount': 400.0,
        'balance': 27900.0,
        'destination': 'Investment Portfolio',
        'label': 'Investment loss',
      },
      {
        'type': 'investment_gain',
        'date': today.subtract(const Duration(days: 90)).toIso8601String(),
        'amount': 600.0,
        'balance': 28500.0,
        'destination': 'Investment Portfolio',
        'label': 'Investment earnings',
      },
      {
        'type': 'investment_loss',
        'date': today.subtract(const Duration(days: 60)).toIso8601String(),
        'amount': 900.0,
        'balance': 27600.0,
        'destination': 'Investment Portfolio',
        'label': 'Investment loss',
      },
      {
        'type': 'investment_gain',
        'date': today.subtract(const Duration(days: 30)).toIso8601String(),
        'amount': 500.0,
        'balance': 28100.0,
        'destination': 'Investment Portfolio',
        'label': 'Investment earnings',
      },
    ]);
    const demoInvestmentHoldings = [
      FakeMayaInvestmentHolding(
        symbol: 'BTC',
        name: 'Bitcoin',
        type: 'crypto',
        units: 0.007,
        price: 3785577.87,
        unitLabel: 'coins',
        costBasis: 23000,
      ),
      FakeMayaInvestmentHolding(
        symbol: 'NVDA',
        name: 'NVIDIA',
        type: 'stock',
        units: 2,
        price: 7350.00,
        unitLabel: 'shares',
        costBasis: 13000,
      ),
    ];
    final demoInvestmentTransactions = [
      FakeMayaStockTransaction(
        side: 'Sold',
        symbol: 'NVDA',
        name: 'NVIDIA',
        shares: 1,
        unitLabel: 'shares',
        type: 'stock',
        amount: 7000,
        createdAt: today.subtract(const Duration(days: 30)),
      ),
      FakeMayaStockTransaction(
        side: 'Bought',
        symbol: 'NVDA',
        name: 'NVIDIA',
        shares: 3,
        unitLabel: 'shares',
        type: 'stock',
        amount: 19500,
        createdAt: today.subtract(const Duration(days: 120)),
      ),
      FakeMayaStockTransaction(
        side: 'Bought',
        symbol: 'BTC',
        name: 'Bitcoin',
        shares: 0.002,
        unitLabel: 'coins',
        type: 'crypto',
        amount: 7000,
        createdAt: today.subtract(const Duration(days: 60)),
      ),
      FakeMayaStockTransaction(
        side: 'Bought',
        symbol: 'BTC',
        name: 'Bitcoin',
        shares: 0.005,
        unitLabel: 'coins',
        type: 'crypto',
        amount: 16000,
        createdAt: today.subtract(const Duration(days: 150)),
      ),
    ];
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
        goalBalance: lifestyleFundBalance +
            lifestyleHobbies.fold<double>(
              0,
              (total, hobby) =>
                  total + lifestyleHobbyBalance(hobby['id'].toString()),
            ),
        goalTarget: 12000,
        investmentHoldings: demoInvestmentHoldings,
        investmentTransactions: demoInvestmentTransactions,
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

  void _applyCashFlowMockProfile(User? user) {
    final now = DateTime.now();
    final normalizedEmail = (user?.email ?? email).trim().toLowerCase().isEmpty
        ? 'cashflow@gmail.com'
        : (user?.email ?? email).trim().toLowerCase();
    name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Cash Flow Account';
    email = normalizedEmail;
    primaryConcern = 'Cash Flow & Basic Needs';
    motivation = 'Cash Flow & Basic Needs';
    reflectedMotivation =
        'Keep bills covered while smoothing irregular income into everyday cash.';
    selectedGoalId = 'G1';
    selectedGoal = 'Maintain Available Cash';
    selectedGoalDescription =
        'Maintain enough available cash to cover essential bills and weekly spending.';
    selectedGoalMonthlyTarget = 12000;
    onboardingComplete = true;
    mockDataEnabled = true;
    confidence = 6;
    anxiety = 5;
    employmentStatus = 'Freelance';
    incomeType = 'Variable';
    incomeRhythm = 'Irregular';
    billsRhythm = 'Clustered bill weeks';
    checkInRhythm = 'Weekly';
    responsibility = 'Shared household expenses';
    selectedActionIds
      ..clear()
      ..addAll(const {'A1', 'A3', 'A20', 'A19'});
    addedGoalIds.clear();
    actionFieldValues
      ..clear()
      ..addAll({
        'A1': {'pct': '55'},
        'A3': {'amt': '12000', 'categories': 'Food & drink,Transport'},
        'A20': {'amt': '30000'},
        'A19': {'amt': '9000'},
      });

    monthlySalary = 0;
    irregularIncomeFloor = 30000;
    income = 36000;
    expenses = 12700;
    variableExpenses = 3000;
    savings = 0;
    emergencyMonths = 1.6;
    debtPayments = 0;
    investments = 0;
    subscriptions = 0;
    basicNeedsMonthlyTarget = 9700;
    basicNeedsAllocationPercent = .55;
    bufferAllocationPercent = .25;
    needsTarget = 9700;
    needsPercent = 70;
    financialSafetyBalance = 0;
    safetyShieldAllocationPercent = 0;
    safetyShieldTargetMonths = 0;
    shieldTrackedBalance = 0;
    investmentBalance = 0;
    lifestyleFundBalance = 0;
    lifestyleActivityBalance = 0;
    cashOnHandBalance = 1200;
    manualAccountBalances
      ..clear()
      ..addAll({
        'Wallet': 0,
        'Savings': 0,
        'Time Deposit': 0,
        'Goal Savings': 0,
      });

    Map<String, dynamic> scheduledExpense({
      required String name,
      required double amount,
      required int dueDay,
    }) =>
        {
          'name': name,
          'amount': amount,
          'essential': true,
          'expenseType': ExpenseLayer.basicNeeds.name,
          'scheduled': true,
          'dueDay': dueDay,
          'scheduleAnchorDate':
              DateTime(now.year, now.month, dueDay).toIso8601String(),
        };

    onboardingIncomeLedger
      ..clear()
      ..add(_incomeLedgerRow(
        name: 'Client projects',
        amount: 36000,
        stable: false,
        scheduled: false,
      ));
    onboardingExpenseLedger
      ..clear()
      ..addAll([
        scheduledExpense(name: 'Rent share', amount: 4500, dueDay: 5),
        scheduledExpense(name: 'Utilities', amount: 2200, dueDay: 15),
        scheduledExpense(name: 'Internet', amount: 1500, dueDay: 20),
        _expenseLedgerRow(
          name: 'Groceries and meals',
          amount: 2500,
          layer: ExpenseLayer.basicNeeds,
        ),
        _expenseLedgerRow(
          name: 'Commute',
          amount: 1000,
          layer: ExpenseLayer.basicNeeds,
        ),
        _expenseLedgerRow(
          name: 'Streaming subscriptions',
          amount: 700,
          layer: ExpenseLayer.nonEssentials,
          scheduled: true,
          dueDay: 12,
        ),
      ]);
    _syncOnboardingBaselineTotals();
    cashFlowExpenses
      ..clear()
      ..addAll([
        CashFlowExpense('Rent share', 4500),
        CashFlowExpense('Utilities', 2200),
        CashFlowExpense('Internet', 1500),
        CashFlowExpense('Groceries and meals', 2500),
        CashFlowExpense('Commute', 1000),
        CashFlowExpense(
          'Streaming subscriptions',
          700,
          layer: ExpenseLayer.nonEssentials,
        ),
      ]);
    categorySpendingBudgets
      ..clear()
      ..addAll({
        'Food & drink': 6500,
        'Transport': 5500,
      });
    onboardingBaselines
      ..clear()
      ..addAll({
        'income_baseline': '36000.00',
        'stable_income': '0.00',
        'variable_income': '36000.00',
        'monthly_expenses': '12400.00',
        'essential_expenses': '9700.00',
        'discretionary_spend': '700.00',
        'investment_balance': '0.00',
        'emergency_balance': '0.00',
      });

    jarLedger.clear();
    d1Ledger.clear();
    shieldLedger.clear();
    billObligations.clear();
    lifestyleHobbies.clear();
    manualTransactions.clear();
    transactionLabelRules.clear();
    goalBucketOverrides.clear();
    planAdjustmentActions.clear();
    anxietyCheckIns
      ..clear()
      ..addAll({
        DateTime(now.year, now.month - 3, 28).toIso8601String(): 6,
        DateTime(now.year, now.month - 2, 28).toIso8601String(): 5,
        DateTime(now.year, now.month - 1, 28).toIso8601String(): 6,
        DateTime(now.year, now.month, now.day).toIso8601String(): 4,
      });

    final transactions = <FakeMayaTransaction>[];
    var walletBalance = 21000.0;
    var needs = 7000.0;
    var buffer = 1800.0;
    final monthOffsets = [3, 2, 1, 0];
    const monthlyIncome = {
      3: [12000.0, 9000.0, 11000.0],
      2: [14000.0, 8000.0, 16000.0],
      1: [10000.0, 15000.0, 12000.0],
      0: [16000.0, 9000.0, 8000.0],
    };
    const monthlyNeedsDeposits = {
      3: [6600.0, 4950.0, 6050.0],
      2: [7700.0, 4400.0, 5000.0],
      1: [5500.0, 8250.0, 6600.0],
      0: [8800.0, 4950.0, 2200.0],
    };
    const monthlyExtraSpending = {
      3: [780.0, 620.0, 940.0, 510.0, 730.0, 660.0],
      2: [980.0, 760.0, 1180.0, 640.0, 820.0, 710.0],
      1: [700.0, 620.0, 840.0, 580.0, 690.0, 640.0],
      0: [1050.0, 890.0, 1320.0, 760.0, 980.0, 880.0],
    };

    for (final offset in monthOffsets) {
      final month = DateTime(now.year, now.month - offset);
      final incomeDates = [
        DateTime(month.year, month.month, 2, 9),
        DateTime(month.year, month.month, 14, 10),
        DateTime(month.year, month.month, 24, 11),
      ];
      final incomes = monthlyIncome[offset]!;
      final deposits = monthlyNeedsDeposits[offset]!;
      for (var i = 0; i < incomes.length; i++) {
        final incomeDate = incomeDates[i];
        if (incomeDate.isAfter(now)) continue;
        final incomeAmount = incomes[i];
        final depositAmount = deposits[i];
        final transactionId = 'cf-income-${month.year}-${month.month}-$i';
        walletBalance += incomeAmount;
        transactions.add(_demoTransaction(
          id: transactionId,
          title: 'Cash in',
          detail:
              'From: ${i == 0 ? 'Retainer client' : i == 1 ? 'Project milestone' : 'Invoice payment'}',
          amount: incomeAmount,
          date: incomeDate,
          category: 'Business income',
          source: 'E-wallet',
        ));
        walletBalance = math.max(0, walletBalance - depositAmount);
        needs += depositAmount;
        final bufferIn = math.max(0.0, incomeAmount - depositAmount);
        buffer += bufferIn;
        jarLedger.add(JarEvent(
          timestamp: incomeDate.add(const Duration(hours: 1)),
          type: JarEventType.income,
          needsIn: depositAmount,
          needsOut: 0,
          bufferIn: bufferIn,
          bufferOut: 0,
          sentence:
              '${money(incomeAmount)} cash in -> ${money(depositAmount)} Needs, ${money(bufferIn)} Buffer',
        ));
        d1Ledger.add({
          'type': 'essential_deposit',
          'date': incomeDate.add(const Duration(hours: 1)).toIso8601String(),
          'sourceDate': incomeDate.toIso8601String(),
          'sourceTransactionId': transactionId,
          'incomeAmount': incomeAmount,
          'percentage': (depositAmount / incomeAmount) * 100,
          'amount': depositAmount,
          'destination': 'Essential Expenses Fund',
          'label': depositAmount >= incomeAmount * .55
              ? 'Cash Flow allocation to Essential Expenses Fund'
              : 'Partial Cash Flow allocation to Essential Expenses Fund',
        });
        transactions.add(_demoTransaction(
          id: 'cf-needs-transfer-${month.year}-${month.month}-$i',
          title: 'Fund transfer',
          detail: 'To: Essential Expenses Fund',
          amount: -depositAmount,
          date: incomeDate.add(const Duration(hours: 1)),
          category: 'Transfer',
          source: 'E-wallet',
        ));
      }

      final bills = [
        (
          DateTime(month.year, month.month, 5, 10),
          'Rent share',
          4500.0,
          'Housing'
        ),
        (
          DateTime(month.year, month.month, 15, 18),
          'Utilities',
          2200.0,
          'Bills & utilities'
        ),
        (
          DateTime(month.year, month.month, 20, 12),
          'Internet',
          1500.0,
          'Bills & utilities'
        ),
      ];
      for (final bill in bills) {
        if (bill.$1.isAfter(now)) continue;
        final amount = bill.$3;
        final needsOut = math.min<double>(needs, amount);
        final bufferOut =
            math.min<double>(buffer, math.max(0.0, amount - needsOut));
        needs = math.max(0, needs - needsOut);
        buffer = math.max(0, buffer - bufferOut);
        jarLedger.add(JarEvent(
          timestamp: bill.$1,
          type: JarEventType.billPaid,
          needsIn: 0,
          needsOut: needsOut,
          bufferIn: 0,
          bufferOut: bufferOut,
          sentence:
              '${bill.$2} ${money(amount)} paid from Needs${bufferOut > 0 ? ' + Buffer' : ''}',
        ));
        transactions.add(_demoTransaction(
          id: 'cf-bill-${bill.$2.toLowerCase().replaceAll(' ', '-')}-${month.year}-${month.month}',
          title: 'Bill payment',
          detail: 'To: ${bill.$2}',
          amount: -amount,
          date: bill.$1,
          category: bill.$4,
          source: 'Basic Needs Fund',
        ));
      }

      final spendingAmounts = monthlyExtraSpending[offset]!;
      for (var i = 0; i < spendingAmounts.length; i++) {
        final date = DateTime(month.year, month.month, 7 + i * 3, 13);
        if (date.isAfter(now)) continue;
        final amount = spendingAmounts[i];
        needs = math.max(0, needs - math.min(needs, amount));
        final isFood = i.isEven;
        transactions.add(_demoTransaction(
          id: 'cf-spend-${month.year}-${month.month}-$i',
          title: isFood ? 'Paid merchant' : 'Sent money',
          detail: isFood ? 'To: Grocery and meals' : 'To: Commute top up',
          amount: -amount,
          date: date,
          category: isFood ? 'Food & drink' : 'Transport',
          source: 'Basic Needs Fund',
        ));
      }
    }

    needsBalance = needs;
    bufferBalance = buffer;
    essentialExpensesBalance = needs;
    billsObligationsBalance = 0;
    jarLedger.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    d1Ledger.sort((a, b) => DateTime.parse(b['date'].toString())
        .compareTo(DateTime.parse(a['date'].toString())));
    fakeMayaBucketCreationAllowed = true;
    confirmedFakeMayaBucketMotivations
      ..clear()
      ..add('Cash Flow & Basic Needs');

    final essentialGoal = FakeMayaPersonalGoal.defaultForId(
      FakeMayaPersonalGoal.essentialExpenseFundId,
    ).copyWith(
      balance: essentialExpensesBalance,
      target: needsTarget,
      daysLeft: 30,
    );
    fakeMayaLink = FakeMayaLink(
      userId: 'mock-cashflow-fakemaya',
      email: normalizedEmail,
      name: name,
      phone: '+63 917 555 0110',
      provider: 'mock',
      accessToken: '',
      refreshToken: '',
      expiresAt: null,
      summary: FakeMayaAccountSummary(
        wallet: walletBalance,
        savings: bufferBalance,
        timeDeposit: 0,
        goalName: essentialGoal.name,
        goalEmoji: essentialGoal.emoji,
        goalBalance: essentialGoal.balance,
        goalTarget: essentialGoal.target,
        personalGoals: [essentialGoal],
        creditLimit: 0,
        creditUsed: 0,
        transactions: transactions
          ..sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now)),
        updatedAt: now,
      ),
    );
    fakeMayaSyncedAccounts
      ..clear()
      ..addAll(manualAccountBalances.keys);
    for (final transaction in transactions) {
      if (transaction.isLabeled && !transaction.excludedFromInsights) {
        transactionLabelRules[transaction.patternKey] =
            TransactionLabelRule.fromTransaction(transaction);
      }
    }
    _syncFakeMayaMoneyItems();
  }

  void _applyMainMockProfile(User? user) {
    final now = DateTime.now();
    _applyCashFlowMockProfile(user);
    final normalizedEmail = (user?.email ?? email).trim().toLowerCase().isEmpty
        ? 'main@gmail.com'
        : (user?.email ?? email).trim().toLowerCase();

    name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Main Account';
    email = normalizedEmail;
    primaryConcern = 'Cash Flow & Basic Needs';
    motivation = 'Cash Flow & Basic Needs';
    reflectedMotivation =
        'Keep everyday cash steady while building Financial Safety in parallel.';
    selectedGoalId = 'G1';
    selectedGoal = 'Maintain Available Cash';
    selectedGoalDescription =
        'Maintain enough available cash while steadily building Financial Safety.';
    selectedGoalMonthlyTarget = 12000;
    selectedActionIds
      ..clear()
      ..addAll(const {'A1', 'A3', 'A20', 'A19', 'A9', 'A8', 'A22', 'A10'});
    addedGoalIds
      ..clear()
      ..add('G3');
    actionFieldValues
      ..clear()
      ..addAll({
        'A1': {'pct': '55'},
        'A3': {'amt': '12000', 'categories': 'Food & drink,Transport'},
        'A20': {'amt': '30000'},
        'A19': {'amt': '9000'},
        'A9': {'amt': '4200'},
        'A8': {'pct': '10'},
        'A22': {'months': '3'},
        'A10': {'days': '7'},
      });
    monthlySalary = 0;
    irregularIncomeFloor = 36000;
    income = 36000;
    expenses = 12700;
    safetyShieldAllocationPercent = 10;
    safetyShieldTargetMonths = 6;

    final link = fakeMayaLink;
    if (link == null) return;
    final transactions = [...link.summary.transactions];
    var emergencyBalance = 24000.0;
    var walletAdjustment = 0.0;
    final incomeTransactions = transactions
        .where((transaction) =>
            transaction.amount > 0 &&
            !transaction.excludedFromInsights &&
            (transaction.createdAt ?? now)
                .isBefore(now.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => (a.createdAt ?? now).compareTo(b.createdAt ?? now));

    for (final transaction in incomeTransactions) {
      final incomeDate = transaction.createdAt ?? now;
      final depositAmount =
          (transaction.amount * (incomeDate.month == now.month ? .08 : .10))
              .roundToDouble();
      if (depositAmount <= 0) continue;
      emergencyBalance += depositAmount;
      walletAdjustment -= depositAmount;
      d1Ledger.add({
        'type': 'emergency_deposit',
        'date': incomeDate.add(const Duration(hours: 3)).toIso8601String(),
        'sourceDate': incomeDate.toIso8601String(),
        'sourceTransactionId': transaction.transactionId,
        'incomeAmount': transaction.amount,
        'percentage': (depositAmount / transaction.amount) * 100,
        'amount': depositAmount,
        'destination': 'Emergency Fund',
        'label': depositAmount >= transaction.amount * .10
            ? '10% income transfer to Emergency Fund'
            : 'Partial income transfer to Emergency Fund',
      });
      transactions.add(_demoTransaction(
        id: 'main-ef-transfer-${incomeDate.year}-${incomeDate.month}-${incomeDate.day}-${transaction.transactionId}',
        title: 'Fund transfer',
        detail: 'To: Emergency Fund',
        amount: -depositAmount,
        date: incomeDate.add(const Duration(hours: 3)),
        category: 'Transfer',
        source: 'E-wallet',
      ));
    }

    final lastMonthEmergency = DateTime(now.year, now.month - 1, 12, 15);
    emergencyBalance = math.max(0, emergencyBalance - 4200);
    d1Ledger.add({
      'type': 'use_emergency',
      'date': lastMonthEmergency.toIso8601String(),
      'amount': 4200.0,
      'label': 'Dental x-ray and medicine',
      'sourceTransactionId': 'main-ef-dental-emergency',
    });
    transactions.add(_demoTransaction(
      id: 'main-ef-dental-emergency',
      title: 'Emergency payment',
      detail: 'To: Dental clinic',
      amount: -4200,
      date: lastMonthEmergency,
      category: 'Health',
      source: 'Emergency Fund',
    ));
    final replenishedAt = lastMonthEmergency.add(const Duration(days: 5));
    emergencyBalance += 4200;
    d1Ledger.add({
      'type': 'ef_replenish',
      'date': replenishedAt.toIso8601String(),
      'amount': 4200.0,
      'label': 'Dental emergency replenished from next cash-in',
    });

    final recentEmergency = now.subtract(const Duration(days: 9));
    emergencyBalance = math.max(0, emergencyBalance - 3600);
    d1Ledger.add({
      'type': 'use_emergency',
      'date': recentEmergency.toIso8601String(),
      'amount': 3600.0,
      'label': 'Urgent clinic visit',
      'sourceTransactionId': 'main-ef-clinic-emergency',
    });
    transactions.add(_demoTransaction(
      id: 'main-ef-clinic-emergency',
      title: 'Emergency payment',
      detail: 'To: Urgent care clinic',
      amount: -3600,
      date: recentEmergency,
      category: 'Health',
      source: 'Emergency Fund',
    ));

    emergencyFundBalance = emergencyBalance;
    financialSafetyBalance = emergencyBalance;
    shieldTrackedBalance = emergencyBalance;
    emergencyMonths =
        emergencyFundBalance / math.max(1, monthlyEssentialExpenseTotal);
    onboardingBaselines['emergency_balance'] =
        emergencyFundBalance.toStringAsFixed(2);
    _lastEfWithdrawalStr = recentEmergency.toIso8601String();
    confirmedFakeMayaBucketMotivations
      ..clear()
      ..addAll(const {'Cash Flow & Basic Needs', 'Financial Safety'});
    fakeMayaBucketCreationAllowed = true;
    d1Ledger.sort((a, b) => DateTime.parse(b['date'].toString())
        .compareTo(DateTime.parse(a['date'].toString())));

    final essentialGoal = FakeMayaPersonalGoal.defaultForId(
      FakeMayaPersonalGoal.essentialExpenseFundId,
    ).copyWith(
      balance: essentialExpensesBalance,
      target: needsTarget,
      daysLeft: 30,
    );
    final emergencyGoal = FakeMayaPersonalGoal.defaultForId(
      FakeMayaPersonalGoal.emergencyFundId,
    ).copyWith(
      balance: emergencyFundBalance,
      target: monthlyEssentialExpenseTotal * 6,
      daysLeft: 120,
    );
    transactions
        .sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now));
    fakeMayaLink = FakeMayaLink(
      userId: 'mock-main-fakemaya',
      email: normalizedEmail,
      name: name,
      phone: '+63 917 555 0100',
      provider: 'mock',
      accessToken: '',
      refreshToken: '',
      expiresAt: null,
      summary: link.summary.copyWith(
        wallet: math.max(0, link.summary.wallet + walletAdjustment),
        goalName: essentialGoal.name,
        goalEmoji: essentialGoal.emoji,
        goalBalance: essentialGoal.balance,
        goalTarget: essentialGoal.target,
        selectedGoalId: FakeMayaPersonalGoal.essentialExpenseFundId,
        personalGoals: [essentialGoal, emergencyGoal],
        transactions: transactions,
        updatedAt: now,
      ),
    );
    transactionLabelRules.clear();
    for (final transaction in transactions) {
      if (transaction.isLabeled && !transaction.excludedFromInsights) {
        transactionLabelRules[transaction.patternKey] =
            TransactionLabelRule.fromTransaction(transaction);
      }
    }
    _syncFakeMayaMoneyItems();
  }

  void _applyEmergencyFundMockProfile(User? user) {
    final now = DateTime.now();
    final normalizedEmail = (user?.email ?? email).trim().toLowerCase().isEmpty
        ? 'emergency@gmail.com'
        : (user?.email ?? email).trim().toLowerCase();
    name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Emergency Fund Account';
    email = normalizedEmail;
    primaryConcern = 'Financial Safety';
    motivation = 'Financial Safety';
    reflectedMotivation =
        'Build enough protection so emergencies do not derail monthly cash flow.';
    selectedGoalId = 'G3';
    selectedGoal = 'Build Emergency Fund';
    selectedGoalDescription =
        'Build an emergency fund that can cover unexpected expenses.';
    selectedGoalMonthlyTarget = 3500;
    onboardingComplete = true;
    mockDataEnabled = true;
    confidence = 6;
    anxiety = 4;
    employmentStatus = 'Employed';
    incomeType = 'Stable';
    incomeRhythm = 'Twice a month';
    billsRhythm = 'Mostly scheduled';
    checkInRhythm = 'Weekly';
    responsibility = 'Shared household expenses';
    selectedActionIds
      ..clear()
      ..addAll(const {'A9', 'A8', 'A22', 'A10'});
    addedGoalIds.clear();
    actionFieldValues
      ..clear()
      ..addAll({
        'A9': {'amt': '6500'},
        'A8': {'pct': '10'},
        'A22': {'months': '3'},
        'A10': {'days': '5'},
      });

    monthlySalary = 42000;
    irregularIncomeFloor = 0;
    income = 42000;
    expenses = 13900;
    variableExpenses = 2400;
    debtPayments = 0;
    investments = 0;
    basicNeedsMonthlyTarget = 11000;
    basicNeedsAllocationPercent = .60;
    bufferAllocationPercent = .20;
    needsTarget = 11000;
    needsPercent = 70;
    financialSafetyBalance = 31500;
    safetyShieldAllocationPercent = 10;
    safetyShieldTargetMonths = 6;
    shieldTrackedBalance = 31500;
    investmentBalance = 0;
    lifestyleFundBalance = 0;
    lifestyleActivityBalance = 0;
    categorySpendingBudgets
      ..clear()
      ..addAll({
        'Health': 2500,
        'Insurance': 2400,
        'Bills & utilities': 2200,
      });

    onboardingIncomeLedger
      ..clear()
      ..add(_incomeLedgerRow(
        name: 'Salary',
        amount: 42000,
        stable: true,
        scheduled: true,
        payDay: 15,
      ));
    onboardingExpenseLedger
      ..clear()
      ..addAll([
        _expenseLedgerRow(
          name: 'Rent share',
          amount: 4500,
          layer: ExpenseLayer.basicNeeds,
          scheduled: true,
          dueDay: 5,
        ),
        _expenseLedgerRow(
          name: 'Utilities',
          amount: 2200,
          layer: ExpenseLayer.basicNeeds,
          scheduled: true,
          dueDay: 15,
        ),
        _expenseLedgerRow(
          name: 'Groceries and meals',
          amount: 3100,
          layer: ExpenseLayer.basicNeeds,
        ),
        _expenseLedgerRow(
          name: 'Commute',
          amount: 1200,
          layer: ExpenseLayer.basicNeeds,
        ),
        _expenseLedgerRow(
          name: 'Insurance premium',
          amount: 2400,
          layer: ExpenseLayer.emergencyInsurance,
          scheduled: true,
          dueDay: 20,
        ),
        _expenseLedgerRow(
          name: 'Medical sinking fund',
          amount: 1500,
          layer: ExpenseLayer.emergencyInsurance,
        ),
        _expenseLedgerRow(
          name: 'Occasional medicine',
          amount: 1000,
          layer: ExpenseLayer.emergencyInsurance,
        ),
      ]);
    _syncOnboardingBaselineTotals();
    cashFlowExpenses
      ..clear()
      ..addAll([
        CashFlowExpense('Rent share', 4500),
        CashFlowExpense('Utilities', 2200),
        CashFlowExpense('Groceries and meals', 3100),
        CashFlowExpense('Commute', 1200),
        CashFlowExpense(
          'Insurance premium',
          2400,
          layer: ExpenseLayer.emergencyInsurance,
        ),
        CashFlowExpense(
          'Medical sinking fund',
          1500,
          layer: ExpenseLayer.emergencyInsurance,
        ),
        CashFlowExpense(
          'Occasional medicine',
          1000,
          layer: ExpenseLayer.emergencyInsurance,
        ),
      ]);

    final transactions = <FakeMayaTransaction>[];
    final ledger = <Map<String, dynamic>>[];
    var emergencyBalance = 18000.0;
    var needs = 7200.0;
    var buffer = 2600.0;
    final monthOffsets = [3, 2, 1, 0];
    for (final offset in monthOffsets) {
      final month = DateTime(now.year, now.month - offset);
      final firstPayday = DateTime(month.year, month.month, 15, 9);
      final secondPayday = offset == 0
          ? DateTime(now.year, now.month, now.day, 9)
          : DateTime(month.year, month.month + 1, 0, 9);
      final paydays = [firstPayday, secondPayday];
      for (var i = 0; i < paydays.length; i++) {
        final payday = paydays[i];
        final transactionId = 'ef-salary-${month.year}-${month.month}-$i';
        transactions.add(_demoTransaction(
          id: transactionId,
          title: 'Cash in',
          detail: 'From: Employer payroll',
          amount: 21000,
          date: payday,
          category: 'Salary',
          source: 'E-wallet',
        ));
        final needsIn =
            math.min<double>(12600, math.max(0, needsTarget - needs));
        final bufferIn = 4200 + (12600 - needsIn);
        needs = math.min(needsTarget, needs + needsIn);
        buffer += bufferIn;
        jarLedger.add(JarEvent(
          timestamp: payday.add(const Duration(hours: 1)),
          type: JarEventType.income,
          needsIn: needsIn,
          needsOut: 0,
          bufferIn: bufferIn,
          bufferOut: 0,
          sentence:
              '${money(21000)} salary -> ${money(needsIn)} Needs, ${money(bufferIn)} Buffer',
        ));
        final depositAmount = 2100.0;
        emergencyBalance += depositAmount;
        ledger.add({
          'type': 'emergency_deposit',
          'date': payday.add(const Duration(hours: 2)).toIso8601String(),
          'sourceDate': payday.toIso8601String(),
          'sourceTransactionId': transactionId,
          'incomeAmount': 21000.0,
          'percentage': 10.0,
          'amount': depositAmount,
          'destination': 'Emergency Fund',
          'label': depositAmount >= 2100
              ? '10% salary transfer to Emergency Fund'
              : 'Partial salary transfer to Emergency Fund',
        });
        transactions.add(_demoTransaction(
          id: 'ef-transfer-${month.year}-${month.month}-$i',
          title: 'Fund transfer',
          detail: 'To: Emergency Fund',
          amount: -depositAmount,
          date: payday.add(const Duration(hours: 2)),
          category: 'Transfer',
          source: 'E-wallet',
        ));
      }

      if (offset == 0) {
        for (final extra in [
          (
            DateTime(month.year, month.month, 3, 11),
            'Weekend clinic reimbursement',
            5000.0,
            500.0
          ),
          (
            DateTime(month.year, month.month, 9, 16),
            'Health allowance reimbursement',
            8000.0,
            800.0
          ),
          (
            DateTime(month.year, month.month, 22, 10),
            'Attendance bonus',
            6000.0,
            600.0
          ),
          (
            now.subtract(const Duration(hours: 1)),
            'Pharmacy refund',
            2500.0,
            250.0
          ),
        ]) {
          final extraDate = extra.$1;
          if (extraDate.isAfter(now)) continue;
          final transactionId =
              'ef-extra-income-${extraDate.year}-${extraDate.month}-${extraDate.day}';
          transactions.add(_demoTransaction(
            id: transactionId,
            title: 'Cash in',
            detail: 'From: ${extra.$2}',
            amount: extra.$3,
            date: extraDate,
            category: 'Refund',
            source: 'E-wallet',
          ));
          final depositAmount = extra.$4;
          if (depositAmount <= 0) continue;
          emergencyBalance += depositAmount;
          ledger.add({
            'type': 'emergency_deposit',
            'date': extraDate.add(const Duration(hours: 2)).toIso8601String(),
            'sourceDate': extraDate.toIso8601String(),
            'sourceTransactionId': transactionId,
            'incomeAmount': extra.$3,
            'percentage': (depositAmount / extra.$3) * 100,
            'amount': depositAmount,
            'destination': 'Emergency Fund',
            'label': depositAmount < extra.$3 * .10
                ? 'Partial extra-income Emergency Fund transfer'
                : 'Extra-income Emergency Fund transfer',
          });
          transactions.add(_demoTransaction(
            id: 'ef-extra-transfer-${extraDate.year}-${extraDate.month}-${extraDate.day}',
            title: 'Fund transfer',
            detail: 'To: Emergency Fund',
            amount: -depositAmount,
            date: extraDate.add(const Duration(hours: 2)),
            category: 'Transfer',
            source: 'E-wallet',
          ));
        }
      }

      final rentDate = DateTime(month.year, month.month, 5, 10);
      final utilityDate = DateTime(month.year, month.month, 15, 18);
      final insuranceDate = DateTime(month.year, month.month, 20, 10);
      for (final item in [
        (rentDate, 'Rent share', 4500.0, 'Housing', 'Basic Needs Fund'),
        (
          utilityDate,
          'Utilities',
          2200.0,
          'Bills & utilities',
          'Basic Needs Fund'
        ),
        (insuranceDate, 'Insurance premium', 2400.0, 'Insurance', 'E-wallet'),
      ]) {
        final amount = item.$3.toDouble();
        if (item.$5 == 'Basic Needs Fund') {
          final needsOut = math.min<double>(needs, amount);
          final bufferOut =
              math.min<double>(buffer, math.max(0.0, amount - needsOut));
          needs = math.max(0, needs - needsOut);
          buffer = math.max(0, buffer - bufferOut);
          jarLedger.add(JarEvent(
            timestamp: item.$1,
            type: JarEventType.billPaid,
            needsIn: 0,
            needsOut: needsOut,
            bufferIn: 0,
            bufferOut: bufferOut,
            sentence:
                '${item.$2} ${money(amount)} paid from Needs${bufferOut > 0 ? ' + Buffer' : ''}',
          ));
        } else if (item.$5 == 'Emergency Fund') {
          emergencyBalance = math.max(0, emergencyBalance - amount);
        }
        transactions.add(_demoTransaction(
          id: 'ef-${item.$2.toLowerCase().replaceAll(' ', '-')}-${month.year}-${month.month}',
          title: 'Bill payment',
          detail: 'To: ${item.$2}',
          amount: -amount,
          date: item.$1,
          category: item.$4,
          source: item.$5,
        ));
      }

      for (var n = 0; n < 4; n++) {
        final date = DateTime(month.year, month.month, 7 + n * 5, 13);
        final amount = 520.0 + ((offset + n) * 45);
        needs = math.max(0, needs - math.min(needs, amount));
        transactions.add(_demoTransaction(
          id: 'ef-grocery-${month.year}-${month.month}-$n',
          title: n.isEven ? 'Paid merchant' : 'Sent money',
          detail: n.isEven ? 'To: Grocery and pharmacy' : 'To: Commute top up',
          amount: -amount,
          date: date,
          category: n.isEven ? 'Groceries' : 'Transport',
          source: 'Basic Needs Fund',
        ));
      }
    }

    final currentMonthLateUse = DateTime(now.year, now.month, 6, 15);
    if (!currentMonthLateUse.isAfter(now)) {
      emergencyBalance = math.max(0, emergencyBalance - 4800);
      ledger.add({
        'type': 'use_emergency',
        'date': currentMonthLateUse.toIso8601String(),
        'amount': 4800.0,
        'label': 'Child fever urgent care',
        'sourceTransactionId': 'ef-current-fever-emergency',
      });
      transactions.add(_demoTransaction(
        id: 'ef-current-fever-emergency',
        title: 'Emergency payment',
        detail: 'To: Pediatric urgent care',
        amount: -4800,
        date: currentMonthLateUse,
        category: 'Health',
        source: 'Emergency Fund',
      ));
      final currentMonthLateReplenish =
          currentMonthLateUse.add(const Duration(days: 10));
      if (!currentMonthLateReplenish.isAfter(now)) {
        emergencyBalance += 4800;
        ledger.add({
          'type': 'ef_replenish',
          'date': currentMonthLateReplenish.toIso8601String(),
          'amount': 4800.0,
          'label': 'Urgent care replenished after next salary',
        });
      }
    }

    final lastMonth = DateTime(now.year, now.month - 1, 11, 14);
    emergencyBalance = math.max(0, emergencyBalance - 6800);
    ledger.add({
      'type': 'use_emergency',
      'date': lastMonth.toIso8601String(),
      'amount': 6800.0,
      'label': 'Urgent dental procedure',
      'sourceTransactionId': 'ef-dental-emergency',
    });
    transactions.add(_demoTransaction(
      id: 'ef-dental-emergency',
      title: 'Emergency payment',
      detail: 'To: Dental clinic',
      amount: -6800,
      date: lastMonth,
      category: 'Health',
      source: 'Emergency Fund',
    ));
    final replenishedAt = lastMonth.add(const Duration(days: 4));
    emergencyBalance += 6800;
    ledger.add({
      'type': 'ef_replenish',
      'date': replenishedAt.toIso8601String(),
      'amount': 6800.0,
      'label': 'Dental emergency replenished after payday',
    });

    final recentEmergency = now.subtract(const Duration(days: 8));
    emergencyBalance = math.max(0, emergencyBalance - 5600);
    ledger.add({
      'type': 'use_emergency',
      'date': recentEmergency.toIso8601String(),
      'amount': 5600.0,
      'label': 'Urgent clinic visit',
      'sourceTransactionId': 'ef-clinic-emergency',
    });
    transactions.add(_demoTransaction(
      id: 'ef-clinic-emergency',
      title: 'Emergency payment',
      detail: 'To: Urgent care clinic',
      amount: -5600,
      date: recentEmergency,
      category: 'Health',
      source: 'Emergency Fund',
    ));

    emergencyFundBalance = emergencyBalance;
    financialSafetyBalance = emergencyBalance;
    shieldTrackedBalance = emergencyBalance;
    emergencyMonths =
        emergencyFundBalance / math.max(1, monthlyEssentialExpenseTotal);
    needsBalance = needs;
    bufferBalance = buffer;
    essentialExpensesBalance = needs;
    billsObligationsBalance = 0;
    _lastEfWithdrawalStr = recentEmergency.toIso8601String();
    billObligations
      ..clear()
      ..addAll([
        {
          'id': 'mock_insurance_${now.year}_${now.month}',
          'name': 'Insurance premium',
          'expectedAmount': 2400.0,
          'paidAmount': 2400.0,
          'dueDate': DateTime(now.year, now.month, 20).toIso8601String(),
          'expenseType': ExpenseLayer.emergencyInsurance.name,
          'status': 'paid',
          'updatedAt': DateTime(now.year, now.month, 20).toIso8601String(),
          'createdAt': DateTime(now.year, now.month, 1).toIso8601String(),
        },
      ]);
    d1Ledger
      ..clear()
      ..addAll(ledger
        ..sort((a, b) => DateTime.parse(b['date'].toString())
            .compareTo(DateTime.parse(a['date'].toString()))));
    jarLedger.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    manualTransactions.clear();
    transactionLabelRules.clear();
    goalBucketOverrides.clear();
    planAdjustmentActions.clear();
    anxietyCheckIns
      ..clear()
      ..addAll({
        DateTime(now.year, now.month - 3, 28).toIso8601String(): 6,
        DateTime(now.year, now.month - 2, 28).toIso8601String(): 5,
        DateTime(now.year, now.month - 1, 28).toIso8601String(): 4,
        DateTime(now.year, now.month, now.day).toIso8601String(): 3,
      });

    final emergencyGoal = FakeMayaPersonalGoal.defaultForId(
      FakeMayaPersonalGoal.emergencyFundId,
    ).copyWith(
      balance: emergencyFundBalance,
      target: monthlyEssentialExpenseTotal * 6,
      daysLeft: 120,
    );
    fakeMayaLink = FakeMayaLink(
      userId: 'mock-emergency-fakemaya',
      email: normalizedEmail,
      name: name,
      phone: '+63 917 555 0130',
      provider: 'mock',
      accessToken: '',
      refreshToken: '',
      expiresAt: null,
      summary: FakeMayaAccountSummary(
        wallet: 24500,
        savings: 6200,
        timeDeposit: 0,
        goalName: emergencyGoal.name,
        goalEmoji: emergencyGoal.emoji,
        goalBalance: emergencyGoal.balance,
        goalTarget: emergencyGoal.target,
        personalGoals: [emergencyGoal],
        creditLimit: 0,
        creditUsed: 0,
        transactions: transactions
          ..sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now)),
        updatedAt: now,
      ),
    );
    fakeMayaSyncedAccounts
      ..clear()
      ..addAll(manualAccountBalances.keys);
    for (final transaction in transactions) {
      if (transaction.isLabeled && !transaction.excludedFromInsights) {
        transactionLabelRules[transaction.patternKey] =
            TransactionLabelRule.fromTransaction(transaction);
      }
    }
    _syncFakeMayaMoneyItems();
  }

  void _applyAccumulatingWealthMockProfile(User? user) {
    final now = DateTime.now();
    final normalizedEmail = (user?.email ?? email).trim().toLowerCase().isEmpty
        ? 'accumulating@gmail.com'
        : (user?.email ?? email).trim().toLowerCase();
    name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Accumulating Wealth Account';
    email = normalizedEmail;
    primaryConcern = 'Accumulating Wealth';
    motivation = 'Accumulating Wealth';
    reflectedMotivation =
        'Keep investing a steady share of income while growing a portfolio with visible return targets.';
    selectedGoalId = 'G5';
    selectedGoal = 'Grow Investments';
    selectedGoalDescription =
        'Build an investment portfolio and keep it on track against your target return.';
    selectedGoalMonthlyTarget = 5800;
    onboardingComplete = true;
    mockDataEnabled = true;
    confidence = 7;
    anxiety = 3;
    employmentStatus = 'Employed';
    incomeType = 'Stable';
    incomeRhythm = 'Twice a month';
    billsRhythm = 'Mostly scheduled';
    checkInRhythm = 'Monthly';
    responsibility = 'Personal expenses';
    selectedActionIds
      ..clear()
      ..addAll(const {'A12', 'A23', 'A30'});
    addedGoalIds.clear();
    actionFieldValues
      ..clear()
      ..addAll({
        'A12': {'pct': '10'},
        'A23': {'amt': '120000'},
        'A30': {'pct': '12'},
      });

    monthlySalary = 58000;
    irregularIncomeFloor = 0;
    income = 58000;
    expenses = 18200;
    variableExpenses = 4200;
    debtPayments = 3500;
    investments = 5800;
    basicNeedsMonthlyTarget = 9000;
    basicNeedsAllocationPercent = .45;
    bufferAllocationPercent = .25;
    needsTarget = 9000;
    needsPercent = 45;
    financialSafetyBalance = 18000;
    safetyShieldAllocationPercent = 0;
    safetyShieldTargetMonths = 0;
    shieldTrackedBalance = 18000;
    lifestyleFundBalance = 0;
    lifestyleActivityBalance = 0;
    cashOnHandBalance = 1500;
    categorySpendingBudgets
      ..clear()
      ..addAll({
        'Investment': 5800,
        'Debt payment': 3500,
        'Food & drink': 7000,
        'Transport': 2500,
      });

    onboardingIncomeLedger
      ..clear()
      ..add(_incomeLedgerRow(
        name: 'Salary',
        amount: 58000,
        stable: true,
        scheduled: true,
        payDay: 15,
      ));
    onboardingExpenseLedger
      ..clear()
      ..addAll([
        _expenseLedgerRow(
          name: 'Rent share',
          amount: 4500,
          layer: ExpenseLayer.basicNeeds,
          scheduled: true,
          dueDay: 5,
        ),
        _expenseLedgerRow(
          name: 'Utilities',
          amount: 2200,
          layer: ExpenseLayer.basicNeeds,
          scheduled: true,
          dueDay: 15,
        ),
        _expenseLedgerRow(
          name: 'Groceries and meals',
          amount: 3100,
          layer: ExpenseLayer.basicNeeds,
        ),
        _expenseLedgerRow(
          name: 'Commute',
          amount: 1200,
          layer: ExpenseLayer.basicNeeds,
        ),
        _expenseLedgerRow(
          name: 'Investment contribution',
          amount: 5800,
          layer: ExpenseLayer.debtInvestments,
          scheduled: true,
          dueDay: 28,
        ),
        _expenseLedgerRow(
          name: 'Credit card payment',
          amount: 3500,
          layer: ExpenseLayer.debtInvestments,
          scheduled: true,
          dueDay: 18,
        ),
        _expenseLedgerRow(
          name: 'Dining out',
          amount: 2200,
          layer: ExpenseLayer.nonEssentials,
        ),
      ]);
    _syncOnboardingBaselineTotals();
    cashFlowExpenses
      ..clear()
      ..addAll([
        CashFlowExpense('Rent share', 4500),
        CashFlowExpense('Utilities', 2200),
        CashFlowExpense('Groceries and meals', 3100),
        CashFlowExpense('Commute', 1200),
        CashFlowExpense(
          'Investment contribution',
          5800,
          layer: ExpenseLayer.debtInvestments,
        ),
        CashFlowExpense(
          'Credit card payment',
          3500,
          layer: ExpenseLayer.debtInvestments,
        ),
        CashFlowExpense(
          'Dining out',
          2200,
          layer: ExpenseLayer.nonEssentials,
        ),
      ]);
    onboardingBaselines
      ..clear()
      ..addAll({
        'income_baseline': '58000.00',
        'stable_income': '58000.00',
        'variable_income': '0.00',
        'monthly_expenses': '18200.00',
        'essential_expenses': '11000.00',
        'discretionary_spend': '2200.00',
        'investment_balance': '0.00',
        'emergency_balance': '18000.00',
      });

    jarLedger.clear();
    d1Ledger.clear();
    shieldLedger.clear();
    billObligations.clear();
    lifestyleHobbies.clear();
    manualTransactions.clear();
    transactionLabelRules.clear();
    goalBucketOverrides.clear();
    planAdjustmentActions.clear();
    anxietyCheckIns
      ..clear()
      ..addAll({
        DateTime(now.year, now.month - 3, 28).toIso8601String(): 4,
        DateTime(now.year, now.month - 2, 28).toIso8601String(): 3,
        DateTime(now.year, now.month - 1, 28).toIso8601String(): 3,
        DateTime(now.year, now.month, now.day).toIso8601String(): 2,
      });

    final transactions = <FakeMayaTransaction>[];
    final stockTransactions = <FakeMayaStockTransaction>[];
    final ledger = <Map<String, dynamic>>[];
    var walletBalance = 26000.0;
    var needs = 5200.0;
    var buffer = 9400.0;
    var investmentBucket = 21000.0;
    const monthOffsets = [3, 2, 1, 0];
    const monthlyInvestmentDeposits = {
      3: [2900.0, 2600.0],
      2: [2900.0, 2900.0],
      1: [2900.0, 3200.0],
      0: [2900.0, 2100.0],
    };
    const monthlyReturns = {
      3: [900.0, -350.0],
      2: [1250.0, -250.0],
      1: [780.0, -700.0],
      0: [650.0, -200.0],
    };

    ledger.add({
      'type': 'investment_return_baseline',
      'date': DateTime(now.year, now.month - 4, 28).toIso8601String(),
      'balance': 62000.0,
      'destination': 'Investment Portfolio',
      'label': 'Started annual return tracking',
    });

    for (final offset in monthOffsets) {
      final month = DateTime(now.year, now.month - offset);
      final paydays = [
        DateTime(month.year, month.month, 15, 9),
        DateTime(month.year, month.month + 1, 0, 9),
      ];
      final deposits = monthlyInvestmentDeposits[offset]!;
      for (var i = 0; i < paydays.length; i++) {
        final payday = paydays[i];
        if (payday.isAfter(now)) continue;
        final transactionId = 'aw-salary-${month.year}-${month.month}-$i';
        walletBalance += 29000;
        transactions.add(_demoTransaction(
          id: transactionId,
          title: 'Cash in',
          detail: 'From: Employer payroll',
          amount: 29000,
          date: payday,
          category: 'Salary',
          source: 'E-wallet',
        ));

        final needsIn =
            math.min<double>(13050, math.max(0, needsTarget - needs));
        final bufferIn = 7250 + (13050 - needsIn);
        needs = math.min(needsTarget, needs + needsIn);
        buffer += bufferIn;
        jarLedger.add(JarEvent(
          timestamp: payday.add(const Duration(hours: 1)),
          type: JarEventType.income,
          needsIn: needsIn,
          needsOut: 0,
          bufferIn: bufferIn,
          bufferOut: 0,
          sentence:
              '${money(29000)} salary -> ${money(needsIn)} Needs, ${money(bufferIn)} Buffer',
        ));

        final depositAmount = deposits[i];
        walletBalance = math.max(0, walletBalance - depositAmount);
        investmentBucket += depositAmount;
        ledger.add({
          'type': 'investment_deposit',
          'date': payday.add(const Duration(hours: 2)).toIso8601String(),
          'sourceDate': payday.toIso8601String(),
          'sourceTransactionId': transactionId,
          'incomeAmount': 29000.0,
          'percentage': (depositAmount / 29000) * 100,
          'amount': depositAmount,
          'destination': 'Investment Portfolio',
          'label': depositAmount >= 2900
              ? '10% salary transfer to Investment Portfolio'
              : 'Partial salary transfer to Investment Portfolio',
        });
        transactions.add(_demoTransaction(
          id: 'aw-invest-transfer-${month.year}-${month.month}-$i',
          title: 'Fund transfer',
          detail: 'To: Investment Portfolio',
          amount: -depositAmount,
          date: payday.add(const Duration(hours: 2)),
          category: 'Investment',
          source: 'E-wallet',
        ));
      }

      final firstReturn = monthlyReturns[offset]![0];
      final secondReturn = monthlyReturns[offset]![1];
      for (final item in [
        (DateTime(month.year, month.month, 10, 10), firstReturn),
        (DateTime(month.year, month.month, 24, 10), secondReturn),
      ]) {
        if (item.$1.isAfter(now)) continue;
        final amount = item.$2.abs();
        ledger.add({
          'type': item.$2 >= 0 ? 'investment_gain' : 'investment_loss',
          'date': item.$1.toIso8601String(),
          'amount': amount,
          'balance': investmentBucket,
          'destination': 'Investment Portfolio',
          'label': item.$2 >= 0 ? 'Investment earnings' : 'Investment loss',
        });
      }

      final stockDate = DateTime(month.year, month.month, 28, 11);
      if (!stockDate.isAfter(now)) {
        final buyNvda = offset.isEven;
        stockTransactions.add(FakeMayaStockTransaction(
          side: 'Bought',
          symbol: buyNvda ? 'NVDA' : 'BTC',
          name: buyNvda ? 'NVIDIA' : 'Bitcoin',
          shares: buyNvda ? 0.55 : 0.0016,
          unitLabel: buyNvda ? 'shares' : 'coins',
          type: buyNvda ? 'stock' : 'crypto',
          amount: buyNvda ? 4100 : 6200,
          createdAt: stockDate,
        ));
      }

      for (final bill in [
        (
          DateTime(month.year, month.month, 5, 10),
          'Rent share',
          4500.0,
          'Housing'
        ),
        (
          DateTime(month.year, month.month, 15, 18),
          'Utilities',
          2200.0,
          'Bills & utilities'
        ),
        (
          DateTime(month.year, month.month, 18, 12),
          'Credit card payment',
          3500.0,
          'Debt payment'
        ),
      ]) {
        if (bill.$1.isAfter(now)) continue;
        needs = math.max(0, needs - math.min(needs, bill.$3));
        transactions.add(_demoTransaction(
          id: 'aw-${bill.$2.toLowerCase().replaceAll(' ', '-')}-${month.year}-${month.month}',
          title: 'Bill payment',
          detail: 'To: ${bill.$2}',
          amount: -bill.$3,
          date: bill.$1,
          category: bill.$4,
          source: bill.$4 == 'Debt payment' ? 'E-wallet' : 'Basic Needs Fund',
        ));
      }

      for (var n = 0; n < 4; n++) {
        final date = DateTime(month.year, month.month, 8 + n * 4, 13);
        if (date.isAfter(now)) continue;
        final amount = 620.0 + ((offset + n) * 70);
        final isFood = n.isEven;
        needs = math.max(0, needs - math.min(needs, amount));
        transactions.add(_demoTransaction(
          id: 'aw-spend-${month.year}-${month.month}-$n',
          title: isFood ? 'Paid merchant' : 'Sent money',
          detail: isFood ? 'To: Groceries and coffee' : 'To: Commute reload',
          amount: -amount,
          date: date,
          category: isFood ? 'Food & drink' : 'Transport',
          source: 'Basic Needs Fund',
        ));
      }
    }

    const holdings = [
      FakeMayaInvestmentHolding(
        symbol: 'BTC',
        name: 'Bitcoin',
        type: 'crypto',
        units: 0.0102,
        price: 3860000,
        unitLabel: 'coins',
        costBasis: 36800,
      ),
      FakeMayaInvestmentHolding(
        symbol: 'NVDA',
        name: 'NVIDIA',
        type: 'stock',
        units: 2.35,
        price: 7200,
        unitLabel: 'shares',
        costBasis: 15800,
      ),
    ];
    investmentBalance = investmentBucket;
    needsBalance = needs;
    bufferBalance = buffer;
    essentialExpensesBalance = needs;
    emergencyFundBalance = financialSafetyBalance;
    shieldTrackedBalance = financialSafetyBalance;
    d1Ledger
      ..clear()
      ..addAll(ledger
        ..sort((a, b) => DateTime.parse(b['date'].toString())
            .compareTo(DateTime.parse(a['date'].toString()))));
    jarLedger.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    fakeMayaBucketCreationAllowed = true;
    confirmedFakeMayaBucketMotivations
      ..clear()
      ..add('Accumulating Wealth');

    final investmentGoal = FakeMayaPersonalGoal.defaultForId(
      FakeMayaPersonalGoal.investmentFundId,
    ).copyWith(
      balance: investmentBalance,
      target: 120000,
      daysLeft: 180,
    );
    fakeMayaLink = FakeMayaLink(
      userId: 'mock-accumulating-fakemaya',
      email: normalizedEmail,
      name: name,
      phone: '+63 917 555 0150',
      provider: 'mock',
      accessToken: '',
      refreshToken: '',
      expiresAt: null,
      summary: FakeMayaAccountSummary(
        wallet: walletBalance,
        savings: bufferBalance,
        timeDeposit: 0,
        goalName: investmentGoal.name,
        goalEmoji: investmentGoal.emoji,
        goalBalance: investmentGoal.balance,
        goalTarget: investmentGoal.target,
        selectedGoalId: investmentGoal.id,
        personalGoals: [investmentGoal],
        investmentHoldings: holdings,
        investmentTransactions: stockTransactions
          ..sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now)),
        creditLimit: 0,
        creditUsed: 0,
        transactions: transactions
          ..sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now)),
        updatedAt: now,
      ),
    );
    fakeMayaSyncedAccounts
      ..clear()
      ..addAll(manualAccountBalances.keys);
    for (final transaction in transactions) {
      if (transaction.isLabeled && !transaction.excludedFromInsights) {
        transactionLabelRules[transaction.patternKey] =
            TransactionLabelRule.fromTransaction(transaction);
      }
    }
    _syncFakeMayaMoneyItems();
  }

  void _applyFinancialFreedomMockProfile(User? user) {
    final now = DateTime.now();
    final normalizedEmail = (user?.email ?? email).trim().toLowerCase().isEmpty
        ? 'freedom@gmail.com'
        : (user?.email ?? email).trim().toLowerCase();
    name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Financial Freedom Account';
    email = normalizedEmail;
    primaryConcern = 'Financial Freedom';
    motivation = 'Financial Freedom';
    reflectedMotivation =
        'Fund everyday enjoyment, recurring lifestyle costs, and personal experiences without pulling from core bills.';
    selectedGoalId = 'G8';
    selectedGoal = 'Lifestyle Fund';
    selectedGoalDescription =
        'Create room for hobbies, memberships, and chosen experiences without disrupting other goals.';
    selectedGoalMonthlyTarget = 6500;
    onboardingComplete = true;
    mockDataEnabled = true;
    confidence = 7;
    anxiety = 2;
    employmentStatus = 'Employed';
    incomeType = 'Stable';
    incomeRhythm = 'Twice a month';
    billsRhythm = 'Mostly scheduled';
    checkInRhythm = 'Monthly';
    responsibility = 'Personal expenses';
    selectedActionIds
      ..clear()
      ..addAll(const {'A26', 'A27', 'A28', 'A29'});
    addedGoalIds.clear();
    actionFieldValues
      ..clear()
      ..addAll({
        'A26': {'amt': '2500'},
        'A27': {'amt': '1500'},
        'A28': {'amt': '2200'},
        'A29': {'amt': '45000', 'months': '8'},
      });

    monthlySalary = 76000;
    irregularIncomeFloor = 0;
    income = 76000;
    expenses = 26300;
    variableExpenses = 6200;
    debtPayments = 0;
    investments = 12000;
    basicNeedsMonthlyTarget = 11000;
    basicNeedsAllocationPercent = .40;
    bufferAllocationPercent = .20;
    needsTarget = 11000;
    needsPercent = 40;
    financialSafetyBalance = 42000;
    safetyShieldAllocationPercent = 0;
    safetyShieldTargetMonths = 0;
    shieldTrackedBalance = 42000;
    investmentBalance = 0;
    lifestyleFundBalance = 0;
    lifestyleActivityBalance = 0;
    cashOnHandBalance = 2200;
    categorySpendingBudgets
      ..clear()
      ..addAll({
        'Entertainment': 7000,
        'Travel': 9000,
        'Food & drink': 8500,
        'Memberships': 2500,
      });

    onboardingIncomeLedger
      ..clear()
      ..add(_incomeLedgerRow(
        name: 'Salary',
        amount: 76000,
        stable: true,
        scheduled: true,
        payDay: 15,
      ));
    onboardingExpenseLedger
      ..clear()
      ..addAll([
        _expenseLedgerRow(
          name: 'Rent share',
          amount: 4500,
          layer: ExpenseLayer.basicNeeds,
          scheduled: true,
          dueDay: 5,
        ),
        _expenseLedgerRow(
          name: 'Utilities',
          amount: 2200,
          layer: ExpenseLayer.basicNeeds,
          scheduled: true,
          dueDay: 15,
        ),
        _expenseLedgerRow(
          name: 'Food and drinks',
          amount: 4300,
          layer: ExpenseLayer.basicNeeds,
        ),
        _expenseLedgerRow(
          name: 'Investment contribution',
          amount: 12000,
          layer: ExpenseLayer.debtInvestments,
          scheduled: true,
          dueDay: 28,
        ),
        _expenseLedgerRow(
          name: 'Memberships',
          amount: 2500,
          layer: ExpenseLayer.nonEssentials,
          scheduled: true,
          dueDay: 12,
        ),
        _expenseLedgerRow(
          name: 'Travel and hobbies',
          amount: 6800,
          layer: ExpenseLayer.nonEssentials,
        ),
      ]);
    _syncOnboardingBaselineTotals();
    cashFlowExpenses
      ..clear()
      ..addAll([
        CashFlowExpense('Rent share', 4500),
        CashFlowExpense('Utilities', 2200),
        CashFlowExpense('Food and drinks', 4300),
        CashFlowExpense(
          'Investment contribution',
          12000,
          layer: ExpenseLayer.debtInvestments,
        ),
        CashFlowExpense(
          'Memberships',
          2500,
          layer: ExpenseLayer.nonEssentials,
        ),
        CashFlowExpense(
          'Travel and hobbies',
          6800,
          layer: ExpenseLayer.nonEssentials,
        ),
      ]);
    onboardingBaselines
      ..clear()
      ..addAll({
        'income_baseline': '76000.00',
        'stable_income': '76000.00',
        'variable_income': '0.00',
        'monthly_expenses': '26300.00',
        'essential_expenses': '11000.00',
        'discretionary_spend': '9300.00',
        'investment_balance': '0.00',
        'emergency_balance': '42000.00',
      });

    jarLedger.clear();
    d1Ledger.clear();
    shieldLedger.clear();
    billObligations.clear();
    manualTransactions.clear();
    transactionLabelRules.clear();
    goalBucketOverrides.clear();
    planAdjustmentActions.clear();
    anxietyCheckIns
      ..clear()
      ..addAll({
        DateTime(now.year, now.month - 3, 28).toIso8601String(): 3,
        DateTime(now.year, now.month - 2, 28).toIso8601String(): 3,
        DateTime(now.year, now.month - 1, 28).toIso8601String(): 2,
        DateTime(now.year, now.month, now.day).toIso8601String(): 2,
      });

    lifestyleHobbies
      ..clear()
      ..addAll([
        {
          'id': 'freedom_travel',
          'name': 'Weekend Trips',
          'target': 24000.0,
          'months': 8,
          'createdAt': DateTime(now.year, now.month - 3, 3).toIso8601String(),
        },
        {
          'id': 'freedom_music',
          'name': 'Music Lessons',
          'target': 12000.0,
          'months': 6,
          'createdAt': DateTime(now.year, now.month - 2, 8).toIso8601String(),
        },
        {
          'id': 'freedom_camera',
          'name': 'Camera Upgrade',
          'target': 18000.0,
          'months': 10,
          'createdAt': DateTime(now.year, now.month - 1, 12).toIso8601String(),
        },
      ]);

    final transactions = <FakeMayaTransaction>[];
    final ledger = <Map<String, dynamic>>[];
    var walletBalance = 32000.0;
    var needs = 7000.0;
    var buffer = 18000.0;
    var lifestyleFund = 9000.0;
    const monthOffsets = [3, 2, 1, 0];
    const subscriptionReserve = {3: 2200.0, 2: 2500.0, 1: 2700.0, 0: 2500.0};
    const paydayContributions = {
      3: [1500.0, 1200.0],
      2: [1500.0, 1500.0],
      1: [1500.0, 1700.0],
      0: [1500.0, 1500.0],
    };
    const hobbyDeposits = {
      3: [('freedom_travel', 2500.0), ('freedom_music', 1200.0)],
      2: [('freedom_travel', 3200.0), ('freedom_music', 1600.0)],
      1: [('freedom_travel', 2800.0), ('freedom_camera', 1900.0)],
      0: [('freedom_music', 1800.0), ('freedom_camera', 2200.0)],
    };
    const weeklyLifestyleSpend = {
      3: [1600.0, 2300.0, 1800.0, 1200.0],
      2: [1900.0, 2100.0, 2600.0, 1700.0],
      1: [1500.0, 1800.0, 2200.0, 1400.0],
      0: [1700.0, 1950.0, 2350.0, 900.0],
    };

    for (final offset in monthOffsets) {
      final month = DateTime(now.year, now.month - offset);
      final paydays = [
        DateTime(month.year, month.month, 15, 9),
        DateTime(month.year, month.month + 1, 0, 9),
      ];
      final paydayAmounts = paydayContributions[offset]!;
      for (var i = 0; i < paydays.length; i++) {
        final payday = paydays[i];
        if (payday.isAfter(now)) continue;
        final transactionId = 'ff-salary-${month.year}-${month.month}-$i';
        walletBalance += 38000;
        transactions.add(_demoTransaction(
          id: transactionId,
          title: 'Cash in',
          detail: 'From: Employer payroll',
          amount: 38000,
          date: payday,
          category: 'Salary',
          source: 'E-wallet',
        ));

        final needsIn =
            math.min<double>(15200, math.max(0, needsTarget - needs));
        final bufferIn = 7600 + (15200 - needsIn);
        needs = math.min(needsTarget, needs + needsIn);
        buffer += bufferIn;
        jarLedger.add(JarEvent(
          timestamp: payday.add(const Duration(hours: 1)),
          type: JarEventType.income,
          needsIn: needsIn,
          needsOut: 0,
          bufferIn: bufferIn,
          bufferOut: 0,
          sentence:
              '${money(38000)} salary -> ${money(needsIn)} Needs, ${money(bufferIn)} Buffer',
        ));

        final contribution = paydayAmounts[i];
        walletBalance = math.max(0, walletBalance - contribution);
        lifestyleFund += contribution;
        ledger.add({
          'type': 'lifestyle_payday',
          'date': payday.add(const Duration(hours: 2)).toIso8601String(),
          'sourceDate': payday.toIso8601String(),
          'sourceTransactionId': transactionId,
          'amount': contribution,
          'destination': 'Personal Lifestyle Fund',
          'label': contribution >= 1500
              ? 'Payday enjoyment contribution'
              : 'Partial payday enjoyment contribution',
        });
        transactions.add(_demoTransaction(
          id: 'ff-payday-transfer-${month.year}-${month.month}-$i',
          title: 'Fund transfer',
          detail: 'To: Personal Lifestyle Fund',
          amount: -contribution,
          date: payday.add(const Duration(hours: 2)),
          category: 'Transfer',
          source: 'E-wallet',
        ));
      }

      final reserveDate = DateTime(month.year, month.month, 3, 10);
      if (!reserveDate.isAfter(now)) {
        final amount = subscriptionReserve[offset]!;
        walletBalance = math.max(0, walletBalance - amount);
        lifestyleFund += amount;
        ledger.add({
          'type': 'lifestyle_subscription_reserve',
          'date': reserveDate.toIso8601String(),
          'amount': amount,
          'destination': 'Personal Lifestyle Fund',
          'label': 'Subscriptions and memberships reserve',
        });
        transactions.add(_demoTransaction(
          id: 'ff-subscription-reserve-${month.year}-${month.month}',
          title: 'Fund transfer',
          detail: 'To: Personal Lifestyle Fund',
          amount: -amount,
          date: reserveDate,
          category: 'Transfer',
          source: 'E-wallet',
        ));
      }

      for (final item in hobbyDeposits[offset]!) {
        final date = DateTime(month.year, month.month, 21, 11)
            .add(Duration(days: hobbyDeposits[offset]!.indexOf(item) * 3));
        if (date.isAfter(now)) continue;
        walletBalance = math.max(0, walletBalance - item.$2);
        lifestyleFund += item.$2;
        ledger.add({
          'type': 'lifestyle_hobby_deposit',
          'date': date.toIso8601String(),
          'hobbyId': item.$1,
          'amount': item.$2,
          'destination': 'Personal Lifestyle Fund',
          'label': 'Hobby or activity contribution',
        });
        transactions.add(_demoTransaction(
          id: 'ff-hobby-transfer-${item.$1}-${month.year}-${month.month}',
          title: 'Fund transfer',
          detail:
              'To: ${item.$1 == 'freedom_travel' ? 'Weekend Trips' : item.$1 == 'freedom_music' ? 'Music Lessons' : 'Camera Upgrade'}',
          amount: -item.$2,
          date: date,
          category: 'Transfer',
          source: 'E-wallet',
        ));
      }

      for (final bill in [
        (
          DateTime(month.year, month.month, 5, 10),
          'Rent share',
          4500.0,
          'Housing'
        ),
        (
          DateTime(month.year, month.month, 12, 9),
          'Music app subscription',
          500.0,
          'Entertainment'
        ),
        (
          DateTime(month.year, month.month, 15, 18),
          'Utilities',
          2200.0,
          'Bills & utilities'
        ),
        (
          DateTime(month.year, month.month, 18, 9),
          'Gym membership',
          1200.0,
          'Memberships'
        ),
      ]) {
        if (bill.$1.isAfter(now)) continue;
        if (bill.$4 == 'Housing' || bill.$4 == 'Bills & utilities') {
          needs = math.max(0, needs - math.min(needs, bill.$3));
        } else {
          lifestyleFund = math.max(0, lifestyleFund - bill.$3);
        }
        transactions.add(_demoTransaction(
          id: 'ff-${bill.$2.toLowerCase().replaceAll(' ', '-')}-${month.year}-${month.month}',
          title: 'Bill payment',
          detail: 'To: ${bill.$2}',
          amount: -bill.$3,
          date: bill.$1,
          category: bill.$4,
          source: bill.$4 == 'Housing' || bill.$4 == 'Bills & utilities'
              ? 'Basic Needs Fund'
              : 'Lifestyle Fund',
        ));
      }

      final spendAmounts = weeklyLifestyleSpend[offset]!;
      for (var i = 0; i < spendAmounts.length; i++) {
        final date = DateTime(month.year, month.month, 6 + i * 6, 14);
        if (date.isAfter(now)) continue;
        final amount = spendAmounts[i];
        lifestyleFund = math.max(0, lifestyleFund - amount);
        transactions.add(_demoTransaction(
          id: 'ff-enjoy-${month.year}-${month.month}-$i',
          title: i.isEven ? 'Paid merchant' : 'Sent money',
          detail: i.isEven ? 'To: Restaurant and cafe' : 'To: Weekend activity',
          amount: -amount,
          date: date,
          category: i.isEven ? 'Food & drink' : 'Entertainment',
          source: 'Lifestyle Fund',
        ));
      }
    }

    lifestyleFundBalance = lifestyleFund;
    lifestyleActivityBalance = 0;
    needsBalance = needs;
    bufferBalance = buffer;
    essentialExpensesBalance = needs;
    d1Ledger
      ..clear()
      ..addAll(ledger
        ..sort((a, b) => DateTime.parse(b['date'].toString())
            .compareTo(DateTime.parse(a['date'].toString()))));
    jarLedger.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    fakeMayaBucketCreationAllowed = true;
    confirmedFakeMayaBucketMotivations
      ..clear()
      ..add('Financial Freedom');

    final lifestyleGoal = FakeMayaPersonalGoal.defaultForId(
      FakeMayaPersonalGoal.personalLifestyleFundId,
    ).copyWith(
      balance: lifestyleFundBalance,
      target: 54000,
      daysLeft: 210,
    );
    fakeMayaLink = FakeMayaLink(
      userId: 'mock-freedom-fakemaya',
      email: normalizedEmail,
      name: name,
      phone: '+63 917 555 0180',
      provider: 'mock',
      accessToken: '',
      refreshToken: '',
      expiresAt: null,
      summary: FakeMayaAccountSummary(
        wallet: walletBalance,
        savings: bufferBalance,
        timeDeposit: 0,
        goalName: lifestyleGoal.name,
        goalEmoji: lifestyleGoal.emoji,
        goalBalance: lifestyleGoal.balance,
        goalTarget: lifestyleGoal.target,
        selectedGoalId: lifestyleGoal.id,
        personalGoals: [lifestyleGoal],
        creditLimit: 0,
        creditUsed: 0,
        transactions: transactions
          ..sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now)),
        updatedAt: now,
      ),
    );
    fakeMayaSyncedAccounts
      ..clear()
      ..addAll(manualAccountBalances.keys);
    for (final transaction in transactions) {
      if (transaction.isLabeled && !transaction.excludedFromInsights) {
        transactionLabelRules[transaction.patternKey] =
            TransactionLabelRule.fromTransaction(transaction);
      }
    }
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
      'mockDataEnabled': mockDataEnabled,
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
      'fakeMayaBucketCreationAllowed': fakeMayaBucketCreationAllowed,
      'confirmedFakeMayaBucketMotivations':
          confirmedFakeMayaBucketMotivations.toList()..sort(),
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
      'lifestyleHobbies': lifestyleHobbies,
      'billObligations': billObligations,
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
    final savedBillObligations = data['billObligations'];
    if (savedBillObligations is Iterable) {
      billObligations
        ..clear()
        ..addAll(savedBillObligations.whereType<Map>().map(
              (entry) => Map<String, dynamic>.from(entry),
            ));
    }
    final savedLifestyleHobbies = data['lifestyleHobbies'];
    if (savedLifestyleHobbies is Iterable) {
      lifestyleHobbies
        ..clear()
        ..addAll(savedLifestyleHobbies.whereType<Map>().map(
              (entry) => Map<String, dynamic>.from(entry),
            ));
    }
    _migrateLegacyLifestyleHobbyIfNeeded();
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
    fakeMayaBucketCreationAllowed =
        data['fakeMayaBucketCreationAllowed'] as bool? ??
            fakeMayaBucketCreationAllowed;
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
    mockDataEnabled = data['mockDataEnabled'] as bool? ?? mockDataEnabled;
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
    _replaceSet(
      confirmedFakeMayaBucketMotivations,
      data['confirmedFakeMayaBucketMotivations'],
    );
    backfillMissingOnboardingLedgers();
    backfillMainAccountGoalDefaults();
    backfillFeasibleActionDefaults();
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

  bool backfillMissingOnboardingLedgers() {
    var changed = false;
    if (onboardingIncomeLedger.isEmpty) {
      final fallback = _legacyIncomeLedger();
      if (fallback.isNotEmpty) {
        onboardingIncomeLedger.addAll(fallback);
        changed = true;
      }
    }
    if (onboardingExpenseLedger.isEmpty) {
      final fallback = _legacyExpenseLedger();
      if (fallback.isNotEmpty) {
        onboardingExpenseLedger.addAll(fallback);
        changed = true;
      }
    }
    if (changed) {
      _syncOnboardingBaselineTotals();
    }
    return changed;
  }

  bool backfillFeasibleActionDefaults() {
    if (!selectedActionIds.contains('A19') &&
        !actionFieldValues.containsKey('A19')) {
      return false;
    }
    final fields = actionFieldValues['A19'] ?? const <String, String>{};
    final current = _doubleFrom(fields['amt'], 0);
    final oldExpenseBuffer = _roundMoney(
        _monthlyExpenseBase(this) * _recommendedEverydayFundMonths(this));
    final oldHardcodedDefaults = {12000.0, 20000.0, 30000.0};
    final shouldUpdate = current <= 0 ||
        (current - oldExpenseBuffer).abs() < 1 ||
        oldHardcodedDefaults.any((value) => (current - value).abs() < 1);
    if (!shouldUpdate) return false;

    final recommended = _recommendedEssentialFundFloor(this).round().toString();
    actionFieldValues['A19'] = {
      ...fields,
      'amt': recommended,
    };
    return true;
  }

  bool backfillMainAccountGoalDefaults() {
    if (email.trim().toLowerCase() != 'main@gmail.com') return false;
    var changed = false;
    if (primaryConcern.trim().isEmpty) {
      primaryConcern = 'Cash Flow & Basic Needs';
      motivation = 'Cash Flow & Basic Needs';
      changed = true;
    }
    if (selectedGoalId.trim().isEmpty) {
      selectedGoalId = 'G1';
      selectedGoal = 'Maintain Available Cash';
      selectedGoalDescription =
          'Maintain enough available cash while also steadily building Financial Safety.';
      changed = true;
    }
    if (addedGoalIds.add('G3')) changed = true;
    for (final id in const {
      'A1',
      'A3',
      'A20',
      'A19',
      'A9',
      'A8',
      'A22',
      'A10'
    }) {
      if (selectedActionIds.add(id)) changed = true;
    }
    final defaults = <String, Map<String, String>>{
      'A1': {'pct': '55'},
      'A3': {'amt': '10000', 'categories': 'Food & drink,Transport'},
      'A20': {'amt': '50000'},
      'A19': {'amt': '12000'},
      'A9': {'amt': '3500'},
      'A8': {'pct': '10'},
      'A22': {'months': '3'},
      'A10': {'days': '7'},
    };
    for (final entry in defaults.entries) {
      actionFieldValues.putIfAbsent(entry.key, () {
        changed = true;
        return entry.value;
      });
    }
    return changed;
  }

  List<Map<String, dynamic>> _legacyIncomeLedger() {
    final rows = <Map<String, dynamic>>[];
    final stableAmount = monthlySalary > 0 ? monthlySalary : 0.0;
    final variableAmount =
        irregularIncomeFloor > 0 ? irregularIncomeFloor : 0.0;
    final remainingIncome =
        math.max(0.0, income - stableAmount - variableAmount);

    if (stableAmount > 0) {
      rows.add(_incomeLedgerRow(
        name: 'Salary or main income',
        amount: stableAmount,
        stable: true,
        scheduled: incomeRhythm.toLowerCase().contains('monthly'),
      ));
    }
    if (variableAmount > 0) {
      rows.add(_incomeLedgerRow(
        name: 'Variable income baseline',
        amount: variableAmount,
        stable: false,
      ));
    }
    if (remainingIncome > 0) {
      rows.add(_incomeLedgerRow(
        name: rows.isEmpty ? 'Monthly income baseline' : 'Other income',
        amount: remainingIncome,
        stable: incomeType.toLowerCase().contains('fixed'),
        scheduled: incomeRhythm.toLowerCase().contains('monthly'),
      ));
    }
    if (rows.isNotEmpty) return rows;
    return _presetIncomeLedgerForEmail(email);
  }

  List<Map<String, dynamic>> _legacyExpenseLedger() {
    if (cashFlowExpenses.isNotEmpty) {
      return [
        for (final expense in cashFlowExpenses)
          _expenseLedgerRow(
            name: expense.name,
            amount: expense.budget,
            layer: expense.layer,
          ),
      ];
    }

    final rows = <Map<String, dynamic>>[];
    if (expenses > 0) {
      rows.add(_expenseLedgerRow(
        name: 'Fixed monthly expenses',
        amount: expenses,
        layer: ExpenseLayer.basicNeeds,
      ));
    }
    if (debtPayments > 0) {
      rows.add(_expenseLedgerRow(
        name: 'Debt payments',
        amount: debtPayments,
        layer: ExpenseLayer.debtInvestments,
      ));
    }
    if (variableExpenses > 0) {
      rows.add(_expenseLedgerRow(
        name: 'Variable monthly expenses',
        amount: variableExpenses,
        layer: ExpenseLayer.nonEssentials,
      ));
    }
    if (rows.isNotEmpty) return rows;
    return _presetExpenseLedgerForEmail(email);
  }

  Map<String, dynamic> _incomeLedgerRow({
    required String name,
    required double amount,
    required bool stable,
    bool scheduled = false,
    int? payDay,
  }) {
    return {
      'name': name,
      'amount': amount,
      'stable': stable,
      'scheduled': scheduled,
      'payDay': scheduled ? payDay ?? 15 : null,
      'layer': ExpenseLayer.basicNeeds.label,
    };
  }

  Map<String, dynamic> _expenseLedgerRow({
    required String name,
    required double amount,
    required ExpenseLayer layer,
    bool scheduled = false,
    int? dueDay,
  }) {
    return {
      'name': name,
      'amount': amount,
      'essential': layer == ExpenseLayer.basicNeeds,
      'expenseType': layer.name,
      'scheduled': scheduled,
      'dueDay': scheduled ? dueDay : null,
    };
  }

  List<Map<String, dynamic>> _presetIncomeLedgerForEmail(String email) {
    final normalized = email.trim().toLowerCase();
    final amount = switch (normalized) {
      'cashflow@gmail.com' => 32000.0,
      'emergency@gmail.com' => 42000.0,
      'accumulating@gmail.com' => 58000.0,
      'freedom@gmail.com' => 76000.0,
      'main@gmail.com' => 50000.0,
      _ => 0.0,
    };
    if (amount <= 0) return const [];
    return [
      _incomeLedgerRow(
        name: normalized == 'cashflow@gmail.com'
            ? 'Project client work'
            : 'Salary or main income',
        amount: amount,
        stable: normalized != 'cashflow@gmail.com',
        scheduled: normalized != 'cashflow@gmail.com',
      ),
    ];
  }

  List<Map<String, dynamic>> _presetExpenseLedgerForEmail(String email) {
    final normalized = email.trim().toLowerCase();
    final commonBasicNeeds = [
      _expenseLedgerRow(
        name: 'Rent share',
        amount: 4500,
        layer: ExpenseLayer.basicNeeds,
        scheduled: true,
        dueDay: 5,
      ),
      _expenseLedgerRow(
        name: 'Utilities',
        amount: 2200,
        layer: ExpenseLayer.basicNeeds,
        scheduled: true,
        dueDay: 15,
      ),
      _expenseLedgerRow(
        name: 'Food and drinks',
        amount: 1500,
        layer: ExpenseLayer.basicNeeds,
      ),
      _expenseLedgerRow(
        name: 'Transport',
        amount: 800,
        layer: ExpenseLayer.basicNeeds,
      ),
    ];
    return switch (normalized) {
      'cashflow@gmail.com' => [
          ...commonBasicNeeds,
          _expenseLedgerRow(
            name: 'Health insurance',
            amount: 1200,
            layer: ExpenseLayer.emergencyInsurance,
            scheduled: true,
            dueDay: 20,
          ),
          _expenseLedgerRow(
            name: 'Student loan payment',
            amount: 2000,
            layer: ExpenseLayer.debtInvestments,
            scheduled: true,
            dueDay: 25,
          ),
          _expenseLedgerRow(
            name: 'Streaming subscriptions',
            amount: 700,
            layer: ExpenseLayer.nonEssentials,
            scheduled: true,
            dueDay: 12,
          ),
          _expenseLedgerRow(
            name: 'Gym membership',
            amount: 800,
            layer: ExpenseLayer.nonEssentials,
            scheduled: true,
            dueDay: 18,
          ),
          _expenseLedgerRow(
            name: 'Everyday enjoyment',
            amount: 1498,
            layer: ExpenseLayer.nonEssentials,
          ),
        ],
      'emergency@gmail.com' => [
          ...commonBasicNeeds,
          _expenseLedgerRow(
            name: 'Insurance premium',
            amount: 2400,
            layer: ExpenseLayer.emergencyInsurance,
            scheduled: true,
            dueDay: 20,
          ),
          _expenseLedgerRow(
            name: 'Medical sinking fund',
            amount: 1500,
            layer: ExpenseLayer.emergencyInsurance,
          ),
          _expenseLedgerRow(
            name: 'Subscriptions',
            amount: 900,
            layer: ExpenseLayer.nonEssentials,
          ),
        ],
      'accumulating@gmail.com' => [
          ...commonBasicNeeds,
          _expenseLedgerRow(
            name: 'Investment contribution',
            amount: 7000,
            layer: ExpenseLayer.debtInvestments,
            scheduled: true,
            dueDay: 28,
          ),
          _expenseLedgerRow(
            name: 'Credit card payment',
            amount: 3500,
            layer: ExpenseLayer.debtInvestments,
            scheduled: true,
            dueDay: 18,
          ),
          _expenseLedgerRow(
            name: 'Dining out',
            amount: 2200,
            layer: ExpenseLayer.nonEssentials,
          ),
        ],
      'freedom@gmail.com' => [
          ...commonBasicNeeds,
          _expenseLedgerRow(
            name: 'Investment contribution',
            amount: 12000,
            layer: ExpenseLayer.debtInvestments,
            scheduled: true,
            dueDay: 28,
          ),
          _expenseLedgerRow(
            name: 'Travel fund',
            amount: 6000,
            layer: ExpenseLayer.nonEssentials,
          ),
          _expenseLedgerRow(
            name: 'Memberships',
            amount: 2500,
            layer: ExpenseLayer.nonEssentials,
          ),
        ],
      'main@gmail.com' => [
          ...commonBasicNeeds,
          _expenseLedgerRow(
            name: 'Insurance premium',
            amount: 1800,
            layer: ExpenseLayer.emergencyInsurance,
          ),
          _expenseLedgerRow(
            name: 'Investment contribution',
            amount: 5000,
            layer: ExpenseLayer.debtInvestments,
          ),
          _expenseLedgerRow(
            name: 'Subscriptions and lifestyle',
            amount: 2500,
            layer: ExpenseLayer.nonEssentials,
          ),
        ],
      _ => const [],
    };
  }

  void _syncOnboardingBaselineTotals() {
    final incomeTotal = onboardingIncomeLedger.fold<double>(
      0,
      (total, entry) => total + _doubleFrom(entry['amount'], 0),
    );
    final stableTotal = onboardingIncomeLedger
        .where((entry) => entry['stable'] == true)
        .fold<double>(
          0,
          (total, entry) => total + _doubleFrom(entry['amount'], 0),
        );
    final variableTotal = math.max(0.0, incomeTotal - stableTotal);
    final expenseTotal = onboardingExpenseLedger.fold<double>(
      0,
      (total, entry) => total + _doubleFrom(entry['amount'], 0),
    );
    final essentialTotal = onboardingExpenseLedger
        .where(
            (entry) => expenseLayerForLedger(entry) == ExpenseLayer.basicNeeds)
        .fold<double>(
          0,
          (total, entry) => total + _doubleFrom(entry['amount'], 0),
        );
    income = incomeTotal;
    monthlySalary = stableTotal;
    irregularIncomeFloor = variableTotal;
    onboardingBaselines['income_baseline'] = incomeTotal.toStringAsFixed(2);
    onboardingBaselines['stable_income'] = stableTotal.toStringAsFixed(2);
    onboardingBaselines['variable_income'] = variableTotal.toStringAsFixed(2);
    onboardingBaselines['monthly_expenses'] = expenseTotal.toStringAsFixed(2);
    onboardingBaselines['essential_expenses'] =
        essentialTotal.toStringAsFixed(2);
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

  Future<void> saveOnboardingLedgerEdits() async {
    final incomeTotal = onboardingIncomeLedger.fold<double>(
      0,
      (total, entry) => total + _doubleFrom(entry['amount'], 0),
    );
    final stableTotal = onboardingIncomeLedger
        .where((entry) => entry['stable'] == true)
        .fold<double>(
          0,
          (total, entry) => total + _doubleFrom(entry['amount'], 0),
        );
    final variableTotal = math.max(0.0, incomeTotal - stableTotal);
    final expenseTotal = onboardingExpenseLedger.fold<double>(
      0,
      (total, entry) => total + _doubleFrom(entry['amount'], 0),
    );
    final essentialTotal = onboardingExpenseLedger
        .where(
            (entry) => expenseLayerForLedger(entry) == ExpenseLayer.basicNeeds)
        .fold<double>(
          0,
          (total, entry) => total + _doubleFrom(entry['amount'], 0),
        );
    income = incomeTotal;
    monthlySalary = stableTotal;
    irregularIncomeFloor = variableTotal;
    onboardingBaselines['income_baseline'] = incomeTotal.toStringAsFixed(2);
    onboardingBaselines['stable_income'] = stableTotal.toStringAsFixed(2);
    onboardingBaselines['variable_income'] = variableTotal.toStringAsFixed(2);
    onboardingBaselines['monthly_expenses'] = expenseTotal.toStringAsFixed(2);
    onboardingBaselines['essential_expenses'] =
        essentialTotal.toStringAsFixed(2);
    await saveProfile();
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

  Future<void> recordBasicNeedsBillPlan({
    String? obligationId,
    required String name,
    required double expectedAmount,
    required double fromEssentialFund,
    required double fromWallet,
    required double fromSavings,
    DateTime? dueDate,
  }) async {
    if (expectedAmount <= 0) return;
    final essential = fromEssentialFund.clamp(0, expectedAmount).toDouble();
    final wallet = fromWallet.clamp(0, expectedAmount).toDouble();
    final savings = fromSavings.clamp(0, expectedAmount).toDouble();
    final existingIndex = obligationId?.trim().isNotEmpty == true
        ? billObligations.indexWhere((bill) => bill['id'] == obligationId)
        : -1;
    final existing = existingIndex >= 0
        ? Map<String, dynamic>.from(billObligations[existingIndex])
        : <String, dynamic>{};
    final priorPaid = _doubleFrom(existing['paidAmount'], 0);
    final paymentCapacity = math.max(0, expectedAmount - priorPaid);
    final paidAmount = math.min(paymentCapacity, essential + wallet + savings);
    if (essential > 0) {
      await _withdrawFakeMayaPersonalGoalToWallet(
        essential,
        personalGoalId: FakeMayaPersonalGoal.essentialExpenseFundId,
      );
      essentialExpensesBalance =
          math.max(0, essentialExpensesBalance - essential);
    }
    if (savings > 0) {
      await _withdrawFakeMayaSavingsToWallet(savings);
    }

    final now = DateTime.now();
    final id = obligationId?.trim().isNotEmpty == true
        ? obligationId!.trim()
        : 'bill_${now.microsecondsSinceEpoch}';
    final index = existingIndex >= 0
        ? existingIndex
        : billObligations.indexWhere((bill) => bill['id'] == id);
    final totalPaid = math.min(expectedAmount, priorPaid + paidAmount);
    final next = {
      ...existing,
      'id': id,
      'name': name.trim().isEmpty ? 'Basic needs bill' : name.trim(),
      'expectedAmount': expectedAmount,
      'paidAmount': totalPaid,
      'dueDate': (dueDate ??
              DateTime.tryParse(existing['dueDate']?.toString() ?? '') ??
              now)
          .toIso8601String(),
      'expenseType': ExpenseLayer.basicNeeds.name,
      'status': totalPaid >= expectedAmount ? 'paid' : 'partial',
      'updatedAt': now.toIso8601String(),
      'createdAt': existing['createdAt'] ?? now.toIso8601String(),
    };
    if (index >= 0) {
      billObligations[index] = next;
    } else {
      billObligations.insert(0, next);
    }
    d1Ledger.insert(0, {
      'type': 'bill_plan',
      'date': now.toIso8601String(),
      'billId': id,
      'billName': next['name'],
      'expectedAmount': expectedAmount,
      'paidAmount': paidAmount,
      'remainingAmount': math.max(0, expectedAmount - totalPaid),
      'fromEssentialFund': essential,
      'fromWallet': wallet,
      'fromSavings': savings,
    });
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
        transaction.isInternalFakeMayaTransfer ||
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
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) {
      throw const FakeMayaException(
          'Not enough in FakeMaya wallet for this transfer.');
    }
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.essentialExpenseFundId,
    );
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
            !income.isInternalFakeMayaTransfer &&
            !hasEssentialAllocationForIncome(income.transactionId))
        .toList();
    if (pending.isEmpty) return;
    final clampedPercentage = percentage.clamp(0, 100).toDouble();
    final totalIncome =
        pending.fold<double>(0, (total, income) => total + income.amount);
    final totalAllocation = totalIncome * clampedPercentage / 100;
    final obligationAmount = math
        .min(
          openBasicNeedsBillNeed,
          math.max(0, totalIncome - totalAllocation),
        )
        .toDouble();
    if (totalAllocation <= 0 && obligationAmount <= 0) return;
    if (fakeMayaLink != null && totalAllocation > unallocatedFakeMayaWallet) {
      throw const FakeMayaException(
          'Not enough in FakeMaya wallet for this transfer.');
    }
    if (totalAllocation > 0) {
      await _moveFakeMayaWalletTo(
        totalAllocation,
        FakeMayaGoalAccount.personalGoal,
        personalGoalId: FakeMayaPersonalGoal.essentialExpenseFundId,
      );
      essentialExpensesBalance += totalAllocation;
    }
    if (obligationAmount > 0) {
      _applyIncomeToOpenBasicNeedsBills(obligationAmount);
    }
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
        if (obligationAmount > 0) 'billShortfallReserved': obligationAmount,
      });
    }
    await _saveProfileAfterFakeMayaTransfer();
    notifyListeners();
  }

  void _applyIncomeToOpenBasicNeedsBills(double amount) {
    var remaining = amount;
    for (var i = 0; i < billObligations.length && remaining > 0; i++) {
      final bill = billObligations[i];
      if (expenseLayerForLedger(bill) != ExpenseLayer.basicNeeds) continue;
      final billRemaining = _billRemaining(bill);
      if (billRemaining <= 0) continue;
      final applied = math.min(remaining, billRemaining);
      final paid = _doubleFrom(bill['paidAmount'], 0) + applied;
      billObligations[i] = {
        ...bill,
        'paidAmount': paid,
        'status':
            paid >= _doubleFrom(bill['expectedAmount'], 0) ? 'paid' : 'partial',
        'updatedAt': DateTime.now().toIso8601String(),
      };
      d1Ledger.insert(0, {
        'type': 'bill_shortfall_reserved',
        'date': DateTime.now().toIso8601String(),
        'billId': bill['id'],
        'billName': bill['name'],
        'amount': applied,
      });
      remaining -= applied;
    }
  }

  Future<void> _saveProfileAfterFakeMayaTransfer() async {
    if (!isSignedIn) return;
    try {
      await saveProfile();
    } catch (error) {
      debugPrint('Shellby profile save failed after FakeMaya transfer: $error');
    }
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
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.emergencyFundId,
    );
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
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.emergencyFundId,
    );
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
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.investmentFundId,
    );
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
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.investmentFundId,
    );
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

  /// A30: keep the investment portfolio on track to meet a target annual
  /// return. There's no natural "day one" for a return calculation, so
  /// tracking starts explicitly and is anchored to the most recent
  /// 'investment_return_baseline' ledger entry - mirroring how
  /// [lastInvestmentReviewDate] reads its own marker entries rather than a
  /// separate persisted field.
  Map<String, dynamic>? get _investmentReturnBaselineEntry {
    for (final entry in d1Ledger) {
      if (entry['type'] == 'investment_return_baseline') return entry;
    }
    return null;
  }

  DateTime? get investmentReturnBaselineDate {
    final date = _investmentReturnBaselineEntry?['date']?.toString();
    return date == null ? null : DateTime.tryParse(date);
  }

  double get investmentReturnBaselineValue =>
      (_investmentReturnBaselineEntry?['balance'] as num?)?.toDouble() ?? 0;

  /// Sum of investment_gain/investment_loss ledger entries recorded since
  /// tracking started. Contributions (investment_deposit/monthly/windfall)
  /// are deliberately excluded so this reflects market performance only,
  /// not money the user added.
  double get investmentNetReturnSinceBaseline {
    final baseline = investmentReturnBaselineDate;
    if (baseline == null) return 0;
    var total = 0.0;
    for (final entry in d1Ledger) {
      final type = entry['type'];
      if (type != 'investment_gain' && type != 'investment_loss') continue;
      final date = DateTime.tryParse(entry['date']?.toString() ?? '');
      if (date == null || date.isBefore(baseline)) continue;
      final amount = (entry['amount'] as num?)?.toDouble() ?? 0;
      total += type == 'investment_gain' ? amount : -amount;
    }
    return total;
  }

  double get investmentReturnPercentSinceBaseline {
    final baselineValue = investmentReturnBaselineValue;
    if (baselineValue <= 0) return 0;
    return investmentNetReturnSinceBaseline / baselineValue * 100;
  }

  /// Projects the return-to-date to a full year, so a tracking window
  /// shorter than 12 months can still be compared fairly against an annual
  /// target (e.g. +2% after 2 months reads as +12% annualized).
  double get investmentAnnualizedReturnPercent {
    final baseline = investmentReturnBaselineDate;
    if (baseline == null || investmentReturnBaselineValue <= 0) return 0;
    final elapsedDays = math.max(1, DateTime.now().difference(baseline).inDays);
    return investmentReturnPercentSinceBaseline * (365 / elapsedDays);
  }

  double get investmentTargetAnnualReturnPercent {
    final configured = double.tryParse(actionFieldValues['A30']?['pct'] ?? '');
    return configured ?? 8.0;
  }

  bool get isInvestmentAnnualReturnOnTrack {
    final baseline = investmentReturnBaselineDate;
    if (baseline == null) return true;
    // A brand-new tracking window sits at 0% return by definition - flagging
    // that as "behind target" on day one would be misleading, so give it a
    // week before judging performance.
    if (DateTime.now().difference(baseline).inDays < 7) return true;
    return investmentAnnualizedReturnPercent >=
        investmentTargetAnnualReturnPercent;
  }

  /// Marks "now" as the start of a new annual-return tracking window,
  /// anchored to the current portfolio balance - call the first time the
  /// user sets this action's target, or whenever they want to restart
  /// tracking (e.g. after a large one-off deposit that isn't investment
  /// return).
  Future<void> startInvestmentReturnTracking() async {
    d1Ledger.insert(0, {
      'type': 'investment_return_baseline',
      'date': DateTime.now().toIso8601String(),
      'balance': investmentBalance,
      'destination': 'Investment Portfolio',
      'label': 'Started annual return tracking',
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
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.personalLifestyleFundId,
    );
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
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.personalLifestyleFundId,
    );
    lifestyleFundBalance += amount;
    d1Ledger.insert(0, {
      'type': 'lifestyle_payday',
      'date': DateTime.now().toIso8601String(),
      'sourceDate': incomeDate.toIso8601String(),
      'sourceTransactionId': transactionId,
      'amount': amount,
      'destination': 'Personal Lifestyle Fund',
      'label': 'Payday enjoyment contribution',
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> depositLifestyleActivity(double amount) async {
    if (amount <= 0) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.personalLifestyleFundId,
    );
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

  static const int lifestyleHobbyLimit = 3;
  static const String _legacyLifestyleHobbyId = 'hobby_legacy';

  /// Saved balance for one hobby/activity target, summed from tagged
  /// deposits. The migrated legacy hobby additionally carries whatever
  /// [lifestyleActivityBalance] had already accumulated before hobbies
  /// existed as a list, so its progress doesn't appear to reset to zero.
  double lifestyleHobbyBalance(String hobbyId) {
    final tagged = d1Ledger.where((entry) {
      return entry['type'] == 'lifestyle_hobby_deposit' &&
          entry['hobbyId'] == hobbyId;
    }).fold<double>(
      0,
      (total, entry) => total + ((entry['amount'] as num?)?.toDouble() ?? 0),
    );
    return hobbyId == _legacyLifestyleHobbyId
        ? tagged + lifestyleActivityBalance
        : tagged;
  }

  DateTime? lifestyleHobbyStartedAt(String hobbyId) {
    final hobby = lifestyleHobbies.firstWhere(
      (entry) => entry['id'] == hobbyId,
      orElse: () => const {},
    );
    return DateTime.tryParse(hobby['createdAt']?.toString() ?? '');
  }

  Future<void> addLifestyleHobby({
    required String name,
    required double target,
    required int months,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        target <= 0 ||
        lifestyleHobbies.length >= lifestyleHobbyLimit) {
      return;
    }
    lifestyleHobbies.add({
      'id': 'hobby_${DateTime.now().microsecondsSinceEpoch}',
      'name': trimmed,
      'target': target,
      'months': months.clamp(1, 24),
      'createdAt': DateTime.now().toIso8601String(),
    });
    await saveProfile();
    notifyListeners();
  }

  Future<void> editLifestyleHobby(
    String hobbyId, {
    String? name,
    double? target,
    int? months,
  }) async {
    final index =
        lifestyleHobbies.indexWhere((entry) => entry['id'] == hobbyId);
    if (index == -1) return;
    final current = lifestyleHobbies[index];
    lifestyleHobbies[index] = {
      ...current,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (target != null && target > 0) 'target': target,
      if (months != null) 'months': months.clamp(1, 24),
    };
    await saveProfile();
    notifyListeners();
  }

  Future<void> removeLifestyleHobby(String hobbyId) async {
    if (!lifestyleHobbies.any((entry) => entry['id'] == hobbyId)) return;
    lifestyleHobbies.removeWhere((entry) => entry['id'] == hobbyId);
    await saveProfile();
    notifyListeners();
  }

  Future<void> depositLifestyleHobby({
    required String hobbyId,
    required double amount,
  }) async {
    if (amount <= 0) return;
    final hobby =
        lifestyleHobbies.where((entry) => entry['id'] == hobbyId).firstOrNull;
    if (hobby == null) return;
    if (fakeMayaLink != null && amount > unallocatedFakeMayaWallet) return;
    await _moveFakeMayaWalletTo(
      amount,
      FakeMayaGoalAccount.personalGoal,
      personalGoalId: FakeMayaPersonalGoal.personalLifestyleFundId,
    );
    d1Ledger.insert(0, {
      'type': 'lifestyle_hobby_deposit',
      'date': DateTime.now().toIso8601String(),
      'hobbyId': hobbyId,
      'amount': amount,
      'destination': 'Personal Lifestyle Fund',
      'label': '${hobby['name']} contribution',
    });
    await saveProfile();
    notifyListeners();
  }

  /// Accounts that configured A29 before hobbies became a named list get a
  /// single hobby synthesized from their old amt/months target and
  /// [lifestyleActivityBalance], so existing progress carries over instead
  /// of appearing to vanish. Guarded by the emptiness check so it only ever
  /// runs once per account.
  void _migrateLegacyLifestyleHobbyIfNeeded() {
    if (lifestyleHobbies.isNotEmpty) return;
    final legacyValues = actionFieldValues['A29'];
    final legacyTarget = double.tryParse(
      (legacyValues?['amt'] ?? '').replaceAll(',', ''),
    );
    final hasLegacyActivity = lifestyleActivityBalance > 0 ||
        (legacyTarget != null && legacyTarget > 0);
    if (!hasLegacyActivity) return;
    final legacyMonths = int.tryParse(legacyValues?['months'] ?? '') ?? 6;
    lifestyleHobbies.add({
      'id': _legacyLifestyleHobbyId,
      'name': 'Hobby or Activity Fund',
      'target': legacyTarget ?? 10000.0,
      'months': legacyMonths.clamp(1, 24),
      'createdAt':
          (lifestyleActivityStartedAt ?? DateTime.now()).toIso8601String(),
    });
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

  /// Runs a FakeMaya call and, if it fails because the stored session/
  /// refresh token is dead (expired, or already rotated away by another
  /// session sharing this account), clears the stale link so the app
  /// doesn't keep retrying with a token that will never work again — then
  /// rethrows so the caller can still show an error to the user.
  Future<T> _withFakeMayaSessionRecovery<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FakeMayaException catch (error) {
      if (error.sessionExpired) await unlinkFakeMayaAccount();
      rethrow;
    }
  }

  List<FakeMayaTransaction> _mergeFakeMayaTransactionLabels({
    required Iterable<FakeMayaTransaction> savedTransactions,
    required Iterable<FakeMayaTransaction> freshTransactions,
  }) {
    final savedById = {
      for (final transaction in savedTransactions)
        if (transaction.isLabeled) transaction.transactionId: transaction,
    };
    final savedByStableKey = <String, List<FakeMayaTransaction>>{};
    for (final transaction in savedTransactions) {
      if (!transaction.isLabeled) continue;
      final key = _fakeMayaTransactionStableKey(transaction);
      savedByStableKey.putIfAbsent(key, () => []).add(transaction);
    }
    final savedByFingerprint = <String, List<FakeMayaTransaction>>{};
    for (final transaction in savedTransactions) {
      if (!transaction.isLabeled) continue;
      final key = _fakeMayaTransactionFingerprint(transaction);
      savedByFingerprint.putIfAbsent(key, () => []).add(transaction);
    }
    return freshTransactions.map((transaction) {
      final savedByExactId = savedById[transaction.transactionId];
      if (savedByExactId != null) {
        return transaction.withLabelFrom(savedByExactId);
      }
      final stableKey = _fakeMayaTransactionStableKey(transaction);
      final savedMatches = savedByStableKey[stableKey];
      if (savedMatches != null && savedMatches.isNotEmpty) {
        return transaction.withLabelFrom(savedMatches.removeAt(0));
      }
      final fingerprint = _fakeMayaTransactionFingerprint(transaction);
      final fingerprintMatches = savedByFingerprint[fingerprint];
      if (fingerprintMatches == null || fingerprintMatches.isEmpty) {
        return transaction;
      }
      return transaction.withLabelFrom(fingerprintMatches.removeAt(0));
    }).toList();
  }

  List<FakeMayaTransaction> mergeFakeMayaTransactionLabelsForTesting({
    required Iterable<FakeMayaTransaction> savedTransactions,
    required Iterable<FakeMayaTransaction> freshTransactions,
  }) {
    return _mergeFakeMayaTransactionLabels(
      savedTransactions: savedTransactions,
      freshTransactions: freshTransactions,
    );
  }

  String _fakeMayaTransactionStableKey(FakeMayaTransaction transaction) {
    String clean(String value) {
      return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    }

    return [
      clean(transaction.title),
      clean(transaction.detail),
      clean(transaction.amountText),
      transaction.createdAt?.toUtc().toIso8601String() ?? '',
      clean(transaction.account ?? ''),
    ].join('|');
  }

  String _fakeMayaTransactionFingerprint(FakeMayaTransaction transaction) {
    String clean(String value) {
      return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    }

    return [
      clean(transaction.title),
      transaction.counterpartyKey,
      transaction.amount.toStringAsFixed(2),
      clean(transaction.account ?? ''),
    ].join('|');
  }

  void _applyFakeMayaSession(
    FakeMayaSession session, {
    FakeMayaLink? previousLink,
    bool preserveLabels = true,
    List<FakeMayaInvestmentHolding>? investmentHoldings,
  }) {
    final savedLink = preserveLabels ? previousLink ?? fakeMayaLink : null;
    final transactions = savedLink == null
        ? session.summary.transactions
        : _mergeFakeMayaTransactionLabels(
            savedTransactions: savedLink.summary.transactions,
            freshTransactions: session.summary.transactions,
          );
    final holdings = investmentHoldings ??
        (savedLink == null
            ? session.summary.investmentHoldings
            : _withLastKnownInvestmentPrices(
                session.summary.investmentHoldings,
                savedLink.summary.investmentHoldings,
              ));
    fakeMayaLink = FakeMayaLink(
      userId: session.userId,
      email: session.email,
      name: session.name,
      phone: session.phone,
      provider: session.provider,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      summary: session.summary.copyWith(
        investmentHoldings: holdings,
        transactions: transactions,
      ),
    );
    _syncFakeMayaMoneyItems();
  }

  Future<void> _moveFakeMayaWalletTo(
    double amount,
    FakeMayaGoalAccount account, {
    String? personalGoalId,
  }) async {
    final link = fakeMayaLink;
    if (link == null || amount <= 0) return;
    final session = await _withFakeMayaSessionRecovery(
      () => FakeMayaService.allocateFromWallet(
        link: link,
        amount: amount,
        account: account,
        personalGoalId: personalGoalId,
      ),
    );
    _applyFakeMayaSession(session, previousLink: link);
  }

  Future<void> _withdrawFakeMayaPersonalGoalToWallet(
    double amount, {
    String? personalGoalId,
  }) async {
    final link = fakeMayaLink;
    if (link == null || amount <= 0) return;
    final session = await _withFakeMayaSessionRecovery(
      () => FakeMayaService.withdrawFromPersonalGoal(
        link: link,
        amount: amount,
        personalGoalId: personalGoalId,
      ),
    );
    _applyFakeMayaSession(session, previousLink: link);
  }

  /// Pulls [amount] out of the FakeMaya bucket tied to [motivation] and
  /// tops the wallet back up by the same amount, so the bucket balance
  /// reflects the spend without double-counting the wallet's own already-
  /// recorded outflow for the transaction being labeled. Throws
  /// [FakeMayaException] if no account is linked, the bucket doesn't exist,
  /// or the bucket doesn't have enough balance to cover [amount].
  Future<void> fundTransactionFromBucket({
    required String motivation,
    required double amount,
  }) async {
    final bucketId = fakeMayaBucketIdForMotivation(motivation);
    if (bucketId == null) return;
    await _withdrawFakeMayaPersonalGoalToWallet(
      amount,
      personalGoalId: bucketId,
    );
  }

  Future<void> _withdrawFakeMayaSavingsToWallet(double amount) async {
    final link = fakeMayaLink;
    if (link == null || amount <= 0) return;
    final session = await _withFakeMayaSessionRecovery(
      () => FakeMayaService.withdrawFromSavings(
        link: link,
        amount: amount,
      ),
    );
    _applyFakeMayaSession(session, previousLink: link);
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

  void setActionsForGoal({
    required Iterable<String> allowedActionIds,
    required Iterable<String> actionIds,
    bool clearRemovedValues = true,
  }) {
    final allowed = allowedActionIds.toSet();
    final selected = actionIds.where(allowed.contains).toSet();
    final removed = selectedActionIds.where(allowed.contains).toSet()
      ..removeAll(selected);
    selectedActionIds
      ..removeWhere(allowed.contains)
      ..addAll(selected);
    if (clearRemovedValues) {
      for (final id in removed) {
        actionFieldValues.remove(id);
      }
    }
    notifyListeners();
  }

  /// Explicitly marks a canonical goal as added via "+ Add Goal". Kept
  /// separate from action-selection overlap checks so that goals sharing
  /// an action id with another goal's catalog can't falsely appear added.
  void addUnlockedGoal(String goalId) {
    addedGoalIds.add(goalId);
    notifyListeners();
  }

  /// Records that the user agreed to a FakeMaya bucket for [motivation] and,
  /// if an account is already linked, creates the bucket right away. If no
  /// account is linked yet (e.g. this runs during onboarding before the
  /// FakeMaya linking step), the agreement is remembered and the bucket is
  /// created later by [reconcileFakeMayaBuckets] once linking succeeds.
  Future<void> ensureFakeMayaBucketForMotivation(String motivation) async {
    if (mockDataEnabled) {
      notifyListeners();
      return;
    }
    confirmedFakeMayaBucketMotivations.add(motivation);
    final bucketId = fakeMayaBucketIdForMotivation(motivation);
    final link = fakeMayaLink;
    if (bucketId != null && link != null) {
      // Bucket creation is a best-effort side effect of adding a goal — if
      // the FakeMaya session has expired (or the request otherwise fails,
      // e.g. a refresh token already rotated away by another session
      // sharing this demo account), don't block the goal-add flow the user
      // is actually trying to complete. The motivation stays recorded in
      // confirmedFakeMayaBucketMotivations either way, so the next
      // successful link/refresh retries this automatically via
      // reconcileFakeMayaBuckets — no manual reset or relink needed.
      try {
        final session = await _withFakeMayaSessionRecovery(
          () => FakeMayaService.ensurePersonalGoalBucket(
            link: link,
            personalGoalId: bucketId,
          ),
        );
        _applyFakeMayaSession(session, previousLink: link);
      } on FakeMayaException {
        // Swallowed - see comment above. _withFakeMayaSessionRecovery
        // already unlinked the account if the session was dead.
      }
    }
    await saveProfile();
    notifyListeners();
  }

  /// Creates any FakeMaya buckets the user has already agreed to but that
  /// couldn't be created yet because no FakeMaya account was linked at the
  /// time — call this right after a successful link.
  Future<void> reconcileFakeMayaBuckets() async {
    if (mockDataEnabled ||
        fakeMayaLink == null ||
        confirmedFakeMayaBucketMotivations.isEmpty) {
      return;
    }
    final allowedMotivations = _activeFakeMayaBucketMotivations();
    confirmedFakeMayaBucketMotivations.removeWhere(
      (motivation) => !allowedMotivations.contains(motivation),
    );
    await _pruneFakeMayaBucketsToActiveGoals();
    for (final motivation in confirmedFakeMayaBucketMotivations.toList()) {
      await ensureFakeMayaBucketForMotivation(motivation);
    }
  }

  Set<String> _activeFakeMayaBucketMotivations() {
    final motivations = <String>{};
    final onboardingMotivation =
        _fakeMayaBucketMotivationForGoalId(selectedGoalId) ?? primaryConcern;
    if (fakeMayaBucketIdForMotivation(onboardingMotivation) != null) {
      motivations.add(onboardingMotivation);
    }
    for (final goalId in addedGoalIds) {
      final motivation = _fakeMayaBucketMotivationForGoalId(goalId);
      if (motivation != null) motivations.add(motivation);
    }
    return motivations;
  }

  String? _fakeMayaBucketMotivationForGoalId(String goalId) {
    return switch (goalId.trim()) {
      'G1' || 'G2' => 'Cash Flow & Basic Needs',
      'G3' || 'G4' => 'Financial Safety',
      'G5' || 'G6' => 'Accumulating Wealth',
      'G7' || 'G8' => 'Financial Freedom',
      _ => null,
    };
  }

  Set<String> _activeFakeMayaBucketIds() {
    return {
      for (final motivation in _activeFakeMayaBucketMotivations())
        if (fakeMayaBucketIdForMotivation(motivation) case final id?) id,
    };
  }

  Future<void> _pruneFakeMayaBucketsToActiveGoals() async {
    final link = fakeMayaLink;
    if (link == null) return;
    final allowedIds = _activeFakeMayaBucketIds();
    if (allowedIds.isEmpty) return;
    try {
      final session = await _withFakeMayaSessionRecovery(
        () => FakeMayaService.pruneZeroBalancePersonalGoals(
          link: link,
          allowedPersonalGoalIds: allowedIds,
        ),
      );
      _applyFakeMayaSession(session, previousLink: link);
    } on FakeMayaException {
      // Keep refresh/link flows usable even if a stale bucket cleanup fails.
    }
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
      final session = await _withFakeMayaSessionRecovery(
        () => FakeMayaService.allocateFromWallet(
          link: link,
          amount: amount,
          account: FakeMayaGoalAccount.savings,
        ),
      );
      _applyFakeMayaSession(session, previousLink: link);
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
          final link = fakeMayaLink!;
          try {
            final session = await FakeMayaService.withdrawFromSavings(
              link: link,
              amount: remainder,
            );
            _applyFakeMayaSession(session, previousLink: link);
          } on FakeMayaException catch (error) {
            if (error.sessionExpired) await unlinkFakeMayaAccount();
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
      final link = fakeMayaLink!;
      final session = await _withFakeMayaSessionRecovery(
        () => FakeMayaService.allocateFromWallet(
          link: link,
          amount: amount,
          account: linkedAccount,
        ),
      );
      _applyFakeMayaSession(session, previousLink: link);
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
    mockDataEnabled = false;
    _applyFakeMayaSession(session, preserveLabels: false);
    fakeMayaSyncedAccounts
      ..clear()
      ..addAll(syncedAccounts ?? manualAccountBalances.keys);
    thirdPartyDataLinkingAllowed = true;
    automaticDataGatheringAllowed = true;
    await _pruneFakeMayaBucketsToActiveGoals();
    // Catch this account up on every motivation it already agreed to a
    // bucket for (onboarding, "Add goal", etc.) but that couldn't be
    // created earlier because no account was linked yet, or a prior
    // attempt failed - not just when linking happens to go through the
    // onboarding flow.
    await reconcileFakeMayaBuckets();
    await saveProfile();
    notifyListeners();
  }

  Future<void> refreshFakeMayaAccount({bool reconcileBuckets = true}) async {
    final link = fakeMayaLink;
    if (link == null) return;
    if (mockDataEnabled) {
      _syncFakeMayaMoneyItems();
      notifyListeners();
      return;
    }
    final session = await _withFakeMayaSessionRecovery(
      () => FakeMayaService.refreshSession(link),
    );
    _applyFakeMayaSession(session, previousLink: link);
    if (reconcileBuckets) {
      await _pruneFakeMayaBucketsToActiveGoals();
      // Self-heal: retry creating any bucket that's been agreed to but is
      // still missing, so a transiently-failed creation catches up the next
      // time the session refreshes successfully, with no manual action
      // needed from the user.
      await reconcileFakeMayaBuckets();
    }
    await saveProfile();
    notifyListeners();
  }

  Future<void> refreshFakeMayaAssetPrices() async {
    final link = fakeMayaLink;
    if (link == null) return;
    if (mockDataEnabled) {
      _syncFakeMayaMoneyItems();
      notifyListeners();
      return;
    }
    if (!link.canRefresh) {
      throw const FakeMayaException(
        'Unavailable to refresh assets. Please relink FakeMaya first.',
      );
    }
    final session = await _withFakeMayaSessionRecovery(
      () => FakeMayaService.refreshSession(link),
    );
    final prices = await FakeMayaService.loadLiveInvestmentPrices();
    final updatedHoldings = session.summary.investmentHoldings.map((holding) {
      final price = prices[holding.symbol.toUpperCase()];
      return price == null ? holding : holding.copyWith(price: price);
    }).toList();
    _applyFakeMayaSession(
      session,
      previousLink: link,
      investmentHoldings: updatedHoldings,
    );
    await saveProfile();
    notifyListeners();
  }

  List<FakeMayaInvestmentHolding> _withLastKnownInvestmentPrices(
    List<FakeMayaInvestmentHolding> fresh,
    List<FakeMayaInvestmentHolding> previous,
  ) {
    final previousPrices = {
      for (final holding in previous)
        if (holding.price > 0) holding.symbol.toUpperCase(): holding.price,
    };
    return fresh.map((holding) {
      if (holding.price > 0) return holding;
      final lastPrice = previousPrices[holding.symbol.toUpperCase()];
      return lastPrice == null ? holding : holding.copyWith(price: lastPrice);
    }).toList();
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
    if (link.summary.creditLimit > 0) {
      _removeStaleFakeMayaCreditPlaceholders();
    }
    assets.addAll(
      link.summary
          .toMoneyItems()
          .where((item) => fakeMayaSyncedAccounts.contains(item.name)),
    );
    assets.addAll(
      link.summary.investmentHoldings
          .where((holding) => holding.price > 0)
          .map((holding) => holding.toMoneyItem()),
    );
    final creditLiability = link.summary.creditLiability;
    if (creditLiability != null) {
      liabilities.add(creditLiability);
    }
    savings = accountBalance('Savings') +
        accountBalance('Time Deposit') +
        accountBalance('Goal Savings');
  }

  void _removeFakeMayaMoneyItems() {
    assets.removeWhere((item) => item.description.contains('FakeMaya'));
    liabilities.removeWhere((item) => item.description.contains('FakeMaya'));
  }

  void _removeStaleFakeMayaCreditPlaceholders() {
    bool isCreditPlaceholder(String value) {
      final name = value.trim().toLowerCase();
      return name == 'credit card payment' ||
          name == 'maya easy credit' ||
          (name.contains('credit') && name.contains('payment'));
    }

    onboardingExpenseLedger.removeWhere(
      (row) => isCreditPlaceholder(row['name']?.toString() ?? ''),
    );
    liabilities.removeWhere((item) => isCreditPlaceholder(item.name));
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
        ExpenseLayer.basicNeeds => 'Cash Flow & Basic Needs',
        ExpenseLayer.emergencyInsurance => 'Emergency Fund / Insurance',
        ExpenseLayer.debtInvestments => 'Assets / Liabilities',
        ExpenseLayer.nonEssentials => 'Financial Freedom expenses',
      };

  String get examples => switch (this) {
        ExpenseLayer.basicNeeds =>
          'Income, electricity, water, rent, food, transport',
        ExpenseLayer.emergencyInsurance =>
          'Emergency fund contributions, insurance premiums, medical bills',
        ExpenseLayer.debtInvestments =>
          'Assets, investments, credit card balances, loan payments',
        ExpenseLayer.nonEssentials =>
          'Freedom-related travel, memberships, hobbies, optional lifestyle',
      };
}

ExpenseLayer? expenseLayerFromValue(Object? value) {
  final name = value?.toString().trim();
  if (name == null || name.isEmpty) return null;
  final byEnumName =
      ExpenseLayer.values.where((layer) => layer.name == name).firstOrNull;
  if (byEnumName != null) return byEnumName;
  final normalized = name.toLowerCase();
  if (normalized.contains('cash') ||
      normalized.contains('basic') ||
      normalized == 'income' ||
      normalized == 'expenses') {
    return ExpenseLayer.basicNeeds;
  }
  if (normalized.contains('emergency') ||
      normalized.contains('insurance') ||
      normalized.contains('safety')) {
    return ExpenseLayer.emergencyInsurance;
  }
  if (normalized.contains('asset') ||
      normalized.contains('liabil') ||
      normalized.contains('debt') ||
      normalized.contains('investment') ||
      normalized.contains('wealth')) {
    return ExpenseLayer.debtInvestments;
  }
  if (normalized.contains('freedom') ||
      normalized.contains('non-essential') ||
      normalized.contains('nonessential') ||
      normalized.contains('lifestyle')) {
    return ExpenseLayer.nonEssentials;
  }
  return null;
}

ExpenseLayer expenseLayerForLedger(Map<String, dynamic> expense) {
  return expenseLayerFromValue(expense['expenseType'] ?? expense['layer']) ??
      ((expense['essential'] as bool? ?? false)
          ? ExpenseLayer.basicNeeds
          : ExpenseLayer.nonEssentials);
}

double _billRemaining(Map<String, dynamic> bill) {
  final expected = _doubleValue(bill['expectedAmount'] ?? bill['amount'], 0);
  final paid = _doubleValue(bill['paidAmount'], 0);
  return math.max(0.0, expected - paid);
}

double _doubleValue(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
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
