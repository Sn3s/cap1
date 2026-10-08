part of '../main.dart';

enum MerchantCategorySuggestionSource {
  savedTransaction,
  merchantRule,
  patternRule,
  builtIn,
}

class MerchantCategorySuggestion {
  const MerchantCategorySuggestion({
    required this.category,
    required this.source,
  });

  final String category;
  final MerchantCategorySuggestionSource source;
}

const _builtInMerchantCategories = <String, String>{
  'mcdonald': 'Groceries / Food',
  'mcdonalds': 'Groceries / Food',
  'jollibee': 'Groceries / Food',
  'starbucks': 'Groceries / Food',
  'kfc': 'Groceries / Food',
  'chowking': 'Groceries / Food',
  'grab': 'Transport',
  'angkas': 'Transport',
  'joyride': 'Transport',
  'move it': 'Transport',
  'meralco': 'Utilities',
  'maynilad': 'Utilities',
  'pldt': 'Utilities',
  'globe': 'Utilities',
  'smart': 'Utilities',
  'mercury': 'Healthcare',
  'watsons': 'Healthcare',
  'netflix': 'Subscriptions',
  'spotify': 'Subscriptions',
  'disney': 'Subscriptions',
  'uniqlo': 'Shopping',
  'h m': 'Shopping',
  'zara': 'Shopping',
  'sm department store': 'Shopping',
  'sm store': 'Shopping',
};

String _merchantMatchingText(FakeMayaTransaction transaction) {
  String normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  return [
    transaction.counterpartyKey,
    normalize(transaction.title),
    normalize(transaction.detail),
  ].where((value) => value.isNotEmpty).join(' ');
}

/// Returns a deterministic built-in category. The aliases are matched as
/// whole words, which deliberately avoids treating the generic word "sm" as
/// the SM Store merchant.
String? builtInMerchantCategoryFor(FakeMayaTransaction transaction) {
  final text = _merchantMatchingText(transaction);
  for (final entry in _builtInMerchantCategories.entries) {
    final alias = RegExp.escape(entry.key);
    if (RegExp('(^| )$alias(?= |\$)').hasMatch(text)) return entry.value;
  }
  return null;
}

bool canSuggestMerchantExpenseCategory(FakeMayaTransaction transaction) {
  if (transaction.amount >= 0 || transaction.excludedFromInsights) {
    return false;
  }
  if (transaction.automaticDestination != null ||
      transaction.isFakeMayaCashIn ||
      transaction.isInternalFakeMayaTransfer ||
      transaction.isWalletCashMovement) {
    return false;
  }
  final title = transaction.title.trim().toLowerCase();
  return !title.contains('transfer') &&
      !title.contains('sent money') &&
      !title.contains('received money');
}

bool isMerchantExpenseCategory(String? category) =>
    category != null && expenseCategoryPresets.contains(category);
