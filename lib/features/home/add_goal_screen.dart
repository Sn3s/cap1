part of '../../main.dart';

/// Layers open for "+ Add Goal" right now — the app is only building out
/// the two foundational pyramid layers, so Accumulating Wealth and
/// Financial Freedom stay locked/unclickable for every account, including
/// the Reflection Demo account.
const _addGoalOpenLayers = {'Cash Flow & Basic Needs', 'Financial Safety'};

/// Post-onboarding "+ Add Goal" flow. Onboarding itself always restricts the
/// user to exactly 1 motivation/goal — this screen is the only place a
/// second goal can be unlocked, and only for the layer paired with the
/// user's onboarding pick (see `_addGoalUnlockMap` in home_screens.dart).
class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  // Same 4 steps as onboarding: 1 motivation, 2 Surface, 3 your goal + first
  // actions, 4 set the numbers.
  String? _chosenLayer;
  GuidedOption? _surfaceAnswer;
  bool _actionsConfirmed = false;
  final Set<String> _chosenActionIds = {};

  String get _goalId => _goalForMotivation(_chosenLayer!);

  List<String> get _pickedActionIds => [..._chosenActionIds];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    // The Reflection Demo account is a showcase account: it can freely pick
    // between the two OPEN layers (Cash Flow / Financial Safety), on
    // repeat, with no pairing restriction or "already added" block. It does
    // NOT unlock Accumulating Wealth or Financial Freedom — those stay
    // locked for everyone (see `_addGoalOpenLayers`).
    final isDemo = _insightsIsReflectionDemoAccount(state);
    final unlockedLayer = _addGoalUnlockMap[state.primaryConcern];
    final unlockedGoalId =
        unlockedLayer == null ? null : _layerCanonicalGoalId[unlockedLayer];
    final alreadyAdded = !isDemo &&
        unlockedGoalId != null &&
        _visibleGoalIds(state).contains(unlockedGoalId);
    final noneAvailable = !isDemo && unlockedLayer == null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _title),
        title: const Text(
          'Add another motivation',
          style: TextStyle(color: _title, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: noneAvailable || alreadyAdded
            ? _buildLocked(state, alreadyAdded: alreadyAdded)
            : _chosenLayer == null
                ? _buildLayerPicker(state,
                    isDemo: isDemo, unlockedLayer: unlockedLayer)
                : _surfaceAnswer == null
                    ? _buildSurface(_chosenLayer!)
                    : !_actionsConfirmed
                        ? _buildActionPicker(state)
                        : _buildNumbers(state),
      ),
    );
  }

  Widget _buildLocked(AppState state, {required bool alreadyAdded}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        ChatBubble(
          fromUser: false,
          text: alreadyAdded
              ? "You've already added your second goal! We're focused on "
                  'the two foundational layers for now — more will unlock '
                  'as we build them out.'
              : "We're currently focused on the two foundational layers of "
                  'the pyramid — Cash Flow & Basic Needs and Financial '
                  'Safety. This layer is **Coming Soon**.',
        ),
        const SizedBox(height: 18),
        for (final branch in _goalBranches) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectableOption(
              icon: branch.icon,
              title: branch.layer,
              body: branch.layerDescription,
              selected: false,
              enabled: false,
              onTap: () {},
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLayerPicker(
    AppState state, {
    required bool isDemo,
    required String? unlockedLayer,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        ChatBubble(
          fromUser: false,
          text: isDemo
              ? "Reflection Demo account — pick any layer to explore its "
                  'goal and actions.'
              : 'Which motivation do you want to add next? Right now you '
                  'can unlock the one next in line.',
        ),
        const SizedBox(height: 18),
        for (final branch in _goalBranches) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectableOption(
              icon: branch.icon,
              title: branch.layer,
              body: branch.layerDescription,
              selected: _chosenLayer == branch.layer,
              enabled: _addGoalOpenLayers.contains(branch.layer) &&
                  (isDemo || branch.layer == unlockedLayer),
              onTap: () => setState(() => _chosenLayer = branch.layer),
            ),
          ),
        ],
      ],
    );
  }

  /// Step 2: the same Surface question onboarding asks for this motivation.
  /// The answer picks the "★ Suggested for you" habit in step 3.
  Widget _buildSurface(String layer) {
    final surface = _pathwayForLayer(layer).steps.first;
    final branch = _goalBranches.firstWhere((b) => b.layer == layer);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        ChatBubble(fromUser: false, text: surface.question),
        const SizedBox(height: 18),
        for (final option in surface.options) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectableOption(
              icon: branch.icon,
              title: option.text,
              selected: false,
              onTap: () => setState(() => _surfaceAnswer = option),
            ),
          ),
        ],
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => setState(() => _chosenLayer = null),
          child: const Text('Back',
              style: TextStyle(color: _body, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  /// Step 3: the motivation sets the goal; the user picks its first actions.
  Widget _buildActionPicker(AppState state) {
    final layer = _chosenLayer!;
    final goalId = _goalId;
    final goal = _d1GoalById(goalId);
    final actionIds = _goalActionIds[goalId] ?? const <String>[];
    final suggested = _surfaceSuggestedAction[layer]?[_surfaceAnswer?.label];
    return _stepScaffold(
      onBack: () => setState(() {
        _surfaceAnswer = null;
        _chosenActionIds.clear();
      }),
      confirmLabel: 'Continue',
      canConfirm: _chosenActionIds.isNotEmpty,
      onConfirm: () => setState(() => _actionsConfirmed = true),
      children: [
        ChatBubble(
          fromUser: false,
          text: '**Your goal: ${goal.title}**\nBecause you chose $layer, '
              '${_goalTrackingLine(goalId)}\n\nWhich actions do you want to '
              'start with? Pick at least one. You can change these anytime '
              'on the Goals page.',
        ),
        const SizedBox(height: 18),
        for (final id in actionIds) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AddGoalActionTile(
              action: _d2Actions[id],
              number: _actionNumber(id),
              suggested: id == suggested,
              selected: _chosenActionIds.contains(id),
              onTap: () => setState(() {
                if (!_chosenActionIds.remove(id)) _chosenActionIds.add(id);
              }),
            ),
          ),
        ],
      ],
    );
  }

  /// Step 4: set the numbers for each action (same editor as onboarding).
  Widget _buildNumbers(AppState state) {
    final actions = _pickedActionIds
        .map((id) => _d2Actions[id])
        .whereType<D2Action>()
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const ChatBubble(
          fromUser: false,
          text: "Let's set the numbers for each action.",
        ),
        const SizedBox(height: 14),
        ActionConfigWidget(
          actions: actions,
          onConfirm: (values) => _finish(state, values),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => setState(() => _actionsConfirmed = false),
          child: const Text('Back',
              style: TextStyle(color: _body, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Future<void> _finish(
    AppState state,
    Map<String, Map<String, String>> values,
  ) async {
    final goalId = _goalId;
    await _confirmAndEnsureFakeMayaBucketForGoal(context, state, goalId);
    state.addUnlockedGoal(goalId);
    state.addActionsForGoal(_pickedActionIds);
    state.actionFieldValues.addAll(values);
    for (final id in _pickedActionIds) {
      final action = _d2Actions[id];
      if (action == null || !action.hasFields) continue;
      state.actionFieldValues
          .putIfAbsent(id, () => _initialActionFieldValues(state, action));
    }
    await state.saveProfile();
    if (mounted) Navigator.of(context).pop();
  }

  Widget _stepScaffold({
    required List<Widget> children,
    required VoidCallback onBack,
    required String confirmLabel,
    required bool canConfirm,
    required VoidCallback onConfirm,
  }) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: children,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: _surface,
            border: Border(top: BorderSide(color: _border)),
          ),
          child: Row(
            children: [
              TextButton(
                onPressed: onBack,
                child: const Text('Back',
                    style:
                        TextStyle(color: _body, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              SizedBox(
                height: 46,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _brand,
                    disabledBackgroundColor: _border,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: _body,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: canConfirm ? onConfirm : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddGoalActionTile extends StatelessWidget {
  const _AddGoalActionTile({
    required this.action,
    required this.selected,
    required this.onTap,
    this.number,
    this.suggested = false,
  });

  final D2Action? action;
  final bool selected;
  final VoidCallback onTap;
  final String? number;
  final bool suggested;

  @override
  Widget build(BuildContext context) {
    if (action == null) return const SizedBox.shrink();
    final detail = suggested ? '★ Suggested for you' : null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _bellySoft : _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _brand : _border, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number == null ? action!.text : '$number · ${action!.text}',
                    style: const TextStyle(
                      color: _title,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: TextStyle(
                        color: suggested ? _brand : _body,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? _brand : _body,
            ),
          ],
        ),
      ),
    );
  }
}
