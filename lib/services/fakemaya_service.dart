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
      throw const FakeMayaException(
        'Your FakeMaya session has expired. Please relink your account.',
        sessionExpired: true,
      );
    }
    Object? response;
    try {
      response = await _request(
        'POST',
        '/auth/v1/token',
        query: {'grant_type': 'refresh_token'},
        body: {'refresh_token': link.refreshToken},
      );
    } on FakeMayaException catch (error) {
      // Supabase returns messages like "Invalid Refresh Token: Refresh
      // Token Not Found" (or "... Already Used") once a refresh token has
      // expired or been rotated away by a previous session — shared demo
      // accounts hit this constantly since many sessions reuse the same
      // cached token. Surface a clear, actionable message instead of the
      // raw auth error, and flag it so callers know to clear the link.
      if (error.message.toLowerCase().contains('refresh token')) {
        throw const FakeMayaException(
          'Your FakeMaya session has expired. Please relink your account.',
          sessionExpired: true,
        );
      }
      rethrow;
    }
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

  static Future<Map<String, double>> loadLiveInvestmentPrices() async {
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price',
    ).replace(queryParameters: {
      'ids': 'bitcoin,nvidia-xstock',
      'vs_currencies': 'php',
    });
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      final request =
          await client.getUrl(uri).timeout(const Duration(seconds: 10));
      final response =
          await request.close().timeout(const Duration(seconds: 10));
      final payload = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == HttpStatus.tooManyRequests) {
        throw const FakeMayaException(
          'Unavailable to refresh asset prices right now. Market price tokens are limited, so try again later.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const FakeMayaException(
          'Unavailable to refresh asset prices right now.',
        );
      }
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final btc = FakeMayaAccountSummary._doubleFrom(
          _mapFrom(data['bitcoin'])?['php'], 0);
      final nvda = FakeMayaAccountSummary._doubleFrom(
        _mapFrom(data['nvidia-xstock'])?['php'],
        0,
      );
      if (btc <= 0 || nvda <= 0) {
        throw const FakeMayaException(
          'Unavailable to refresh asset prices right now.',
        );
      }
      return {'BTC': btc, 'NVDA': nvda};
    } on FakeMayaException {
      rethrow;
    } on SocketException {
      throw const FakeMayaException(
        'Unavailable to refresh asset prices. Check your connection.',
      );
    } on TimeoutException {
      throw const FakeMayaException(
        'Unavailable to refresh asset prices right now.',
      );
    } on FormatException {
      throw const FakeMayaException(
        'Unavailable to refresh asset prices right now.',
      );
    } finally {
      client.close(force: true);
    }
  }

  /// Same live source as [loadLiveInvestmentPrices], but also carries the
  /// 24h % change CoinGecko already computes (the exact figure FakeMaya's
  /// own Crypto page shows) - used for the Accumulating Wealth insights
  /// page's per-asset performance cards.
  static Future<Map<String, FakeMayaAssetQuote>>
      loadLiveInvestmentQuotes() async {
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price',
    ).replace(queryParameters: {
      'ids': 'bitcoin,nvidia-xstock',
      'vs_currencies': 'php',
      'include_24hr_change': 'true',
    });
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      final request =
          await client.getUrl(uri).timeout(const Duration(seconds: 10));
      final response =
          await request.close().timeout(const Duration(seconds: 10));
      final payload = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == HttpStatus.tooManyRequests) {
        throw const FakeMayaException(
          'Unavailable to refresh asset prices right now. Market price tokens are limited, so try again later.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const FakeMayaException(
          'Unavailable to refresh asset prices right now.',
        );
      }
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final btc = _mapFrom(data['bitcoin']);
      final nvda = _mapFrom(data['nvidia-xstock']);
      final btcPrice = FakeMayaAccountSummary._doubleFrom(btc?['php'], 0);
      final nvdaPrice = FakeMayaAccountSummary._doubleFrom(nvda?['php'], 0);
      if (btcPrice <= 0 || nvdaPrice <= 0) {
        throw const FakeMayaException(
          'Unavailable to refresh asset prices right now.',
        );
      }
      return {
        'BTC': FakeMayaAssetQuote(
          price: btcPrice,
          changePercent24h:
              FakeMayaAccountSummary._doubleFrom(btc?['php_24h_change'], 0),
        ),
        'NVDA': FakeMayaAssetQuote(
          price: nvdaPrice,
          changePercent24h:
              FakeMayaAccountSummary._doubleFrom(nvda?['php_24h_change'], 0),
        ),
      };
    } on FakeMayaException {
      rethrow;
    } on SocketException {
      throw const FakeMayaException(
        'Unavailable to refresh asset prices. Check your connection.',
      );
    } on TimeoutException {
      throw const FakeMayaException(
        'Unavailable to refresh asset prices right now.',
      );
    } on FormatException {
      throw const FakeMayaException(
        'Unavailable to refresh asset prices right now.',
      );
    } finally {
      client.close(force: true);
    }
  }

  static const _investmentCoinGeckoIds = {
    'BTC': 'bitcoin',
    'NVDA': 'nvidia-xstock'
  };

  /// Live historical PHP price series for BTC/NVDA over the last [days],
  /// straight from CoinGecko's public market_chart endpoint - the same
  /// source FakeMaya's own Crypto page uses for live prices. Used to chart
  /// portfolio value over time without needing FakeMaya to keep its own
  /// price history (it only ever stores the current price).
  static Future<Map<String, List<FakeMayaPricePoint>>>
      loadHistoricalInvestmentPrices({required int days}) async {
    final result = <String, List<FakeMayaPricePoint>>{};
    for (final entry in _investmentCoinGeckoIds.entries) {
      result[entry.key] =
          await _fetchMarketChart(coinId: entry.value, days: days);
    }
    return result;
  }

  static Future<List<FakeMayaPricePoint>> _fetchMarketChart({
    required String coinId,
    required int days,
  }) async {
    final uri = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/$coinId/market_chart',
    ).replace(queryParameters: {
      'vs_currency': 'php',
      'days': days.toString(),
    });
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      final request =
          await client.getUrl(uri).timeout(const Duration(seconds: 10));
      final response =
          await request.close().timeout(const Duration(seconds: 12));
      final payload = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == HttpStatus.tooManyRequests) {
        throw const FakeMayaException(
          'Unavailable to load price history right now. Market price tokens are limited, so try again later.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const FakeMayaException(
          'Unavailable to load price history right now.',
        );
      }
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final prices = data['prices'];
      if (prices is! List) {
        throw const FakeMayaException(
          'Unavailable to load price history right now.',
        );
      }
      return prices
          .map((point) {
            if (point is! List || point.length < 2) return null;
            final ms = (point[0] as num?)?.toInt();
            final price = (point[1] as num?)?.toDouble();
            if (ms == null || price == null || price <= 0) return null;
            return FakeMayaPricePoint(
              DateTime.fromMillisecondsSinceEpoch(ms),
              price,
            );
          })
          .whereType<FakeMayaPricePoint>()
          .toList();
    } on FakeMayaException {
      rethrow;
    } on SocketException {
      throw const FakeMayaException(
        'Unavailable to load price history. Check your connection.',
      );
    } on TimeoutException {
      throw const FakeMayaException(
        'Unavailable to load price history right now.',
      );
    } on FormatException {
      throw const FakeMayaException(
        'Unavailable to load price history right now.',
      );
    } finally {
      client.close(force: true);
    }
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

  /// Creates the named personal-goal bucket with a zero balance if it
  /// doesn't already exist on this account — used when Shellby auto-creates
  /// a FakeMaya bucket for a motivation, ahead of any actual deposit.
  /// No-op (returns the current session unchanged) if the bucket is already
  /// there, so this is safe to call repeatedly.
  static Future<FakeMayaSession> ensurePersonalGoalBucket({
    required FakeMayaLink link,
    required String personalGoalId,
  }) async {
    final session = await refreshSession(link);
    final summary = session.summary;
    if (summary.personalGoalById(personalGoalId) != null) return session;
    final updatedGoals = [
      ...summary.personalGoals,
      FakeMayaPersonalGoal.defaultForId(personalGoalId),
    ];
    final totalGoalBalance = updatedGoals.fold<double>(
      0,
      (total, goal) => total + goal.balance,
    );
    final nextSummary = summary.copyWith(
      personalGoals: updatedGoals,
      goalBalance: totalGoalBalance,
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

  static Future<FakeMayaSession> pruneZeroBalancePersonalGoals({
    required FakeMayaLink link,
    required Set<String> allowedPersonalGoalIds,
  }) async {
    final session = await refreshSession(link);
    final summary = session.summary;
    final keptGoals = summary.personalGoals
        .where((goal) =>
            allowedPersonalGoalIds.contains(goal.id) || goal.balance > 0)
        .toList();
    if (keptGoals.length == summary.personalGoals.length) return session;
    final totalGoalBalance = keptGoals.fold<double>(
      0,
      (total, goal) => total + goal.balance,
    );
    final selectedGoalId =
        keptGoals.any((goal) => goal.id == summary.selectedGoalId)
            ? summary.selectedGoalId
            : keptGoals.firstOrNull?.id ??
                FakeMayaPersonalGoal.essentialExpenseFundId;
    final nextSummary = summary.copyWith(
      selectedGoalId: selectedGoalId,
      personalGoals: keptGoals,
      goalBalance: totalGoalBalance,
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

  static Future<FakeMayaSession> withdrawFromPersonalGoal({
    required FakeMayaLink link,
    required double amount,
    String? personalGoalId,
  }) async {
    if (amount <= 0) {
      throw const FakeMayaException('Enter a valid withdrawal amount.');
    }
    final session = await refreshSession(link);
    final summary = session.summary;
    final personalGoal = summary.personalGoalById(personalGoalId) ??
        summary.personalGoalById(summary.selectedGoalId) ??
        summary.personalGoalById(FakeMayaPersonalGoal.essentialExpenseFundId);
    if (personalGoal == null) {
      throw const FakeMayaException('Personal goal was not found.');
    }
    if (amount > personalGoal.balance) {
      throw const FakeMayaException('Not enough in this FakeMaya goal.');
    }
    final nextPersonalGoals = summary.personalGoalsWithWithdrawal(
      personalGoal.id,
      amount,
    );
    final transaction = FakeMayaTransaction(
      title: 'Withdrawn from goal',
      detail: personalGoal.name,
      age: 'Just now',
      amountText: '- ${_formatPeso(amount)}',
      createdAt: DateTime.now(),
    );
    final nextSummary = summary.copyWith(
      wallet: summary.wallet + amount,
      goalBalance: nextPersonalGoals.fold<double>(
        0,
        (total, goal) => total + goal.balance,
      ),
      goalName: personalGoal.name,
      goalEmoji: personalGoal.emoji,
      goalTarget: personalGoal.target,
      selectedGoalId: personalGoal.id,
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
    // A brand-new account has no buckets yet - they're only created when
    // Shellby's goal-creation flow (or FakeMaya's own "Create a new
    // Personal Goal" sheet) actually creates one. `essentialGoal` here is
    // just a template for the legacy goalName/goalEmoji/goalTarget fields,
    // not an actual bucket.
    final essentialGoal = FakeMayaPersonalGoal.defaultForId(
      FakeMayaPersonalGoal.essentialExpenseFundId,
    );
    return FakeMayaAccountSummary(
      wallet: 1000,
      savings: 0,
      timeDeposit: 0,
      goalName: essentialGoal.name,
      goalEmoji: essentialGoal.emoji,
      goalBalance: 0,
      goalTarget: essentialGoal.target,
      selectedGoalId: essentialGoal.id,
      personalGoals: const [],
      creditLimit: 5000,
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
  const FakeMayaException(this.message, {this.sessionExpired = false});

  final String message;

  /// True when this error means the stored FakeMaya refresh token is dead
  /// (missing, expired, or already rotated away by another session) —
  /// callers should clear the link and prompt the user to relink rather
  /// than retry, since retrying with the same token will fail identically.
  final bool sessionExpired;

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
    this.investmentHoldings = const [],
    this.investmentTransactions = const [],
    required this.creditLimit,
    required this.creditUsed,
    this.creditBillingDay,
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
  final List<FakeMayaInvestmentHolding> investmentHoldings;
  final List<FakeMayaStockTransaction> investmentTransactions;
  final double creditLimit;
  final double creditUsed;
  final int? creditBillingDay;
  final List<FakeMayaTransaction> transactions;
  final DateTime? updatedAt;

  double get totalBalance => wallet + savings + timeDeposit + goalBalance;
  double get investmentHoldingsValue => investmentHoldings.fold<double>(
        0,
        (total, holding) => total + holding.value,
      );
  double get investmentHoldingsCostBasis => investmentHoldings.fold<double>(
        0,
        (total, holding) => total + holding.costBasis,
      );
  double get investmentHoldingsUnrealizedGain =>
      investmentHoldingsValue - investmentHoldingsCostBasis;
  double get investmentHoldingsUnrealizedGainPercent =>
      investmentHoldingsCostBasis <= 0
          ? 0
          : investmentHoldingsUnrealizedGain /
              investmentHoldingsCostBasis *
              100;
  double get availableCredit => math.max(0, creditLimit - creditUsed);
  DateTime? get nextCreditCycleBillDate {
    if (creditUsed <= 0) return null;
    final billingDay = (creditBillingDay ?? 15).clamp(1, 27).toInt();
    final now = DateTime.now();
    var cycleDate = DateTime(now.year, now.month, billingDay);
    final today = DateTime(now.year, now.month, now.day);
    if (cycleDate.isBefore(today)) {
      cycleDate = DateTime(now.year, now.month + 1, billingDay);
    }
    return cycleDate;
  }

  String get creditCycleBillDateLabel {
    final cycleDate = nextCreditCycleBillDate;
    return cycleDate == null ? 'No active bill' : _formatDate(cycleDate);
  }

  MoneyItem? get creditLiability {
    if (creditUsed <= 0) return null;
    final billingDay = (creditBillingDay ?? 15).clamp(1, 27).toInt();
    return MoneyItem(
      'Maya Easy Credit',
      'Synced with FakeMaya · Next cycle bill $creditCycleBillDateLabel · Every $billingDay${_ordinalSuffix(billingDay)}',
      creditUsed,
    );
  }

  FakeMayaTransaction? get creditBillTransaction {
    if (creditUsed <= 0) return null;
    final cycleDate = nextCreditCycleBillDate;
    return FakeMayaTransaction(
      id: 'fakemaya-credit-bill',
      title: 'Maya Easy Credit bill',
      detail: cycleDate == null
          ? 'Outstanding credit balance'
          : 'Next cycle bill $creditCycleBillDateLabel',
      age: cycleDate == null ? 'Pending' : 'Cycle ${_formatDate(cycleDate)}',
      amountText: '- ${_moneyText(creditUsed)}',
      createdAt: updatedAt ?? DateTime.now(),
      category: 'Liability',
      source: 'FakeMaya Credit',
      account: 'Credit',
      subcategory: 'Credit bill',
      note:
          'Outstanding balance from Maya Easy Credit. This is tracked as a liability, not a wallet cash-out.',
      excludedFromInsights: true,
    );
  }

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
    List<FakeMayaInvestmentHolding>? investmentHoldings,
    List<FakeMayaStockTransaction>? investmentTransactions,
    double? creditLimit,
    double? creditUsed,
    int? creditBillingDay,
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
      investmentHoldings: investmentHoldings ?? this.investmentHoldings,
      investmentTransactions:
          investmentTransactions ?? this.investmentTransactions,
      creditLimit: creditLimit ?? this.creditLimit,
      creditUsed: creditUsed ?? this.creditUsed,
      creditBillingDay: creditBillingDay ?? this.creditBillingDay,
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
      ...investmentHoldings.map((holding) => holding.toMoneyItem()),
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
      'investmentHoldings':
          investmentHoldings.map((holding) => holding.toMap()).toList(),
      'investmentTransactions':
          investmentTransactions.map((t) => t.toMap()).toList(),
      'creditLimit': creditLimit,
      'creditUsed': creditUsed,
      'creditBillingDay': creditBillingDay,
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
      'stockHoldings': {
        for (final holding in investmentHoldings) holding.symbol: holding.units,
      },
      // Round-tripped so a Shelby-triggered write (e.g. a bucket deposit)
      // never wipes out FakeMaya's own trade history - app_state is written
      // back wholesale, not merged field-by-field.
      'stockTransactions':
          investmentTransactions.map((t) => t.toMap()).toList(),
      'goal': (personalGoalById(selectedGoalId) ??
              personalGoalById(FakeMayaPersonalGoal.essentialExpenseFundId) ??
              _legacyPersonalGoal())
          .toMap(),
      'creditLimit': creditLimit,
      'creditUsed': creditUsed,
      'creditForm': {
        'billingDay': creditBillingDay,
      },
      'transactions':
          transactions.map((transaction) => transaction.toMap()).toList(),
    };
  }

  factory FakeMayaAccountSummary.fromMap(Map<String, dynamic> data) {
    final appState =
        Map<String, dynamic>.from(data['app_state'] as Map? ?? const {});
    final creditForm =
        Map<String, dynamic>.from(appState['creditForm'] as Map? ?? const {});
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
      investmentHoldings: _investmentHoldingsFrom(
        data['investmentHoldings'] ??
            appState['investmentHoldings'] ??
            appState['stockHoldings'],
        marketPrices: appState['marketPrices'],
        transactions: _stockTransactionsFrom(
          data['investmentTransactions'] ?? appState['stockTransactions'],
        ),
      ),
      investmentTransactions: _stockTransactionsFrom(
        data['investmentTransactions'] ?? appState['stockTransactions'],
      ),
      creditLimit: _doubleFrom(
        appState['creditLimit'] ?? data['creditLimit'] ?? data['credit_limit'],
        5000,
      ),
      creditUsed: _doubleFrom(
        appState['creditUsed'] ?? data['creditUsed'] ?? data['credit_used'],
        0,
      ),
      creditBillingDay:
          _intFrom(appState['creditBillingDay'] ?? creditForm['billingDay']),
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
    final goals = personalGoals;
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

  List<FakeMayaPersonalGoal> personalGoalsWithWithdrawal(
    String? id,
    double amount,
  ) {
    final targetId =
        (id?.trim().isNotEmpty == true ? id!.trim() : selectedGoalId);
    final goals = personalGoals;
    return [
      for (final goal in goals)
        if (goal.id == targetId)
          goal.copyWith(balance: math.max(0, goal.balance - amount))
        else
          goal,
    ];
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
    // An explicit `personalGoals` array - even an empty one - is
    // authoritative: it means this account genuinely has no buckets yet
    // (or exactly the buckets listed). Never widen it back out to the
    // full default set just because it's short.
    if (value is Iterable) {
      return value
          .map((item) => item is Map
              ? FakeMayaPersonalGoal.fromMap(Map<String, dynamic>.from(item))
              : null)
          .whereType<FakeMayaPersonalGoal>()
          .toList();
    }
    // No `personalGoals` array at all - this is a pre-migration row from
    // when FakeMaya only stored a single `goal` object. Migrate that one
    // goal into the Essential Expense Fund bucket if it has any data;
    // otherwise this account has no buckets yet.
    if (legacyGoal.isEmpty && legacyGoalBalance == null) {
      return const [];
    }
    final migrated = FakeMayaPersonalGoal.defaultForId(
      FakeMayaPersonalGoal.essentialExpenseFundId,
    );
    final goals = [
      migrated.copyWith(
        name: _stringFrom(legacyGoal['name'], migrated.name),
        emoji: _stringFrom(legacyGoal['emoji'], migrated.emoji),
        balance: _doubleFrom(legacyGoal['balance'] ?? legacyGoalBalance, 0),
        target: _doubleFrom(legacyGoal['target'], migrated.target),
      ),
    ];
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

  static List<FakeMayaInvestmentHolding> _investmentHoldingsFrom(
    Object? value, {
    Object? marketPrices,
    List<FakeMayaStockTransaction> transactions = const [],
  }) {
    final costBasisBySymbol = _costBasisBySymbol(transactions);
    List<FakeMayaInvestmentHolding> withCostBasis(
      List<FakeMayaInvestmentHolding> holdings,
    ) {
      if (costBasisBySymbol.isEmpty) return holdings;
      return holdings
          .map((holding) => holding.copyWith(
                costBasis: costBasisBySymbol[holding.symbol],
              ))
          .toList();
    }

    if (value is Map) {
      return withCostBasis(value.entries
          .map((entry) => FakeMayaInvestmentHolding.fromSymbolUnits(
                entry.key.toString(),
                _doubleFrom(entry.value, 0),
                price: _investmentPriceFromMarketPrices(
                  marketPrices,
                  entry.key.toString(),
                ),
              ))
          .whereType<FakeMayaInvestmentHolding>()
          .toList());
    }
    if (value is Iterable) {
      return withCostBasis(value
          .map((item) => item is Map
              ? FakeMayaInvestmentHolding.fromMap(
                  Map<String, dynamic>.from(item),
                )
              : null)
          .whereType<FakeMayaInvestmentHolding>()
          .toList());
    }
    return const [];
  }

  static double _investmentPriceFromMarketPrices(Object? value, String symbol) {
    if (value is! Map) return 0;
    final raw = value[symbol.trim().toUpperCase()];
    if (raw is num) return raw.toDouble();
    if (raw is Map) return _doubleFrom(raw['price'], 0);
    return 0;
  }

  static List<FakeMayaStockTransaction> _stockTransactionsFrom(Object? value) {
    if (value is! Iterable) return const [];
    return value
        .map((item) => item is Map
            ? FakeMayaStockTransaction.fromMap(Map<String, dynamic>.from(item))
            : null)
        .whereType<FakeMayaStockTransaction>()
        .toList();
  }

  /// Weighted-average cost basis (total ₱ still "in" the currently-held
  /// units) per symbol, replayed from FakeMaya's own buy/sell history.
  /// FakeMaya stores transactions newest-first (and caps the list at 20), so
  /// this is best-effort - a symbol with a longer history than that will
  /// have its earliest buys silently dropped, same as FakeMaya's own UI.
  static Map<String, double> _costBasisBySymbol(
    List<FakeMayaStockTransaction> transactions,
  ) {
    final bySymbol = <String, List<FakeMayaStockTransaction>>{};
    for (final tx in transactions) {
      bySymbol.putIfAbsent(tx.symbol, () => []).add(tx);
    }
    final result = <String, double>{};
    for (final entry in bySymbol.entries) {
      var units = 0.0;
      var cost = 0.0;
      // Chronological replay (oldest first) is required for a correct
      // running average, so reverse FakeMaya's newest-first ordering.
      for (final tx in entry.value.reversed) {
        if (tx.isBuy) {
          units += tx.shares;
          cost += tx.amount;
        } else if (units > 0) {
          final soldFraction = (tx.shares / units).clamp(0.0, 1.0);
          cost -= cost * soldFraction;
          units = math.max(0.0, units - tx.shares);
        }
      }
      result[entry.key] = math.max(0.0, cost);
    }
    return result;
  }

  static double _doubleFrom(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _intFrom(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String _stringFrom(Object? value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _formatDate(DateTime value) {
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
    final year = local.year == DateTime.now().year ? '' : ', ${local.year}';
    return '${months[local.month - 1]} ${local.day}$year';
  }

  static String _ordinalSuffix(int value) {
    final tens = value % 100;
    if (tens >= 11 && tens <= 13) return 'th';
    return switch (value % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }

  static String _moneyText(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final positionFromEnd = whole.length - i;
      buffer.write(whole[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return '₱$buffer.${parts.last}';
  }
}

class FakeMayaInvestmentHolding {
  const FakeMayaInvestmentHolding({
    required this.symbol,
    required this.name,
    required this.type,
    required this.units,
    required this.price,
    required this.unitLabel,
    this.costBasis = 0,
  });

  final String symbol;
  final String name;
  final String type;
  final double units;
  final double price;
  final String unitLabel;
  // Total ₱ still "in" the currently-held units (weighted-average cost),
  // reconstructed from FakeMaya's buy/sell history - see
  // FakeMayaAccountSummary._costBasisBySymbol. 0 when there's no trade
  // history to derive it from (e.g. a holding seeded directly rather than
  // bought through FakeMaya's Crypto page).
  final double costBasis;

  double get value => units * price;
  double get unrealizedGain => value - costBasis;
  double get unrealizedGainPercent =>
      costBasis <= 0 ? 0 : unrealizedGain / costBasis * 100;

  FakeMayaInvestmentHolding copyWith({
    double? price,
    double? units,
    double? costBasis,
  }) {
    return FakeMayaInvestmentHolding(
      symbol: symbol,
      name: name,
      type: type,
      units: units ?? this.units,
      price: price ?? this.price,
      unitLabel: unitLabel,
      costBasis: costBasis ?? this.costBasis,
    );
  }

  MoneyItem toMoneyItem() {
    final unitText = units.toStringAsFixed(type == 'stock' ? 4 : 8);
    return MoneyItem(
      '$name ($symbol)',
      'FakeMaya ${type == 'stock' ? 'stock' : 'crypto'} · $unitText $unitLabel · current ${money(price)} each · worth ${money(value)}',
      value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'type': type,
      'units': units,
      'price': price,
      'unitLabel': unitLabel,
      'value': value,
      'costBasis': costBasis,
    };
  }

  factory FakeMayaInvestmentHolding.fromMap(Map<String, dynamic> data) {
    final symbol = data['symbol']?.toString() ?? '';
    final template = _fakeMayaInvestmentTemplate(symbol);
    final parsedPrice = FakeMayaAccountSummary._doubleFrom(data['price'], 0);
    return FakeMayaInvestmentHolding(
      symbol: template.symbol,
      name: data['name']?.toString() ?? template.name,
      type: data['type']?.toString() ?? template.type,
      units: FakeMayaAccountSummary._doubleFrom(
        data['units'] ?? data['shares'] ?? data['quantity'],
        0,
      ),
      price: _isSampleInvestmentPrice(template.symbol, parsedPrice)
          ? 0
          : parsedPrice,
      unitLabel: data['unitLabel']?.toString() ?? template.unitLabel,
      costBasis: FakeMayaAccountSummary._doubleFrom(data['costBasis'], 0),
    );
  }

  static FakeMayaInvestmentHolding? fromSymbolUnits(
    String symbol,
    double units, {
    double price = 0,
  }) {
    if (units <= 0) return null;
    final template = _fakeMayaInvestmentTemplate(symbol);
    return FakeMayaInvestmentHolding(
      symbol: template.symbol,
      name: template.name,
      type: template.type,
      units: units,
      price: price,
      unitLabel: template.unitLabel,
    );
  }
}

/// A single FakeMaya Crypto-page buy/sell event (BTC/NVDA today).
/// One point in a live historical price series (see
/// [FakeMayaService.loadHistoricalInvestmentPrices]).
class FakeMayaPricePoint {
  const FakeMayaPricePoint(this.date, this.price);
  final DateTime date;
  final double price;
}

/// A live current price + 24h change (see
/// [FakeMayaService.loadLiveInvestmentQuotes]).
class FakeMayaAssetQuote {
  const FakeMayaAssetQuote(
      {required this.price, required this.changePercent24h});
  final double price;
  final double changePercent24h;
}

class FakeMayaStockTransaction {
  const FakeMayaStockTransaction({
    required this.side,
    required this.symbol,
    required this.name,
    required this.shares,
    required this.unitLabel,
    required this.type,
    required this.amount,
    this.createdAt,
  });

  final String side; // 'Bought' | 'Sold'
  final String symbol;
  final String name;
  final double shares;
  final String unitLabel;
  final String type;
  final double amount;
  final DateTime? createdAt;

  bool get isBuy =>
      side.trim().toLowerCase().startsWith('buy') ||
      side.trim().toLowerCase().startsWith('bought');

  Map<String, dynamic> toMap() {
    return {
      'side': side,
      'symbol': symbol,
      'name': name,
      'shares': shares,
      'unitLabel': unitLabel,
      'type': type,
      'amount': amount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory FakeMayaStockTransaction.fromMap(Map<String, dynamic> data) {
    return FakeMayaStockTransaction(
      side: data['side']?.toString() ?? 'Bought',
      symbol: (data['symbol']?.toString() ?? '').trim().toUpperCase(),
      name: data['name']?.toString() ?? '',
      shares: FakeMayaAccountSummary._doubleFrom(
        data['shares'] ?? data['units'],
        0,
      ),
      unitLabel: data['unitLabel']?.toString() ?? 'units',
      type: data['type']?.toString() ?? 'asset',
      amount: FakeMayaAccountSummary._doubleFrom(data['amount'], 0),
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? ''),
    );
  }
}

bool _isSampleInvestmentPrice(String symbol, double price) {
  final sample = switch (symbol.trim().toUpperCase()) {
    'BTC' => 3785577.87,
    'NVDA' => 7350.00,
    _ => 0.0,
  };
  return sample > 0 && (price - sample).abs() < .01;
}

FakeMayaInvestmentHolding _fakeMayaInvestmentTemplate(String symbol) {
  return switch (symbol.trim().toUpperCase()) {
    'BTC' => const FakeMayaInvestmentHolding(
        symbol: 'BTC',
        name: 'Bitcoin',
        type: 'crypto',
        units: 0,
        price: 0,
        unitLabel: 'coins',
      ),
    'NVDA' => const FakeMayaInvestmentHolding(
        symbol: 'NVDA',
        name: 'NVIDIA',
        type: 'stock',
        units: 0,
        price: 0,
        unitLabel: 'shares',
      ),
    final value => FakeMayaInvestmentHolding(
        symbol: value.isEmpty ? 'ASSET' : value,
        name: value.isEmpty ? 'Investment asset' : value,
        type: 'asset',
        units: 0,
        price: 0,
        unitLabel: 'units',
      ),
  };
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
  static const emergencyFundId = 'B2';
  static const investmentFundId = 'B3';
  static const personalLifestyleFundId = 'B4';

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

  /// The 4 preset buckets, one per onboarding motivation (see
  /// `fakeMayaBucketIdForMotivation`/`fakeMayaBucketNameForMotivation`).
  static List<FakeMayaPersonalGoal> defaultGoals() {
    return [
      defaultForId('B1'),
      defaultForId('B2'),
      defaultForId('B3'),
      defaultForId('B4'),
    ];
  }

  static FakeMayaPersonalGoal defaultForId(String id) {
    return switch (id) {
      'B2' => const FakeMayaPersonalGoal(
          id: 'B2',
          name: 'Emergency Fund',
          label: 'Personal Goal 2',
          emoji: '🛟',
          account: '8189 3753 6102',
          balance: 0,
          target: 25000,
          daysLeft: 180,
          rate: 8,
        ),
      'B3' => const FakeMayaPersonalGoal(
          id: 'B3',
          name: 'Investment Fund',
          label: 'Personal Goal 3',
          emoji: '📈',
          account: '8189 3753 6103',
          balance: 0,
          target: 25000,
          daysLeft: 180,
          rate: 8,
        ),
      'B4' => const FakeMayaPersonalGoal(
          id: 'B4',
          name: 'Personal Lifestyle Fund',
          label: 'Personal Goal 4',
          emoji: '✨',
          account: '8189 3753 6104',
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

/// Which FakeMaya personal-goal bucket a Shellby motivation maps to. Kept as
/// a plain switch (rather than a Map literal) so it reads as an explicit
/// 1:1 rule set next to the bucket presets above.
String? fakeMayaBucketIdForMotivation(String motivation) {
  return switch (motivation) {
    'Cash Flow & Basic Needs' => FakeMayaPersonalGoal.essentialExpenseFundId,
    'Financial Safety' => FakeMayaPersonalGoal.emergencyFundId,
    'Accumulating Wealth' => FakeMayaPersonalGoal.investmentFundId,
    'Financial Freedom' => FakeMayaPersonalGoal.personalLifestyleFundId,
    _ => null,
  };
}

String? fakeMayaBucketNameForMotivation(String motivation) {
  final id = fakeMayaBucketIdForMotivation(motivation);
  return id == null ? null : FakeMayaPersonalGoal.defaultForId(id).name;
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
        normalizedTitle == 'withdrawn from goal' ||
        normalizedTitle == 'emergency withdrawal' ||
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

  String get patternKey =>
      '${amount < 0 ? 'out' : 'in'}|$counterpartyKey|${amount.abs().toStringAsFixed(2)}';

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
