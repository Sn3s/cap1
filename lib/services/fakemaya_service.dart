// CHANGELOG (two-jar system):
// - Added withdrawFromSavings (mirrors allocateFromWallet) for emergency shortfall path.
part of '../main.dart';

enum FakeMayaGoalAccount { savings, timeDeposit, personalGoal }

class FakeMayaService {
  const FakeMayaService._();

  static const _supabaseUrl = 'https://rizxgcgooukdckpfhkkr.supabase.co';
  static const _publishableKey =
      'sb_publishable_7kUampSawoDOCylHDsHyHQ_43TopGft';
  static const _walletTable = 'wallet_states';

  static Future<FakeMayaSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      '/auth/v1/token',
      query: {'grant_type': 'password'},
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    final auth = _mapFrom(response) ?? const <String, dynamic>{};
    final user = _mapFrom(auth['user']) ?? const <String, dynamic>{};
    final userId = user['id'] as String?;
    if (userId == null || userId.isEmpty) {
      throw const FakeMayaException('FakeMaya did not return an account id.');
    }

    final accessToken = auth['access_token'] as String? ?? '';
    final summary = await loadWalletSummary(
      userId: userId,
      accessToken: accessToken,
      email: user['email'] as String? ?? email,
      name: _accountName(user, email),
      phone: user['phone'] as String? ?? '+63 917 000 0000',
    );
    return FakeMayaSession(
      userId: userId,
      email: user['email'] as String? ?? email.trim().toLowerCase(),
      name: _accountName(user, email),
      phone: user['phone'] as String? ?? '+63 917 000 0000',
      provider: _provider(user),
      accessToken: accessToken,
      refreshToken: auth['refresh_token'] as String? ?? '',
      expiresAt: DateTime.now().add(
        Duration(seconds: auth['expires_in'] as int? ?? 3600),
      ),
      summary: summary,
    );
  }

  static Future<FakeMayaSession> refreshSession(FakeMayaLink link) async {
    if (link.refreshToken.isEmpty) {
      throw const FakeMayaException('Please log in to FakeMaya again.');
    }
    final response = await _request(
      'POST',
      '/auth/v1/token',
      query: {'grant_type': 'refresh_token'},
      body: {'refresh_token': link.refreshToken},
    );
    final auth = _mapFrom(response) ?? const <String, dynamic>{};
    final user = _mapFrom(auth['user']) ?? const <String, dynamic>{};
    final userId = user['id'] as String? ?? link.userId;
    final accessToken = auth['access_token'] as String? ?? '';
    final summary = await loadWalletSummary(
      userId: userId,
      accessToken: accessToken,
      email: user['email'] as String? ?? link.email,
      name: _accountName(user, link.email),
      phone: user['phone'] as String? ?? link.phone,
    );
    return FakeMayaSession(
      userId: userId,
      email: user['email'] as String? ?? link.email,
      name: _accountName(user, link.email),
      phone: user['phone'] as String? ?? link.phone,
      provider: _provider(user, fallback: link.provider),
      accessToken: accessToken,
      refreshToken: auth['refresh_token'] as String? ?? link.refreshToken,
      expiresAt: DateTime.now().add(
        Duration(seconds: auth['expires_in'] as int? ?? 3600),
      ),
      summary: summary,
    );
  }

  static Future<FakeMayaAccountSummary> loadWalletSummary({
    required String userId,
    required String accessToken,
    required String email,
    required String name,
    required String phone,
  }) async {
    Object? rows;
    try {
      rows = await _request(
        'GET',
        '/rest/v1/$_walletTable',
        query: {
          'select':
              'wallet,savings,time_deposit,goal_balance,app_state,updated_at',
          'user_id': 'eq.$userId',
          'limit': '1',
        },
        accessToken: accessToken,
      );
    } on FakeMayaException catch (error) {
      if (_isMissingWalletTable(error.message)) {
        return _defaultWalletSummary();
      }
      rethrow;
    }
    if (rows is List && rows.isNotEmpty) {
      return FakeMayaAccountSummary.fromMap(_mapFrom(rows.first)!);
    }

    final fresh = _defaultWalletSummary();
    try {
      await _request(
        'POST',
        '/rest/v1/$_walletTable',
        query: {'on_conflict': 'user_id'},
        accessToken: accessToken,
        headers: {'Prefer': 'resolution=merge-duplicates'},
        body: {
          'user_id': userId,
          'email': email,
          'full_name': name,
          'phone': phone,
          'wallet': fresh.wallet,
          'savings': fresh.savings,
          'time_deposit': fresh.timeDeposit,
          'goal_balance': fresh.goalBalance,
          'app_state': fresh.toFakeMayaAppState(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } on FakeMayaException catch (error) {
      if (!_isMissingWalletTable(error.message)) rethrow;
    }
    return fresh;
  }

  static Future<FakeMayaSession> depositToPersonalGoal({
    required FakeMayaLink link,
    required double amount,
    String? personalGoalId,
  }) {
    return allocateFromWallet(
      link: link,
      amount: amount,
      account: FakeMayaGoalAccount.personalGoal,
      personalGoalId: personalGoalId,
    );
  }

  static Future<FakeMayaSession> withdrawFromSavings({
    required FakeMayaLink link,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw const FakeMayaException('Enter a valid withdrawal amount.');
    }
    final session = await refreshSession(link);
    final summary = session.summary;
    if (amount > summary.savings) {
      throw const FakeMayaException('Not enough in FakeMaya savings.');
    }
    final transaction = FakeMayaTransaction(
      title: 'Emergency withdrawal',
      detail: 'From savings',
      age: 'Just now',
      amountText: '- ${_formatPeso(amount)}',
      createdAt: DateTime.now(),
    );
    final nextSummary = summary.copyWith(
      savings: summary.savings - amount,
      wallet: summary.wallet + amount,
      transactions: [transaction, ...summary.transactions],
      updatedAt: DateTime.now(),
    );
    await _request(
      'PATCH',
      '/rest/v1/$_walletTable',
      query: {'user_id': 'eq.${session.userId}'},
      accessToken: session.accessToken,
      headers: {'Prefer': 'return=minimal'},
      body: {
        'wallet': nextSummary.wallet,
        'savings': nextSummary.savings,
        'time_deposit': nextSummary.timeDeposit,
        'goal_balance': nextSummary.goalBalance,
        'app_state': nextSummary.toFakeMayaAppState(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
    return FakeMayaSession(
      userId: session.userId,
      email: session.email,
      name: session.name,
      phone: session.phone,
      provider: session.provider,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      summary: nextSummary,
    );
  }

  static Future<FakeMayaSession> allocateFromWallet({
    required FakeMayaLink link,
    required double amount,
    required FakeMayaGoalAccount account,
    String? personalGoalId,
  }) async {
    if (amount <= 0) {
      throw const FakeMayaException('Enter a valid allocation amount.');
    }

    final session = await refreshSession(link);
    final summary = session.summary;
    if (amount > summary.wallet) {
      throw const FakeMayaException('Not enough in FakeMaya wallet.');
    }

    final transactionTitle = switch (account) {
      FakeMayaGoalAccount.savings => 'Deposited to',
      FakeMayaGoalAccount.timeDeposit => 'Express deposit',
      FakeMayaGoalAccount.personalGoal => 'Deposited to goal',
    };
    final personalGoal = account == FakeMayaGoalAccount.personalGoal
        ? summary.personalGoalById(personalGoalId) ??
            (personalGoalId?.trim().isNotEmpty == true
                ? FakeMayaPersonalGoal.defaultForId(personalGoalId!.trim())
                : summary.personalGoalById(summary.selectedGoalId))
        : null;
    final transactionDetail = switch (account) {
      FakeMayaGoalAccount.savings => 'My Savings',
      FakeMayaGoalAccount.timeDeposit => 'Maya Black',
      FakeMayaGoalAccount.personalGoal =>
        personalGoal?.name ?? summary.goalName,
    };
    final transaction = FakeMayaTransaction(
      title: transactionTitle,
      detail: transactionDetail,
      age: 'Just now',
      amountText: '+ ${_formatPeso(amount)}',
      createdAt: DateTime.now(),
    );
    final nextPersonalGoals = account == FakeMayaGoalAccount.personalGoal
        ? summary.personalGoalsWithDeposit(
            personalGoal?.id ?? personalGoalId,
            amount,
          )
        : summary.personalGoals;
    final nextSummary = summary.copyWith(
      wallet: summary.wallet - amount,
      savings: account == FakeMayaGoalAccount.savings
          ? summary.savings + amount
          : summary.savings,
      timeDeposit: account == FakeMayaGoalAccount.timeDeposit
          ? summary.timeDeposit + amount
          : summary.timeDeposit,
      goalBalance: account == FakeMayaGoalAccount.personalGoal
          ? nextPersonalGoals.fold<double>(
              0,
              (total, goal) => total + goal.balance,
            )
          : summary.goalBalance,
      goalName: account == FakeMayaGoalAccount.personalGoal
          ? personalGoal?.name
          : summary.goalName,
      goalEmoji: account == FakeMayaGoalAccount.personalGoal
          ? personalGoal?.emoji
          : summary.goalEmoji,
      goalTarget: account == FakeMayaGoalAccount.personalGoal
          ? personalGoal?.target
          : summary.goalTarget,
      selectedGoalId: account == FakeMayaGoalAccount.personalGoal
          ? personalGoal?.id ?? personalGoalId
          : summary.selectedGoalId,
      personalGoals: nextPersonalGoals,
      transactions: [transaction, ...summary.transactions],
      updatedAt: DateTime.now(),
    );

    await _request(
      'PATCH',
      '/rest/v1/$_walletTable',
      query: {'user_id': 'eq.${session.userId}'},
      accessToken: session.accessToken,
      headers: {'Prefer': 'return=minimal'},
      body: {
        'wallet': nextSummary.wallet,
        'savings': nextSummary.savings,
        'time_deposit': nextSummary.timeDeposit,
        'goal_balance': nextSummary.goalBalance,
        'app_state': nextSummary.toFakeMayaAppState(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    );

    return FakeMayaSession(
      userId: session.userId,
      email: session.email,
      name: session.name,
      phone: session.phone,
      provider: session.provider,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      summary: nextSummary,
    );
  }

  static FakeMayaAccountSummary _defaultWalletSummary() {
    final personalGoals = FakeMayaPersonalGoal.defaultGoals();
    final essentialGoal = personalGoals.first;
    return FakeMayaAccountSummary(
      wallet: 1000,
      savings: 0,
      timeDeposit: 0,
      goalName: essentialGoal.name,
      goalEmoji: essentialGoal.emoji,
      goalBalance: 0,
      goalTarget: essentialGoal.target,
      selectedGoalId: essentialGoal.id,
      personalGoals: personalGoals,
      creditLimit: 15000,
      creditUsed: 0,
      transactions: [
        FakeMayaTransaction(
          title: 'Account opened',
          detail: 'Welcome wallet funds',
          age: 'Just now',
          amountText: '+ ₱1,000.00',
          createdAt: DateTime.now(),
        ),
      ],
      updatedAt: DateTime.now(),
    );
  }

  static Future<Object?> _request(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
    Map<String, Object?>? body,
    String? accessToken,
  }) async {
    final uri = Uri.parse('$_supabaseUrl$path').replace(queryParameters: query);
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 20));
      request.headers
        ..set('apikey', _publishableKey)
        ..set(HttpHeaders.contentTypeHeader, 'application/json');
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers
            .set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
      }
      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
      }
      if (body != null) {
        request.add(utf8.encode(jsonEncode(body)));
      }
      final response =
          await request.close().timeout(const Duration(seconds: 20));
      final payload = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 20));
      final decoded = payload.isEmpty ? null : jsonDecode(payload);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = _mapFrom(decoded)?['msg'] ??
            _mapFrom(decoded)?['message'] ??
            _mapFrom(decoded)?['error_description'] ??
            'FakeMaya request failed (${response.statusCode}).';
        throw FakeMayaException(message.toString());
      }
      return decoded;
    } on SocketException {
      throw const FakeMayaException(
          'Could not reach FakeMaya. Check your connection.');
    } on TimeoutException {
      throw const FakeMayaException(
          'FakeMaya took too long to respond. Please try again.');
    } on FormatException {
      throw const FakeMayaException(
          'FakeMaya returned an unreadable response.');
    } finally {
      client.close(force: true);
    }
  }

  static Map<String, dynamic>? _mapFrom(Object? value) {
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  static bool _isMissingWalletTable(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('wallet_states') &&
        (normalized.contains('schema cache') ||
            normalized.contains('could not find the table') ||
            normalized.contains('does not exist'));
  }

  static String _accountName(Map<String, dynamic> user, String fallbackEmail) {
    final metadata =
        _mapFrom(user['user_metadata']) ?? const <String, dynamic>{};
    final fromMetadata = metadata['full_name'] ?? metadata['name'];
    if (fromMetadata is String && fromMetadata.trim().isNotEmpty) {
      return fromMetadata.trim();
    }
    final local =
        fallbackEmail.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    final parts = local.split(' ').where((part) => part.isNotEmpty);
    final name = parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
    return name.isEmpty ? 'Maya User' : name;
  }

  static String _provider(Map<String, dynamic> user,
      {String fallback = 'email'}) {
    final metadata =
        _mapFrom(user['app_metadata']) ?? const <String, dynamic>{};
    return metadata['provider'] == 'google' ? 'google' : fallback;
  }

  static String _formatPeso(double value) {
    final rounded = value.toStringAsFixed(2);
    final parts = rounded.split('.');
    final chars = parts.first.split('').reversed.toList();
    final grouped = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) grouped.add(',');
      grouped.add(chars[i]);
    }
    return '₱${grouped.reversed.join()}.${parts.last}';
  }
}

