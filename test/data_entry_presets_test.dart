import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shared data-entry presets', () {
    test('includes searchable work presets and preserves an Other choice', () {
      expect(occupationPresets, contains('Software Engineer'));
      expect(occupationPresets, contains('Freelancer'));
      expect(occupationPresets, contains('Other'));
      expect(industryPresets, contains('Technology'));
      expect(industryPresets, contains('Other'));
    });

    test('includes canonical income frequencies', () {
      expect(
        incomeFrequencyPresets,
        containsAll(<String>[
          'Weekly',
          'Twice a month',
          'Every 2 weeks',
          'Monthly',
          'Irregular',
        ]),
      );
      for (final frequency in incomeFrequencyPresets) {
        expect(validateIncomeFrequency(frequency), isNull);
      }
      expect(validateIncomeFrequency('Every 3 weeks'), isNull);
      expect(validateIncomeFrequency('Every 0 weeks'), isNotNull);
    });

    test('infers categories for legacy expense rows', () {
      expect(inferExpenseCategory(null, 'Rent share'), 'Rent / Housing');
      expect(inferExpenseCategory(null, 'Water utility'), 'Utilities');
      expect(inferExpenseCategory(null, 'Mystery purchase'), 'Other');
      expect(
        inferExpenseCategory('Insurance', 'Old saved label'),
        'Insurance',
      );
    });

    test('keeps expense display labels separate from categories', () {
      expect(
        expenseDisplayName(name: '', category: 'Utilities'),
        'Utilities',
      );
      expect(
        expenseDisplayName(name: 'Meralco', category: 'Utilities'),
        'Meralco',
      );
      expect(inferExpenseCategory('Utilities', 'Meralco'), 'Utilities');
      expect(inferExpenseCategory(null, 'Rent share'), 'Rent / Housing');
      expect(
          expenseDisplayName(name: 'Rent share', category: null), 'Rent share');
    });

    test('separates monthly expense categories from transfers', () {
      expect(expenseCategoryPresets, isNot(contains('Transfer')));
      expect(transactionExpenseCategoryPresets, contains('Transfer'));
    });

    test('suggests a default layer without making it mandatory', () {
      expect(
        suggestedExpenseLayer('Rent / Housing'),
        ExpenseLayer.basicNeeds,
      );
      expect(
        suggestedExpenseLayer('Insurance'),
        ExpenseLayer.emergencyInsurance,
      );
      expect(
        suggestedExpenseLayer('Debt Payment'),
        ExpenseLayer.debtInvestments,
      );
      expect(
        suggestedExpenseLayer('Entertainment'),
        ExpenseLayer.nonEssentials,
      );
      expect(suggestedExpenseLayer('Other'), isNull);
      expect(
        expenseCategoriesForLayer(ExpenseLayer.basicNeeds),
        containsAll(<String>['Education', 'Family Support']),
      );
    });

    test('requires a selected category for a new expense', () {
      expect(
        isExpenseEntryComplete(
          category: null,
          name: '',
          amount: 1200,
          layer: ExpenseLayer.basicNeeds,
          scheduled: false,
          scheduleAnchorDate: null,
        ),
        isFalse,
      );
      expect(
        isExpenseEntryComplete(
          category: 'Utilities',
          name: '',
          amount: 1200,
          layer: ExpenseLayer.basicNeeds,
          scheduled: false,
          scheduleAnchorDate: null,
        ),
        isTrue,
      );
      expect(
        isExpenseEntryComplete(
          category: 'Other',
          name: '',
          amount: 1200,
          layer: ExpenseLayer.basicNeeds,
          scheduled: false,
          scheduleAnchorDate: null,
        ),
        isFalse,
      );
      expect(
        isExpenseEntryComplete(
          category: 'Other',
          name: 'Custom expense',
          amount: 1200,
          layer: ExpenseLayer.basicNeeds,
          scheduled: false,
          scheduleAnchorDate: null,
        ),
        isTrue,
      );
    });
  });

  group('shared validators', () {
    test('validates positive amounts', () {
      expect(validatePositiveAmount(null), isNotNull);
      expect(validatePositiveAmount('0'), isNotNull);
      expect(validatePositiveAmount('-1'), isNotNull);
      expect(validatePositiveAmount('not money'), isNotNull);
      expect(validatePositiveAmount('1,250.50'), isNull);
    });

    test('validates percentages', () {
      expect(validatePercentage('-1'), isNotNull);
      expect(validatePercentage('101'), isNotNull);
      expect(validatePercentage('none'), isNotNull);
      expect(validatePercentage('0'), isNull);
      expect(validatePercentage('0', allowZero: false), isNotNull);
      expect(validatePercentage('75.5'), isNull);
    });

    test('validates email and password before authentication', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('abc'), isNotNull);
      expect(validateEmail('abc@'), isNotNull);
      expect(validateEmail('user@example.com'), isNull);
      expect(validatePassword(''), isNotNull);
      expect(validatePassword('12345'), isNotNull);
      expect(validatePassword('123456'), isNull);
    });

    test('AppState rejects malformed credentials before Firebase is called',
        () async {
      for (final email in ['', 'abc', 'abc@']) {
        await expectLater(
          AppState().stageEmailAccount(email: email, password: '123456'),
          throwsA(isA<Exception>()),
        );
      }
      await expectLater(
        AppState().stageEmailAccount(email: 'user@example.com', password: ''),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        AppState().stageEmailAccount(
          email: 'user@example.com',
          password: '12345',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
