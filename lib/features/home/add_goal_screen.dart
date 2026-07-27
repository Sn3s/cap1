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
  String? _chosenLayer;
  String? _chosenGoalId;
  final Set<String> _chosenActionIds = {};

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
          'Add a Goal',
          style: TextStyle(color: _title, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: noneAvailable || alreadyAdded
            ? _buildLocked(state, alreadyAdded: alreadyAdded)
            : _chosenLayer == null
                ? _buildLayerPicker(state,
                    isDemo: isDemo, unlockedLayer: unlockedLayer)
                : _chosenGoalId == null
                    ? _buildGoalPicker(state, _chosenLayer!)
                    : _buildActionPicker(state, _chosenGoalId!),
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
              : "Ready for a new goal? Here's the full pyramid — right "
                  'now you can unlock the layer next in line.',
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

  /// Step 2, mirroring onboarding's own goal picker (`_editGoal` /
  /// `_goalFocusOptions` in preparation_screens.dart): show the real goals
  /// under the chosen layer and let the user pick exactly one, before
  /// moving on to that goal's recommended actions.
  Widget _buildGoalPicker(AppState state, String layer) {
    final branch = _goalBranches.firstWhere((b) => b.layer == layer);
    final goalIds = _motivationGoalIds[layer] ?? const <String>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        ChatBubble(
          fromUser: false,
          text: '**$layer** — which goal fits best?',
        ),
        const SizedBox(height: 18),
        for (final id in goalIds) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectableOption(
              icon: branch.icon,
              title: _d1GoalById(id).title,
              body: _d1GoalById(id).description,
              selected: false,
              onTap: () => setState(() => _chosenGoalId = id),
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

  Widget _buildActionPicker(AppState state, String goalId) {
    final goal = _d1GoalById(goalId);
    final actionIds = _goalActionIds[goalId] ?? const <String>[];
    final canConfirm = _chosenActionIds.isNotEmpty;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              ChatBubble(
                fromUser: false,
                text: '**${goal.title}**\n${goal.description}\n\nPick the '
                    "actions you'd like to track for this goal.",
              ),
              const SizedBox(height: 18),
              for (final id in actionIds) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AddGoalActionTile(
                    action: _d2Actions[id],
                    selected: _chosenActionIds.contains(id),
                    onTap: () => setState(() {
                      if (_chosenActionIds.contains(id)) {
                        _chosenActionIds.remove(id);
                      } else {
                        _chosenActionIds.add(id);
                      }
                    }),
                  ),
                ),
              ],
            ],
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
                onPressed: () => setState(() {
                  _chosenGoalId = null;
                  _chosenActionIds.clear();
                }),
                child: const Text('Back',
                    style: TextStyle(color: _body, fontWeight: FontWeight.w800)),
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
                  onPressed: canConfirm
                      ? () async {
                          final layer = _chosenLayer!;
                          final canonicalId = _layerCanonicalGoalId[layer]!;
                          await _confirmAndEnsureFakeMayaBucketForGoal(
                            context,
                            state,
                            _chosenGoalId ?? canonicalId,
                          );
                          state.addUnlockedGoal(canonicalId);
                          state.addActionsForGoal(_chosenActionIds);
                          await state.saveProfile();
                          if (mounted) Navigator.of(context).pop();
                        }
                      : null,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Add goal',
                      style: TextStyle(fontWeight: FontWeight.w900)),
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
  });

  final D2Action? action;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (action == null) return const SizedBox.shrink();
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
              child: Text(
                action!.text,
                style: const TextStyle(
                  color: _title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
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
