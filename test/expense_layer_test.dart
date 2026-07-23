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
}
