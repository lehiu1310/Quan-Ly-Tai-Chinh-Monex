import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/pages/add_goal_page.dart';
import 'package:monex/screens/widgets/savings_goal_action_sheet.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

class YourGoalsPage extends StatelessWidget {
  const YourGoalsPage({super.key});

  Future<void> _openAddGoal(BuildContext context) async {
    final added = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (context) => const AddGoalPage()));
    if (added != true || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm mục tiêu'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openGoalActions(
    BuildContext context,
    SavingsGoal goal, {
    SavingsGoalActionMode mode = SavingsGoalActionMode.deposit,
  }) async {
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MonexColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) =>
          SavingsGoalActionSheet(goal: goal, initialMode: mode),
    );
    if (message == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final goals = appState.goals;

        return Scaffold(
          backgroundColor: MonexColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Mục tiêu của bạn'),
            actions: [
              IconButton(
                onPressed: () => _openAddGoal(context),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: MonexBackground(
            child: goals.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có mục tiêu nào',
                      style: TextStyle(color: MonexColors.muted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: goals.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Text(
                          'Tất cả mục tiêu (${goals.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: MonexColors.ink,
                          ),
                        );
                      }
                      return _buildGoalRow(context, goals[index - 1]);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGoalRow(BuildContext context, SavingsGoal goal) {
    return InkWell(
      onTap: () => _openGoalActions(context, goal),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: MonexTheme.cardDecoration(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MonexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(goal.icon, color: MonexColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${goal.frequency} • Hạn ${shortDate(goal.deadline)}',
                    style: const TextStyle(
                      color: MonexColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: MonexColors.line,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      MonexColors.primary,
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        money(goal.currentAmount),
                        style: const TextStyle(
                          color: MonexColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        money(goal.targetAmount),
                        style: const TextStyle(
                          color: MonexColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openGoalActions(context, goal),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Nạp'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openGoalActions(
                            context,
                            goal,
                            mode: SavingsGoalActionMode.withdraw,
                          ),
                          icon: const Icon(Icons.remove_rounded, size: 18),
                          label: const Text('Rút'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
