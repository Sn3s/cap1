import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('integration indices move in expected directions', () {
    final weeks = List.generate(8, (index) {
      final hardWeek = index == 5;
      return WeekRecord(
        start: DateTime(2026, 1, 1).add(Duration(days: index * 7)),
        end: DateTime(2026, 1, 7).add(Duration(days: index * 7)),
        days: const [],
        weekIncome: 5000,
        weekExpense: hardWeek ? 7200 : 2800,
        weekRefill: [900, 850, 920, 880, 900, 2500, 300, 900][index].toDouble(),
        avgSpendPerDay: hardWeek ? 1028 : 400,
        propDaysClassified: 1,
        needsBalanceEnd: hardWeek ? 3500 : 9000,
        bufferBalanceEnd: hardWeek ? 700 : 3000,
        isSalaryWeek: index.isEven,
        isBillWeek: hardWeek,
        hadEmergency: hardWeek,
      );
    });

    final integrity = jarIntegrity(weeks, 9000, 3000);
    expect(integrity.first, greaterThan(integrity[5]));

    final resilience = bufferResilience(weeks, 9000, 3000);
    expect(resilience[5], greaterThan(integrity[5]));
    expect(resilience.first, integrity.first);

    final steadyWeeks = List.generate(
      8,
      (index) => WeekRecord(
        start: weeks[index].start,
        end: weeks[index].end,
        days: const [],
        weekIncome: weeks[index].weekIncome,
        weekExpense: weeks[index].weekExpense,
        weekRefill: 900,
        avgSpendPerDay: weeks[index].avgSpendPerDay,
        propDaysClassified: 1,
        needsBalanceEnd: weeks[index].needsBalanceEnd,
        bufferBalanceEnd: weeks[index].bufferBalanceEnd,
        isSalaryWeek: weeks[index].isSalaryWeek,
        isBillWeek: weeks[index].isBillWeek,
        hadEmergency: weeks[index].hadEmergency,
      ),
    );
    expect(refillConsistency(weeks).last,
        greaterThan(refillConsistency(steadyWeeks).last));
  });
}
