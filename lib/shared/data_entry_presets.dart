part of '../main.dart';

const occupationPresets = [
  'Software Engineer',
  'Software Developer',
  'IT Support',
  'Data Analyst',
  'Data Scientist',
  'Engineer',
  'Architect',
  'Accountant',
  'Finance Professional',
  'Banker',
  'Teacher',
  'Professor / Academic',
  'Doctor',
  'Nurse',
  'Healthcare Professional',
  'Sales',
  'Marketing',
  'Customer Service',
  'Designer',
  'Creative Professional',
  'Government Employee',
  'Business Owner',
  'Freelancer',
  'Self-employed',
  'Student',
  'Retired',
  'Other',
];

const industryPresets = [
  'Technology',
  'Finance',
  'Banking',
  'Healthcare',
  'Education',
  'Business Services',
  'Retail & E-commerce',
  'Creative & Media',
  'Government',
  'Manufacturing',
  'Construction',
  'Real Estate',
  'Hospitality',
  'Transportation & Logistics',
  'Telecommunications',
  'Professional Services',
  'Freelance / Self-employed',
  'Other',
];

const expenseCategoryPresets = [
  'Rent / Housing',
  'Utilities',
  'Groceries / Food',
  'Transport',
  'Healthcare',
  'Insurance',
  'Education',
  'Debt Payment',
  'Investment Contribution',
  'Subscriptions',
  'Entertainment',
  'Travel',
  'Family Support',
  'Transfer',
  'Other',
];
const incomeCategoryPresets = [
  'Salary',
  'Business income',
  'Refund',
  'Gift',
  'Transfer',
  'Other income'
];
const incomeFrequencyPresets = [
  'Weekly',
  'Twice a month',
  'Every 2 weeks',
  'Monthly',
  'Irregular'
];
const assetTypePresets = ['Cash', 'Savings', 'Investment', 'Property', 'Other'];
const liabilityTypePresets = ['Credit Card', 'Loan', 'Mortgage', 'Other'];

String? validateRequired(String? value, {String label = 'This field'}) =>
    value == null || value.trim().isEmpty ? '$label is required.' : null;

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
      ? null
      : email.isEmpty
          ? 'Email is required.'
          : 'Enter a valid email address.';
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Password is required.';
  return password.length < 6 ? 'Use at least 6 characters.' : null;
}

String? validatePositiveAmount(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Amount is required.';
  final amount = double.tryParse(text.replaceAll(',', ''));
  if (amount == null) return 'Enter a valid amount.';
  if (amount <= 0) return 'Enter an amount greater than zero.';
  if (amount > 100000000) return 'Amount is too high.';
  return null;
}

String? validatePercentage(String? value, {bool allowZero = true}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Percentage is required.';
  final amount = double.tryParse(text.replaceAll(',', ''));
  if (amount == null) return 'Enter a valid percentage.';
  if (amount < 0 || amount > 100 || (!allowZero && amount == 0)) {
    return allowZero
        ? 'Use a percentage from 0 to 100.'
        : 'Use a percentage from 1 to 100.';
  }
  return null;
}

String? validateIncomeFrequency(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Choose or enter a value.';
  if (incomeFrequencyPresets.any(
    (frequency) => frequency.toLowerCase() == trimmed.toLowerCase(),
  )) {
    return null;
  }
  final match = RegExp(
    r'^every\s+(\d+)\s+(days?|weeks?|months?)$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (match == null) {
    return 'Choose a listed frequency or use “Every N days/weeks/months.”';
  }
  final count = int.parse(match.group(1)!);
  final unit = match.group(2)!.toLowerCase();
  final maximum = unit.startsWith('day') ? 30 : 12;
  return count >= 1 && count <= maximum
      ? null
      : 'Use 1–30 days, 1–12 weeks, or 1–12 months.';
}

String inferExpenseCategory(String? category, String name) {
  if (expenseCategoryPresets.contains(category)) return category!;
  final value = name.toLowerCase();
  if (value.contains('rent') || value.contains('housing'))
    return 'Rent / Housing';
  if (value.contains('electric') ||
      value.contains('water') ||
      value.contains('utility') ||
      value.contains('internet')) return 'Utilities';
  if (value.contains('grocery') || value.contains('food'))
    return 'Groceries / Food';
  if (value.contains('transport') ||
      value.contains('fare') ||
      value.contains('gas') ||
      value.contains('fuel')) return 'Transport';
  if (value.contains('insurance')) return 'Insurance';
  return 'Other';
}

ExpenseLayer? suggestedExpenseLayer(String category) => switch (category) {
      'Rent / Housing' ||
      'Utilities' ||
      'Groceries / Food' ||
      'Transport' ||
      'Education' ||
      'Family Support' =>
        ExpenseLayer.basicNeeds,
      'Healthcare' || 'Insurance' => ExpenseLayer.emergencyInsurance,
      'Debt Payment' ||
      'Investment Contribution' =>
        ExpenseLayer.debtInvestments,
      'Subscriptions' ||
      'Entertainment' ||
      'Travel' =>
        ExpenseLayer.nonEssentials,
      _ => null,
    };
