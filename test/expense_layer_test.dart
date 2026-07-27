import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expense types survive serialization', () {
    for (final layer in ExpenseLayer.values) {
      final expense = CashFlowExpense('Example', 1200, layer: layer);

      final restored = CashFlowExpense.fromMap(expense.toMap());

      expect(restored.name, 'Example');
      expect(restored.budget, 1200);
      expect(restored.layer, layer);
    }
  });

  test('legacy expenses default to Basic Needs', () {
    final restored = CashFlowExpense.fromMap({
      'name': 'Rent',
      'budget': 5000,
    });

    expect(restored.layer, ExpenseLayer.basicNeeds);
  });

  test('onboarding ledger reads new types and legacy essential flags', () {
    expect(
      expenseLayerForLedger({
        'expenseType': ExpenseLayer.debtInvestments.name,
        'essential': false,
      }),
      ExpenseLayer.debtInvestments,
    );
    expect(
      expenseLayerForLedger({'essential': true}),
      ExpenseLayer.basicNeeds,
    );
    expect(
      expenseLayerForLedger({'essential': false}),
      ExpenseLayer.nonEssentials,
    );
  });

  test('expense budgets can be totaled by layer', () {
    final state = AppState()
      ..cashFlowExpenses.addAll([
        CashFlowExpense('Rent', 5000),
        CashFlowExpense(
          'Health insurance',
          1500,
          layer: ExpenseLayer.emergencyInsurance,
        ),
        CashFlowExpense(
          'Streaming',
          500,
          layer: ExpenseLayer.nonEssentials,
        ),
      ]);

    expect(state.totalCashFlowBudget, 7000);
    expect(state.cashFlowPyramidBaseline, 5000);
    expect(
      state.cashFlowBudgetForLayer(ExpenseLayer.emergencyInsurance),
      1500,
    );
  });

  test('missing onboarding ledgers backfill from legacy profile fields', () {
    final state = AppState()
      ..income = 30000
      ..monthlySalary = 20000
      ..irregularIncomeFloor = 10000
      ..cashFlowExpenses.addAll([
        CashFlowExpense('Rent', 5000),
        CashFlowExpense(
          'Insurance',
          1500,
          layer: ExpenseLayer.emergencyInsurance,
        ),
      ]);

    expect(state.backfillMissingOnboardingLedgers(), isTrue);

    expect(state.onboardingIncomeLedger, hasLength(2));
    expect(state.onboardingExpenseLedger, hasLength(2));
    expect(state.onboardingBaselines['income_baseline'], '30000.00');
    expect(state.onboardingBaselines['monthly_expenses'], '6500.00');
    expect(
      state.onboardingExpenseLedger.map(expenseLayerForLedger),
      containsAll([ExpenseLayer.basicNeeds, ExpenseLayer.emergencyInsurance]),
    );
  });

  test('saved preset accounts get onboarding ledger fallbacks when blank', () {
    final state = AppState()..email = 'cashflow@gmail.com';

    expect(state.backfillMissingOnboardingLedgers(), isTrue);

    expect(state.onboardingIncomeLedger.single['name'], 'Project client work');
    expect(state.income, 32000);
    expect(state.onboardingExpenseLedger, hasLength(9));
    expect(state.monthlyExpenseLedgerTotal, 15198);
    expect(
      state.onboardingExpenseLedger.map(expenseLayerForLedger).toSet(),
      ExpenseLayer.values.toSet(),
    );
  });

  test('fresh onboarding draft clears previous selections', () async {
    final state = AppState()
      ..name = 'Old Name'
      ..email = 'old@example.com'
      ..age = 'Early Career'
      ..employmentStatus = 'Full-time'
      ..primaryConcern = 'Financial Safety'
      ..selectedGoalId = 'G3'
      ..selectedGoal = 'Emergency Fund'
      ..selectedActionIds.add('A9')
      ..actionFieldValues['A9'] = {'amt': '5000'}
      ..onboardingBaselines['income_baseline'] = '30000'
      ..onboardingIncomeLedger.add({'name': 'Old income', 'amount': 30000})
      ..onboardingExpenseLedger.add({'name': 'Old rent', 'amount': 8000})
      ..personalDataConsent = true
      ..dataRetentionConsent = true;

    await state.beginFreshOnboardingDraft();

    expect(state.name, isEmpty);
    expect(state.email, isEmpty);
    expect(state.age, isEmpty);
    expect(state.employmentStatus, isEmpty);
    expect(state.primaryConcern, isEmpty);
    expect(state.selectedGoalId, isEmpty);
    expect(state.selectedGoal, isEmpty);
    expect(state.selectedActionIds, isEmpty);
    expect(state.actionFieldValues, isEmpty);
    expect(state.onboardingBaselines, isEmpty);
    expect(state.onboardingIncomeLedger, isEmpty);
    expect(state.onboardingExpenseLedger, isEmpty);
    expect(state.personalDataConsent, isFalse);
    expect(state.dataRetentionConsent, isFalse);
  });

  test('onboarding ledger backfill does not overwrite existing rows', () {
    final state = AppState()
      ..email = 'cashflow@gmail.com'
      ..onboardingIncomeLedger.add({
        'name': 'Existing income',
        'amount': 12000.0,
        'stable': true,
        'scheduled': true,
        'payDay': 15,
      })
      ..onboardingExpenseLedger.add({
        'name': 'Existing expense',
        'amount': 4000.0,
        'essential': true,
        'expenseType': ExpenseLayer.basicNeeds.name,
        'scheduled': false,
        'dueDay': null,
      });

    expect(state.backfillMissingOnboardingLedgers(), isFalse);

    expect(state.onboardingIncomeLedger.single['name'], 'Existing income');
    expect(state.onboardingExpenseLedger.single['name'], 'Existing expense');
  });

  test('saved automatic A19 floors migrate to feasible onboarding amount', () {
    final state = AppState()
      ..email = 'cashflow@gmail.com'
      ..selectedActionIds.add('A19');
    state.actionFieldValues['A19'] = {'amt': '12000'};

    state.backfillMissingOnboardingLedgers();

    expect(state.backfillFeasibleActionDefaults(), isTrue);
    expect(state.actionFieldValues['A19']?['amt'], '8500');
  });

  test('custom A19 floors are preserved', () {
    final state = AppState()
      ..email = 'cashflow@gmail.com'
      ..selectedActionIds.add('A19');
    state.actionFieldValues['A19'] = {'amt': '5555'};

    state.backfillMissingOnboardingLedgers();

    expect(state.backfillFeasibleActionDefaults(), isFalse);
    expect(state.actionFieldValues['A19']?['amt'], '5555');
  });
}