class FakeMayaException implements Exception {
  const FakeMayaException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FakeMayaSession {
  const FakeMayaSession({
    required this.userId,
    required this.email,
    required this.name,
    required this.phone,
    required this.provider,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.summary,
  });

  final String userId;
  final String email;
  final String name;
  final String phone;
  final String provider;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final FakeMayaAccountSummary summary;
}

class FakeMayaLink {
  const FakeMayaLink({
    required this.userId,
    required this.email,
    required this.name,
    required this.phone,
    required this.provider,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.summary,
  });

  final String userId;
  final String email;
  final String name;
  final String phone;
  final String provider;
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;
  final FakeMayaAccountSummary summary;

  bool get canRefresh => refreshToken.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'phone': phone,
      'provider': provider,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
      'summary': summary.toMap(),
    };
  }

  factory FakeMayaLink.fromSession(FakeMayaSession session) {
    return FakeMayaLink(
      userId: session.userId,
      email: session.email,
      name: session.name,
      phone: session.phone,
      provider: session.provider,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
      summary: session.summary,
    );
  }

  factory FakeMayaLink.fromMap(Map<String, dynamic> data) {
    return FakeMayaLink(
      userId: data['userId'] as String? ?? '',
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? 'Maya User',
      phone: data['phone'] as String? ?? '',
      provider: data['provider'] as String? ?? 'email',
      accessToken: data['accessToken'] as String? ?? '',
      refreshToken: data['refreshToken'] as String? ?? '',
      expiresAt: DateTime.tryParse(data['expiresAt'] as String? ?? ''),
      summary: FakeMayaAccountSummary.fromMap(
        Map<String, dynamic>.from(data['summary'] as Map? ?? const {}),
      ),
    );
  }
}

