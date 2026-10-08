import 'package:cap1/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _expense(String category, {bool scheduled = false}) => {
      'name': category,
      'category': category,
      'amount': 1000,
      'expenseType': ExpenseLayer.basicNeeds.name,
      'scheduled': scheduled,
      if (scheduled) 'dueDay': 15,
    };

Finder _field(String label) => find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButtonFormField<String> &&
          widget.decoration.labelText == label,
    );

List<String> _categories(WidgetTester tester) => tester
    .widget<DropdownButton<String>>(find.descendant(
      of: _field('Category'),
      matching: find.byType(DropdownButton<String>),
    ))
    .items!
    .where((item) => item.enabled)
    .map((item) => item.value!)
    .toList();

String? _selection(WidgetTester tester, String label) =>
    tester.state<FormFieldState<String>>(_field(label)).value;

PrimaryButton _saveButton(WidgetTester tester) => tester.widget<PrimaryButton>(
      find.byWidgetPredicate(
        (widget) => widget is PrimaryButton && widget.label == 'Save label',
      ),
    );

Future<AppState> _openLabelSheet(
  WidgetTester tester, {
  List<Map<String, dynamic>>? expenses,
  String? category,
  String? source,
}) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final state = AppState();
  state.onboardingExpenseLedger.addAll(expenses ??
      [
        _expense('Rent / Housing', scheduled: true),
        _expense('Utilities'),
      ]);
  state.manualTransactions.add(FakeMayaTransaction(
    id: 'grab-payment',
    title: 'Paid merchant',
    detail: 'To: Grab',
    age: 'Just now',
    amountText: '- ₱350.00',
    category: category,
    source: source,
  ));
  await tester.pumpWidget(AppScope(
    state: state,
    child: const MaterialApp(home: RecentActivityPage()),
  ));
  await tester.tap(find.text('Paid merchant'));
  await tester.pumpAndSettle();
  expect(find.text('Label transaction'), findsOneWidget);
  return state;
}

void main() {
  testWidgets('missing Grab suggestion is visible, selected, and can be saved',
      (tester) async {
    final state = await _openLabelSheet(tester);

    expect(_selection(tester, 'Financial layer'), 'Cash Flow & Basic Needs');
    expect(_categories(tester), ['Rent / Housing', 'Utilities', 'Transport']);
    expect(_selection(tester, 'Category'), 'Transport');
    expect(find.text('Transport').hitTestable(), findsOneWidget);
    await tester.tap(_field('Category'));
    await tester.pumpAndSettle();
    expect(find.text('With due date'), findsWidgets);
    expect(find.text('Without due date'), findsWidgets);
    await tester.tap(find.text('Transport').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Suggested based on the merchant name. '
          'You can change it before saving.'),
      findsOneWidget,
    );
    expect(state.manualTransactions.single.category, isNull);
    expect(_saveButton(tester).enabled, isTrue);

    await tester.ensureVisible(find.text('Save label'));
    await tester.tap(find.text('Save label'));
    await tester.pumpAndSettle();
    expect(state.manualTransactions.single.category, 'Transport');
    expect(state.manualTransactions.single.source, 'E-wallet');
  });

  testWidgets('category values are unique even across both due-date groups',
      (tester) async {
    await _openLabelSheet(tester, expenses: [
      _expense('Rent / Housing', scheduled: true),
      _expense('Transport', scheduled: true),
      _expense('Transport'),
      _expense('Transport'),
      _expense('Utilities'),
    ]);

    final categories = _categories(tester);
    expect(categories.where((value) => value == 'Transport'), hasLength(1));
    expect(categories.toSet(), hasLength(categories.length));
    expect(_selection(tester, 'Category'), 'Transport');
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrong-layer saved category is hidden and cannot be saved',
      (tester) async {
    final state = await _openLabelSheet(
      tester,
      category: 'Transport',
      source: 'Emergency Fund',
    );
    expect(_selection(tester, 'Financial layer'), 'Financial Safety');
    expect(_categories(tester), isNot(contains('Transport')));
    expect(_selection(tester, 'Category'), isNull);

    // Make the source valid so the hidden category alone blocks Save.
    tester
        .widget<DropdownButtonFormField<String>>(_field('Source'))
        .onChanged!('E-wallet');
    await tester.pumpAndSettle();
    expect(_saveButton(tester).enabled, isFalse);
    _saveButton(tester).onPressed();
    await tester.pumpAndSettle();
    expect(find.text('Label transaction'), findsOneWidget);
    expect(state.manualTransactions.single.source, 'Emergency Fund');
    expect(state.merchantCategoryRules, isEmpty);
  });

  testWidgets('changing layer clears Transport and enables a valid replacement',
      (tester) async {
    await _openLabelSheet(tester);
    await tester.tap(_field('Financial layer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Financial Safety').last);
    await tester.pumpAndSettle();

    expect(_selection(tester, 'Category'), isNull);
    expect(_categories(tester), containsAll(['Healthcare', 'Insurance']));
    expect(_categories(tester), isNot(contains('Transport')));
    expect(_saveButton(tester).enabled, isFalse);

    await tester.tap(_field('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Healthcare').last);
    await tester.pumpAndSettle();
    expect(_selection(tester, 'Category'), 'Healthcare');
    expect(_saveButton(tester).enabled, isTrue);
  });

  testWidgets('Basic Needs does not inject an incompatible saved category',
      (tester) async {
    await _openLabelSheet(tester,
        category: 'Shopping', source: 'Basic Needs Fund');
    expect(_categories(tester), ['Rent / Housing', 'Utilities']);
    expect(_selection(tester, 'Category'), isNull);
    expect(_saveButton(tester).enabled, isFalse);
  });
}
