import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/pages/add_goal_page.dart';
import 'package:monex/screens/pages/your_goals_page.dart';
import 'package:monex/screens/widgets/savings_goal_action_sheet.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

class SavingsPage extends StatelessWidget {
  const SavingsPage({super.key});

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

  Future<void> _openGoalActions(BuildContext context, SavingsGoal goal) async {
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MonexColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SavingsGoalActionSheet(goal: goal),
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
        return Scaffold(
          backgroundColor: MonexColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Tiết kiệm'),
            actions: [
              IconButton(
                onPressed: () => _openAddGoal(context),
                icon: const Icon(Icons.add, color: MonexColors.ink, size: 28),
              ),
            ],
          ),
          body: MonexBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
              children: [
                _buildCurrentSavings(),
                const SizedBox(height: 24),
                _buildMonthlyGoalCard(),
                const SizedBox(height: 24),
                _buildYourGoalsCard(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentSavings() {
    return Column(
      children: [
        const Text(
          'Tiết kiệm hiện tại',
          style: TextStyle(color: MonexColors.muted, fontSize: 16),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MonexColors.primary.withValues(alpha: 0.1),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: MonexTheme.primaryGradient,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Text(
                    money(appState.savingsTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyGoalCard() {
    final suggested = (appState.incomeTotal * 0.1).clamp(0.0, 999999.0);
    final comfortable = (appState.balance * 0.2).clamp(0.0, 999999.0);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: MonexTheme.cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: MonexColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tháng ${DateTime.now().month} năm ${DateTime.now().year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Gợi ý tiết kiệm cho tháng này',
            style: TextStyle(color: MonexColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: MonexColors.line,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildAmountPill(money(suggested), true)),
                Expanded(child: _buildAmountPill(money(comfortable), false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPill(String amount, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? MonexColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          amount,
          style: TextStyle(
            color: selected ? Colors.white : MonexColors.muted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildYourGoalsCard(BuildContext context) {
    final goals = appState.goals.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: MonexTheme.cardDecoration(radius: 20),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mục tiêu của bạn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const YourGoalsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (goals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Chưa có mục tiêu nào',
                style: TextStyle(color: MonexColors.muted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              itemBuilder: (context, index) =>
                  _buildGoalRow(context, goals[index]),
              separatorBuilder: (context, index) =>
                  const Divider(height: 32, color: MonexColors.line),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalRow(BuildContext context, SavingsGoal goal) {
    return InkWell(
      onTap: () => _openGoalActions(context, goal),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MonexColors.background,
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
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: MonexColors.line,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    MonexColors.primary,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 4),
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
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Nạp hoặc rút tiền',
            onPressed: () => _openGoalActions(context, goal),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: MonexColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