class FakeMayaAccountSummary {
  const FakeMayaAccountSummary({
    required this.wallet,
    required this.savings,
    required this.timeDeposit,
    required this.goalName,
    required this.goalEmoji,
    required this.goalBalance,
    required this.goalTarget,
    this.selectedGoalId = FakeMayaPersonalGoal.essentialExpenseFundId,
    this.personalGoals = const [],
    required this.creditLimit,
    required this.creditUsed,
    required this.transactions,
    required this.updatedAt,
  });

  final double wallet;
  final double savings;
  final double timeDeposit;
  final String goalName;
  final String goalEmoji;
  final double goalBalance;
  final double goalTarget;
  final String selectedGoalId;
  final List<FakeMayaPersonalGoal> personalGoals;
  final double creditLimit;
  final double creditUsed;
  final List<FakeMayaTransaction> transactions;
  final DateTime? updatedAt;

  double get totalBalance => wallet + savings + timeDeposit + goalBalance;
  double get availableCredit => math.max(0, creditLimit - creditUsed);
  FakeMayaPersonalGoal? get essentialExpenseFund =>
      personalGoalById(FakeMayaPersonalGoal.essentialExpenseFundId);

  FakeMayaAccountSummary copyWith({
    double? wallet,
    double? savings,
    double? timeDeposit,
    String? goalName,
    String? goalEmoji,
    double? goalBalance,
    double? goalTarget,
    String? selectedGoalId,
    List<FakeMayaPersonalGoal>? personalGoals,
    double? creditLimit,
    double? creditUsed,
    List<FakeMayaTransaction>? transactions,
    DateTime? updatedAt,
  }) {
    return FakeMayaAccountSummary(
      wallet: wallet ?? this.wallet,
      savings: savings ?? this.savings,
      timeDeposit: timeDeposit ?? this.timeDeposit,
      goalName: goalName ?? this.goalName,
      goalEmoji: goalEmoji ?? this.goalEmoji,
      goalBalance: goalBalance ?? this.goalBalance,
      goalTarget: goalTarget ?? this.goalTarget,
      selectedGoalId: selectedGoalId ?? this.selectedGoalId,
      personalGoals: personalGoals ?? this.personalGoals,
      creditLimit: creditLimit ?? this.creditLimit,
      creditUsed: creditUsed ?? this.creditUsed,
      transactions: transactions ?? this.transactions,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  List<MoneyItem> toMoneyItems() {
    return [
      MoneyItem('Wallet', 'Synced with FakeMaya', wallet),
      MoneyItem('Savings', 'Synced with FakeMaya', savings),
      MoneyItem('Time Deposit', 'Synced with FakeMaya', timeDeposit),
      MoneyItem('Goal Savings', 'Synced with FakeMaya', goalBalance),
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'wallet': wallet,
      'savings': savings,
      'timeDeposit': timeDeposit,
      'goalName': goalName,
      'goalEmoji': goalEmoji,
      'goalBalance': goalBalance,
      'goalTarget': goalTarget,
      'selectedGoalId': selectedGoalId,
      'personalGoals': personalGoals.map((goal) => goal.toMap()).toList(),
      'creditLimit': creditLimit,
      'creditUsed': creditUsed,
      'transactions':
          transactions.map((transaction) => transaction.toMap()).toList(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toFakeMayaAppState() {
    return {
      'wallet': wallet,
      'savings': savings,
      'timeDeposit': timeDeposit,
      'selectedGoalId': selectedGoalId,
      'personalGoals': personalGoals.map((goal) => goal.toMap()).toList(),
      'goal': (personalGoalById(selectedGoalId) ??
              personalGoalById(FakeMayaPersonalGoal.essentialExpenseFundId) ??
              _legacyPersonalGoal())
          .toMap(),
      'creditLimit': creditLimit,
      'creditUsed': creditUsed,
      'transactions':
          transactions.map((transaction) => transaction.toMap()).toList(),
    };
  }

  factory FakeMayaAccountSummary.fromMap(Map<String, dynamic> data) {
    final appState =
        Map<String, dynamic>.from(data['app_state'] as Map? ?? const {});
    final goal =
        Map<String, dynamic>.from(appState['goal'] as Map? ?? const {});
    final personalGoals = _personalGoalsFrom(
      appState['personalGoals'],
      legacyGoal: goal,
      legacyGoalBalance: data['goal_balance'],
    );
    final selectedGoalId = _stringFrom(appState['selectedGoalId'],
        FakeMayaPersonalGoal.essentialExpenseFundId);
    final selectedGoal =
        personalGoals.where((goal) => goal.id == selectedGoalId).firstOrNull;
    final displayGoal = selectedGoal ??
        personalGoals
            .where((goal) =>
                goal.id == FakeMayaPersonalGoal.essentialExpenseFundId)
            .firstOrNull;
    final totalGoalBalance = personalGoals.fold<double>(
      0,
      (total, goal) => total + goal.balance,
    );
    return FakeMayaAccountSummary(
      wallet: _doubleFrom(data['wallet'] ?? appState['wallet'], 1000),
      savings: _doubleFrom(data['savings'] ?? appState['savings'], 0),
      timeDeposit:
          _doubleFrom(data['time_deposit'] ?? appState['timeDeposit'], 0),
      goalName: _stringFrom(
          data['goalName'] ?? displayGoal?.name ?? goal['name'],
          'Personal Goal'),
      goalEmoji: _stringFrom(
        data['goalEmoji'] ?? displayGoal?.emoji ?? goal['emoji'],
        '🎯',
      ),
      goalBalance: personalGoals.isNotEmpty
          ? totalGoalBalance
          : _doubleFrom(data['goal_balance'] ?? goal['balance'], 0),
      goalTarget: _doubleFrom(
        data['goalTarget'] ?? displayGoal?.target ?? goal['target'],
        25000,
      ),
      selectedGoalId: selectedGoalId,
      personalGoals: personalGoals,
      creditLimit: _doubleFrom(appState['creditLimit'], 15000),
      creditUsed: _doubleFrom(appState['creditUsed'], 0),
      transactions:
          _transactionsFrom(appState['transactions'] ?? data['transactions']),
      updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? ''),
    );
  }

  FakeMayaPersonalGoal? personalGoalById(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    for (final goal in personalGoals) {
      if (goal.id == id) return goal;
    }
    return null;
  }

  List<FakeMayaPersonalGoal> personalGoalsWithDeposit(
    String? id,
    double amount,
  ) {
    final targetId =
        (id?.trim().isNotEmpty == true ? id!.trim() : selectedGoalId);
    final goals = personalGoals.isEmpty
        ? FakeMayaPersonalGoal.defaultGoals()
        : personalGoals;
    var found = false;
    final updated = [
      for (final goal in goals)
        if (goal.id == targetId) ...[
          goal.copyWith(balance: goal.balance + amount),
        ] else
          goal,
    ];
    found = updated.any((goal) => goal.id == targetId);
    if (!found) {
      updated.add(
        FakeMayaPersonalGoal.defaultForId(targetId).copyWith(balance: amount),
      );
    }
    return updated;
  }

  FakeMayaPersonalGoal _legacyPersonalGoal() {
    return FakeMayaPersonalGoal(
      id: selectedGoalId,
      name: goalName,
      label: 'Personal Goal',
      emoji: goalEmoji,
      account: '8189 3753 6162',
      balance: goalBalance,
      target: goalTarget,
      daysLeft: 180,
      rate: 8,
    );
  }

  static List<FakeMayaPersonalGoal> _personalGoalsFrom(
    Object? value, {
    required Map<String, dynamic> legacyGoal,
    required Object? legacyGoalBalance,
  }) {
    if (value is Iterable) {
      final goals = value
          .map((item) => item is Map
              ? FakeMayaPersonalGoal.fromMap(Map<String, dynamic>.from(item))
              : null)
          .whereType<FakeMayaPersonalGoal>()
          .toList();
      if (goals.isNotEmpty) return goals;
    }
    if (legacyGoal.isEmpty && legacyGoalBalance == null) {
      return FakeMayaPersonalGoal.defaultGoals();
    }
    final goals = FakeMayaPersonalGoal.defaultGoals();
    goals[0] = goals[0].copyWith(
      name: _stringFrom(legacyGoal['name'], goals[0].name),
      emoji: _stringFrom(legacyGoal['emoji'], goals[0].emoji),
      balance: _doubleFrom(legacyGoal['balance'] ?? legacyGoalBalance, 0),
      target: _doubleFrom(legacyGoal['target'], goals[0].target),
    );
    return goals;
  }

  static List<FakeMayaTransaction> _transactionsFrom(Object? value) {
    if (value is! Iterable) return const [];
    return value
        .map((item) => item is Map
            ? FakeMayaTransaction.fromMap(Map<String, dynamic>.from(item))
            : null)
        .whereType<FakeMayaTransaction>()
        .toList();
  }

  static double _doubleFrom(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String _stringFrom(Object? value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}

class FakeMayaPersonalGoal {
  const FakeMayaPersonalGoal({
    required this.id,
    required this.name,
    required this.label,
    required this.emoji,
    required this.account,
    required this.balance,
    required this.target,
    required this.daysLeft,
    required this.rate,
  });

  static const essentialExpenseFundId = 'B1';
  static const personalLifestyleFundId = 'B5';

  final String id;
  final String name;
  final String label;
  final String emoji;
  final String account;
  final double balance;
  final double target;
  final int daysLeft;
  final double rate;

  FakeMayaPersonalGoal copyWith({
    String? id,
    String? name,
    String? label,
    String? emoji,
    String? account,
    double? balance,
    double? target,
    int? daysLeft,
    double? rate,
  }) {
    return FakeMayaPersonalGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      account: account ?? this.account,
      balance: balance ?? this.balance,
      target: target ?? this.target,
      daysLeft: daysLeft ?? this.daysLeft,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'emoji': emoji,
      'account': account,
      'balance': balance,
      'target': target,
      'daysLeft': daysLeft,
      'rate': rate,
    };
  }

  factory FakeMayaPersonalGoal.fromMap(Map<String, dynamic> data) {
    final defaults = defaultForId(data['id']?.toString() ?? '');
    return FakeMayaPersonalGoal(
      id: _stringFrom(data['id'], defaults.id),
      name: _stringFrom(data['name'], defaults.name),
      label: _stringFrom(data['label'], defaults.label),
      emoji: _stringFrom(data['emoji'], defaults.emoji),
      account: _stringFrom(data['account'], defaults.account),
      balance: _doubleFrom(data['balance'], defaults.balance),
      target: _doubleFrom(data['target'], defaults.target),
      daysLeft: _intFrom(data['daysLeft'], defaults.daysLeft),
      rate: _doubleFrom(data['rate'], defaults.rate),
    );
  }

  static List<FakeMayaPersonalGoal> defaultGoals() {
    return [
      defaultForId('B1'),
      defaultForId('B2'),
      defaultForId('B3'),
      defaultForId('B4'),
      defaultForId('B5'),
    ];
  }

  static FakeMayaPersonalGoal defaultForId(String id) {
    return switch (id) {
      'B2' => const FakeMayaPersonalGoal(
          id: 'B2',
          name: 'Upcoming bill and payment obligations',
          label: 'Personal Goal 2',
          emoji: '🧾',
          account: '8189 3753 6102',
          balance: 0,
          target: 25000,
          daysLeft: 180,
          rate: 8,
        ),
      'B3' => const FakeMayaPersonalGoal(
          id: 'B3',
          name: 'Emergency Fund',
          label: 'Personal Goal 3',
          emoji: '🛟',
          account: '8189 3753 6103',
          balance: 0,
          target: 25000,
          daysLeft: 180,
          rate: 8,
        ),
      'B4' => const FakeMayaPersonalGoal(
          id: 'B4',
          name: 'Goal-Based savings fund',
          label: 'Personal Goal 4',
          emoji: '🎯',
          account: '8189 3753 6104',
          balance: 0,
          target: 25000,
          daysLeft: 180,
          rate: 8,
        ),
      'B5' => const FakeMayaPersonalGoal(
          id: 'B5',
          name: 'Personal Lifestyle Fund',
          label: 'Personal Goal 5',
          emoji: '✨',
          account: '8189 3753 6105',
          balance: 0,
          target: 25000,
          daysLeft: 180,
          rate: 8,
        ),
      _ => const FakeMayaPersonalGoal(
          id: 'B1',
          name: 'Essential Expense Fund',
          label: 'Personal Goal 1',
          emoji: '🏠',
          account: '8189 3753 6101',
          balance: 0,
          target: 25000,
          daysLeft: 180,
          rate: 8,
        ),
    };
  }

  static double _doubleFrom(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int _intFrom(Object? value, int fallback) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static String _stringFrom(Object? value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}

class FakeMayaTransaction {
  const FakeMayaTransaction({
    this.id,
    required this.title,
    required this.detail,
    required String age,
    required this.amountText,
    this.createdAt,
    this.category,
    this.source,
    this.account,
    this.subcategory,
    this.tag,
    this.note,
    this.excludedFromInsights = false,
    this.labeledAt,
  }) : _fallbackAge = age;

  final String? id;
  final String title;
  final String detail;
  final String _fallbackAge;
  final String amountText;
  final DateTime? createdAt;
  final String? category;
  final String? source;
  final String? account;
  final String? subcategory;
  final String? tag;
  final String? note;
  final bool excludedFromInsights;
  final DateTime? labeledAt;

  String get age {
    final timestamp = createdAt;
    return timestamp == null ? _fallbackAge : _formatDateTime(timestamp);
  }

  double get amount {
    final sign = amountText.trimLeft().startsWith('-') ? -1.0 : 1.0;
    final normalized = amountText.replaceAll(RegExp(r'[^0-9.]'), '');
    return sign * (double.tryParse(normalized) ?? 0);
  }

  String get transactionId {
    final explicit = id?.trim() ?? '';
    if (explicit.isNotEmpty) return explicit;
    final timestamp = createdAt?.toIso8601String() ?? _fallbackAge;
    return Uri.encodeComponent('$title|$detail|$timestamp|$amountText');
  }

  bool get isLabeled =>
      (category?.trim().isNotEmpty ?? false) &&
      (source?.trim().isNotEmpty ?? false);

  bool get isWalletCashMovement {
    final value = '$title $detail'.toLowerCase();
    return value.contains('cash in') || value.contains('cash out');
  }

  bool get isFakeMayaCashIn {
    final accountName = account?.trim();
    return amount > 0 &&
        title.toLowerCase().contains('cash in') &&
        (accountName == null || accountName.isEmpty || accountName == 'Wallet');
  }

  bool get isInternalFakeMayaTransfer {
    final normalizedTitle = title.trim().toLowerCase();
    final normalizedDetail = detail.trim().toLowerCase();
    return normalizedTitle == 'deposited to goal' ||
        normalizedTitle == 'express deposit' ||
        normalizedTitle == 'transferred from' ||
        (normalizedTitle == 'deposited to' &&
            (normalizedDetail == 'my savings' ||
                normalizedDetail.contains('goal') ||
                normalizedDetail.contains('fund') ||
                normalizedDetail.contains('maya black')));
  }

  String? get automaticDestination => isFakeMayaCashIn ? 'E-wallet' : null;

  String get counterpartyKey {
    var value = detail.trim().toLowerCase();
    value = value.replaceFirst(RegExp(r'^(from|to)\s*:\s*'), '');
    value = value.split('·').first.trim();
    value = value.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
    return value.isEmpty ? title.trim().toLowerCase() : value;
  }

  String get patternKey => '${amount < 0 ? 'out' : 'in'}|$counterpartyKey';

  FakeMayaTransaction copyWithLabel({
    required String category,
    required String source,
    String? subcategory,
    String? tag,
    String? note,
    bool excludedFromInsights = false,
    DateTime? labeledAt,
  }) {
    return FakeMayaTransaction(
      id: transactionId,
      title: title,
      detail: detail,
      age: _fallbackAge,
      amountText: amountText,
      createdAt: createdAt,
      category: category,
      source: source,
      account: account,
      subcategory: subcategory,
      tag: tag,
      note: note,
      excludedFromInsights: excludedFromInsights,
      labeledAt: labeledAt ?? DateTime.now(),
    );
  }

  FakeMayaTransaction withLabelFrom(FakeMayaTransaction other) {
    if (!(other.category?.trim().isNotEmpty ?? false)) return this;
    return copyWithLabel(
      category: other.category!,
      source: other.source ?? 'Basic Needs Fund',
      subcategory: other.subcategory,
      tag: other.tag,
      note: other.note,
      excludedFromInsights: other.excludedFromInsights,
      labeledAt: other.labeledAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': transactionId,
      'title': title,
      'detail': detail,
      'age': _fallbackAge,
      'amount': amountText,
      'createdAt': createdAt?.toIso8601String(),
      'category': category,
      'source': source,
      'account': account,
      'subcategory': subcategory,
      'tag': tag,
      'note': note,
      'excludedFromInsights': excludedFromInsights,
      'labeledAt': labeledAt?.toIso8601String(),
      'patternKey': patternKey,
    };
  }

  factory FakeMayaTransaction.fromMap(Map<String, dynamic> data) {
    final savedCategory = data['category'] as String?;
    final legacyFundSource = _legacyFundSource(savedCategory);
    return FakeMayaTransaction(
      id: data['id'] as String?,
      title: data['title'] as String? ?? 'FakeMaya transaction',
      detail: data['detail'] as String? ?? 'FakeMaya',
      age: data['age'] as String? ?? 'Just now',
      amountText: data['amount'] as String? ?? '',
      createdAt: _dateTimeFrom(data['createdAt'] ?? data['created_at']),
      category: legacyFundSource == null ? savedCategory : 'Other expense',
      source: data['source'] as String? ??
          legacyFundSource ??
          (savedCategory?.trim().isNotEmpty ?? false
              ? 'Basic Needs Fund'
              : null),
      account: switch (data['account'] as String?) {
        'FakeMaya Wallet' => 'Wallet',
        'FakeMaya Savings' => 'Savings',
        'FakeMaya Time Deposit' => 'Time Deposit',
        final value => value,
      },
      subcategory: data['subcategory'] as String?,
      tag: data['tag'] as String?,
      note: data['note'] as String?,
      excludedFromInsights: data['excludedFromInsights'] as bool? ?? false,
      labeledAt: DateTime.tryParse(data['labeledAt'] as String? ?? ''),
    );
  }

  static DateTime? _dateTimeFrom(Object? value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }

  static String? _legacyFundSource(String? category) {
    return switch (category?.trim().toLowerCase()) {
      'basic needs' => 'Basic Needs Fund',
      'emergency fund' => 'Emergency Fund',
      'investment' => 'Investment',
      'time deposit' => 'Time Deposit',
      _ => null,
    };
  }

  static String _formatDateTime(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    final year = local.year == DateTime.now().year ? '' : ', ${local.year}';
    return '${months[local.month - 1]} ${local.day}$year, '
        '$hour:$minute $period';
  }
}
