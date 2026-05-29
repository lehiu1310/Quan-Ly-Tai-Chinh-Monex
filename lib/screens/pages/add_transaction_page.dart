import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/pages/add_expense_page.dart';
import 'package:monex/screens/pages/add_goal_page.dart';
import 'package:monex/screens/pages/add_income_page.dart';
import 'package:monex/screens/pages/set_reminder_page.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/widgets/category_dialogs.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  Future<void> _openEntryPage(Widget page, String message) async {
    final added = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (context) => page));
    if (!mounted || added != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _addCategory() async {
    final result = await showDialog<CategoryDraft>(
      context: context,
      useRootNavigator: true,
      builder: (context) => const CategoryDraftDialog(),
    );

    if (result == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    appState.addCategory(result.type, result.name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm danh mục "${result.name}"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: MonexColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Opacity(
                      opacity: 0,
                      child: CircleAvatar(backgroundColor: Colors.transparent),
                    ),
                    const Expanded(
                      child: Text(
                        'Thêm',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(999),
                      child: const CircleAvatar(
                        backgroundColor: MonexColors.surface,
                        child: Icon(Icons.close, color: MonexColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: _buildQuickActions(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildLatestEntries(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Thao tác nhanh',
            style: TextStyle(
              color: MonexColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.25,
          children: [
            _buildTypeCard(
              icon: Icons.account_balance_wallet_outlined,
              text: 'Thu nhập',
              color: MonexColors.income,
              onTap: () =>
                  _openEntryPage(const AddIncomePage(), 'Đã thêm thu nhập'),
            ),
            _buildTypeCard(
              icon: Icons.payments_outlined,
              text: 'Chi phí',
              color: MonexColors.expense,
              onTap: () =>
                  _openEntryPage(const AddExpensePage(), 'Đã thêm chi phí'),
            ),
            _buildTypeCard(
              icon: Icons.savings_outlined,
              text: 'Mục tiêu',
              color: MonexColors.primary,
              onTap: () =>
                  _openEntryPage(const AddGoalPage(), 'Đã thêm mục tiêu'),
            ),
            _buildTypeCard(
              icon: Icons.receipt_long_outlined,
              text: 'Hóa đơn',
              color: MonexColors.accent,
              onTap: () =>
                  _openEntryPage(const SetReminderPage(), 'Đã thêm lời nhắc'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildAddCategoryButton(),
      ],
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: MonexTheme.softShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return InkWell(
      onTap: _addCategory,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: MonexColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MonexColors.line, width: 1.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: MonexColors.muted, size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Thêm danh mục thu / chi',
                style: TextStyle(
                  color: MonexColors.muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: MonexColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestEntries() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: MonexTheme.cardDecoration(radius: 20),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Giao dịch gần đây',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.more_horiz, color: MonexColors.muted),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: appState,
              builder: (context, _) {
                final entries = appState.recentTransactions;
                if (entries.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có giao dịch',
                      style: TextStyle(color: MonexColors.muted),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionRow(entries[index]);
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(color: MonexColors.line),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(TransactionEntry entry) {
    final color = entry.isIncome ? MonexColors.income : MonexColors.expense;
    final sign = entry.isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(entry.icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${entry.category} • ${shortDate(entry.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: MonexColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign ${money(entry.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                entry.paymentMethod,
                style: const TextStyle(fontSize: 12, color: MonexColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
