import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bill reservations warn about overlaps without locking the wallet',
      () async {
    final state = AppState()..manualAccountBalances['Wallet'] = 1000;

    final first = await state.recordBasicNeedsBillPlan(
      sourceExpenseKey: 'power-april',
      name: 'Power',
      expectedAmount: 600,
      fromEssentialFund: 0,
      fromWallet: 600,
      fromSavings: 0,
      dueDate: DateTime(2026, 4, 10),
    );

    expect(first, isNotNull);
    expect(first!['paidAmount'], 0);
    expect(state.billReservedAmount(first), 600);
    expect(state.unallocatedFakeMayaWallet, 1000);
    expect(state.openBasicNeedsBillObligations, contains(first));

    final second = await state.recordBasicNeedsBillPlan(
      sourceExpenseKey: 'water-april',
      name: 'Water',
      expectedAmount: 600,
      fromEssentialFund: 0,
      fromWallet: 600,
      fromSavings: 0,
      dueDate: DateTime(2026, 4, 12),
    );

    expect(second, isNotNull);
    expect(state.billReservedFromWallet(second!), 600);
    expect(state.reservedWalletForBills(), 1200);
    expect(state.totalBillReservationOverbooking, 200);
    expect(state.unallocatedFakeMayaWallet, 1000);
  });

  test('releasing a bill reservation makes its source spendable again',
      () async {
    final state = AppState()..manualAccountBalances['Wallet'] = 1000;
    final plan = await state.recordBasicNeedsBillPlan(
      sourceExpenseKey: 'internet-april',
      name: 'Internet',
      expectedAmount: 350,
      fromEssentialFund: 0,
      fromWallet: 350,
      fromSavings: 0,
      dueDate: DateTime(2026, 4, 15),
    );

    await state.releaseBasicNeedsBillReservation(plan!['id'].toString());

    final released = state.billObligations.single;
    expect(state.billReservedAmount(released), 0);
    expect(released['reservationStatus'], 'released');
    expect(state.unallocatedFakeMayaWallet, 1000);
  });
}
