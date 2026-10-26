import 'package:cap1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a spending cap can only go up as far as the user planned', () {
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A3',
        current: 5000,
        proposed: 7000,
        plannedCap: 6000,
      ),
      isFalse,
    );
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A3',
        current: 5000,
        proposed: 6000,
        plannedCap: 6000,
      ),
      isTrue,
    );
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A28',
        current: 1000,
        proposed: 1500,
      ),
      isFalse,
      reason: 'no plan to justify a higher limit',
    );
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A3',
        current: 5000,
        proposed: 4000,
      ),
      isTrue,
      reason: 'spending less is always fine',
    );
  });

  test('a saving target can only go down when the user keeps missing it', () {
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A1',
        current: 62,
        proposed: 40,
        scorePercent: 90,
      ),
      isFalse,
    );
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A1',
        current: 62,
        proposed: 40,
      ),
      isFalse,
      reason: 'no score yet',
    );
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A19',
        current: 12000,
        proposed: 9000,
        scorePercent: 30,
      ),
      isTrue,
    );
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A8',
        current: 10,
        proposed: 15,
        scorePercent: 95,
      ),
      isTrue,
      reason: 'saving more is always fine',
    );
  });

  test('actions that are neither caps nor saving targets are left alone', () {
    expect(
      actionStageTargetChangeIsResponsible(
        actionId: 'A20',
        current: 30000,
        proposed: 20000,
      ),
      isTrue,
    );
  });
}
