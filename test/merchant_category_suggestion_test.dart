import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

FakeMayaTransaction _expense({
  String id = 'expense',
  String title = 'Paid merchant',
  String detail = 'To: McDonalds',
  String amount = '- ₱250.00',
  String? category,
  String? source,
  bool excluded = false,
}) =>
    FakeMayaTransaction(
      id: id,
      title: title,
      detail: detail,
      age: 'Just now',
      amountText: amount,
      category: category,
      source: source,
      excludedFromInsights: excluded,
    );

void main() {
  test('merchant key ignores the purchase amount but keeps direction', () {
    final small = _expense(amount: '- ₱120.00');
    final large = _expense(amount: '- ₱1200.00');
    const incoming = FakeMayaTransaction(
      title: 'Cash in',
      detail: 'From: McDonalds',
      age: 'Just now',
      amountText: '+ ₱120.00',
    );

    expect(small.merchantCategoryKey, large.merchantCategoryKey);
    expect(small.patternKey, isNot(large.patternKey));
    expect(small.merchantCategoryKey, isNot(incoming.merchantCategoryKey));
  });

  test('uses the deterministic merchant mappings and never maps generic SM',
      () {
    final expected = <String, String>{
      'McDonalds': 'Groceries / Food',
      'Jollibee': 'Groceries / Food',
      'Starbucks': 'Groceries / Food',
      'KFC': 'Groceries / Food',
      'Chowking': 'Groceries / Food',
      'Grab': 'Transport',
      'Angkas': 'Transport',
      'JoyRide': 'Transport',
      'Move It': 'Transport',
      'Meralco': 'Utilities',
      'Maynilad': 'Utilities',
      'PLDT': 'Utilities',
      'Globe': 'Utilities',
      'Smart': 'Utilities',
      'Mercury Drug': 'Healthcare',
      'Watsons': 'Healthcare',
      'Netflix': 'Subscriptions',
      'Spotify': 'Subscriptions',
      'Disney Plus': 'Subscriptions',
      'Uniqlo': 'Shopping',
      'H&M': 'Shopping',
      'Zara': 'Shopping',
      'SM Department Store': 'Shopping',
      'SM Store': 'Shopping',
    };

    for (final entry in expected.entries) {
      expect(
        builtInMerchantCategoryFor(_expense(detail: 'To: ${entry.key}')),
        entry.value,
        reason: entry.key,
      );
    }
    expect(
        builtInMerchantCategoryFor(_expense(detail: 'To: SM Cinema')), isNull);
  });

  test('the latest user correction overrides built-in and earlier categories',
      () async {
    final state = AppState();
    final original = _expense(id: 'first');
    state.manualTransactions.add(original);

    await state.labelFakeMayaTransaction(
      transactionId: original.transactionId,
      category: 'Shopping',
      source: 'E-wallet',
    );
    expect(
      state
          .merchantCategorySuggestionFor(
            _expense(id: 'next', amount: '- ₱700.00'),
          )
          ?.category,
      'Shopping',
    );

    final correction = _expense(id: 'second', amount: '- ₱700.00');
    state.manualTransactions.add(correction);
    await state.labelFakeMayaTransaction(
      transactionId: correction.transactionId,
      category: 'Groceries / Food',
      source: 'E-wallet',
    );
    final suggestion = state.merchantCategorySuggestionFor(
      _expense(id: 'third', amount: '- ₱150.00'),
    );
    expect(suggestion?.category, 'Groceries / Food');
    expect(suggestion?.source, MerchantCategorySuggestionSource.merchantRule);
  });

  test('uses old exact-pattern rules after merchant rules and before built-ins',
      () {
    final state = AppState();
    final transaction = _expense(amount: '- ₱480.00');
    state.transactionLabelRules[transaction.patternKey] =
        const TransactionLabelRule(
      category: 'Shopping',
      source: 'E-wallet',
    );

    final suggestion = state.merchantCategorySuggestionFor(transaction);
    expect(suggestion?.category, 'Shopping');
    expect(suggestion?.source, MerchantCategorySuggestionSource.patternRule);
  });

  test('an explicit saved category wins over every suggestion', () {
    final state = AppState()
      ..merchantCategoryRules['out|mcdonalds'] = 'Shopping';
    final transaction = _expense(
      category: 'Groceries / Food',
      source: 'E-wallet',
    );

    final suggestion = state.merchantCategorySuggestionFor(transaction);
    expect(suggestion?.category, 'Groceries / Food');
    expect(
        suggestion?.source, MerchantCategorySuggestionSource.savedTransaction);
  });

  test('does not suggest or learn from transfers, cash movement, or exclusions',
      () async {
    final state = AppState();
    final excluded = _expense(id: 'excluded', excluded: true);
    final cashOut = _expense(id: 'cash-out', title: 'Cash out');
    final transfer = _expense(id: 'transfer', title: 'Transferred to');

    expect(state.merchantCategorySuggestionFor(excluded), isNull);
    expect(state.merchantCategorySuggestionFor(cashOut), isNull);
    expect(state.merchantCategorySuggestionFor(transfer), isNull);

    state.manualTransactions.add(excluded);
    await state.labelFakeMayaTransaction(
      transactionId: excluded.transactionId,
      category: 'Shopping',
      source: 'E-wallet',
      excludedFromInsights: true,
    );
    expect(state.merchantCategoryRules, isEmpty);
  });

  test('rules persist, old profiles stay valid, and labeled history backfills',
      () {
    final state = AppState();
    state.loadMerchantCategoryRules({
      'out|mcdonalds': 'Shopping',
      'out|bad': 'Not a category',
    });
    expect(state.exportMerchantCategoryRules(), {'out|mcdonalds': 'Shopping'});

    final restored = AppState()
      ..loadMerchantCategoryRules(
        Map<String, dynamic>.from(state.exportMerchantCategoryRules()),
      );
    expect(restored.merchantCategoryRules['out|mcdonalds'], 'Shopping');
    restored.loadMerchantCategoryRules(null);
    expect(restored.merchantCategoryRules, isEmpty);

    restored.seedMerchantCategoryRules([
      _expense(category: 'Shopping', source: 'E-wallet'),
    ]);
    expect(restored.merchantCategoryRules['out|mcdonalds'], 'Shopping');
  });

  test('Shopping belongs to the non-essential expense layer', () {
    expect(suggestedExpenseLayer('Shopping'), ExpenseLayer.nonEssentials);
    expect(
      expenseCategoriesForLayer(ExpenseLayer.nonEssentials),
      contains('Shopping'),
    );
  });
}
