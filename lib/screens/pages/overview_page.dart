import 'package:flutter/material.dart';
import 'package:monex/data/app_preferences.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/auths/login_screen.dart';
import 'package:monex/screens/pages/add_transaction_page.dart';
import 'package:monex/screens/pages/analytics_page.dart';
import 'package:monex/screens/pages/transactions_search_page.dart';
import 'package:monex/screens/pages/total_salary_page.dart';
import 'package:monex/screens/widgets/animated_money_text.dart';
import 'package:monex/screens/widgets/skeleton_box.dart';
import 'package:monex/services/insight_service.dart';
import 'package:monex/services/notification_service.dart';
import 'package:monex/services/report_service.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

import 'total_expenses_page.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  int _selectedActionIndex = 0;
  bool _showSkeleton = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 360), () {
      if (mounted) setState(() => _showSkeleton = false);
    });
  }

  Future<void> _showAccountSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: MonexColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final account = appState.currentAccount;
        final title = account == null ? 'Tài khoản khách' : account.username;
        final subtitle = account == null
            ? 'Bạn đang dùng chế độ khách'
            : account.email;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: MonexTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        title.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: MonexColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: MonexColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    appState.logout();
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Đăng xuất'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MonexColors.expense,
                    side: const BorderSide(color: MonexColors.expense),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: MonexColors.background,
          body: MonexBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _showSkeleton
                        ? _buildSkeletonDashboard()
                        : Column(
                            key: const ValueKey('overview_content'),
                            children: [
                              _buildBalanceCard(context),
                              const SizedBox(height: 18),
                              _buildSummaryCards(),
                              const SizedBox(height: 18),
                              _buildAiInsightCard(context),
                              const SizedBox(height: 22),
                              _buildActionButtons(),
                              const SizedBox(height: 18),
                              _buildExportButtons(),
                              const SizedBox(height: 18),
                              _buildDynamicContent(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonDashboard() {
    return const Column(
      key: ValueKey('overview_skeleton'),
      children: [
        SkeletonBox(height: 184),
        SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 78)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 78)),
          ],
        ),
        SizedBox(height: 18),
        SkeletonBox(height: 172),
        SizedBox(height: 18),
        SkeletonBox(height: 54),
        SizedBox(height: 18),
        SkeletonBox(height: 150),
      ],
    );
  }

  Widget _buildHeader() {
    final name = appState.displayName.trim().isEmpty
        ? 'Bạn'
        : appState.displayName.trim();
    final initial = name.substring(0, 1).toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, $name',
                style: const TextStyle(color: MonexColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tổng quan',
                style: TextStyle(
                  color: MonexColors.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _buildHeaderAction(
          icon: Icons.search,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TransactionsSearchPage(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildHeaderAction(
          icon: Icons.query_stats,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AnalyticsPage()),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildHeaderAction(
          icon: appPreferences.themeMode == ThemeMode.dark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          onTap: appPreferences.toggleTheme,
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _showAccountSheet,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MonexColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MonexColors.line),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: MonexColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: MonexColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MonexColors.line),
        ),
        child: Icon(icon, color: MonexColors.primary, size: 21),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final monthBalance = appState.currentMonthBalance;
    final monthIncome = appState.currentMonthIncomeTotal;
    final monthExpense = appState.currentMonthExpenseTotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: MonexTheme.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: MonexTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Số dư tháng này',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tháng ${DateTime.now().month}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedMoneyText(
              value: money(monthBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildBalanceMetric(
                  label: 'Thu nhập',
                  value: money(monthIncome),
                  icon: Icons.arrow_downward_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TotalSalaryPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceMetric(
                  label: 'Chi tiêu',
                  value: money(monthExpense),
                  icon: Icons.arrow_upward_rounded,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TotalExpensesPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceMetric({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: MonexColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AnimatedMoneyText(
                      value: value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.wallet_outlined,
            title: 'Tiết kiệm',
            amount: money(appState.savingsTotal),
            color: MonexColors.primary,
            onTap: () {
              setState(() {
                _selectedActionIndex = 0;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.receipt_long_outlined,
            title: 'Hóa đơn',
            amount: money(appState.billsTotal),
            color: MonexColors.accent,
            onTap: () {
              setState(() {
                _selectedActionIndex = 1;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String amount,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MonexTheme.radius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: MonexTheme.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: MonexColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amount,
                      style: const TextStyle(
                        color: MonexColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: MonexColors.muted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAiInsightCard(BuildContext context) {
    final insight = insightService.buildAssistantInsight(appState);
    final progress = insight.progress.clamp(0.0, 1.0).toDouble();
    final statusColor = _insightColor(insight.severity);
    final title = insight.title;
    final suggestion = insight.message;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MonexColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MonexColors.primary.withValues(alpha: 0.14)),
        boxShadow: MonexTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: MonexColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: MonexColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trợ lý chi tiêu',
                      style: TextStyle(
                        color: MonexColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        color: MonexColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  insight.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: MonexColors.line,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
          const SizedBox(height: 12),
          Text(
            suggestion,
            style: const TextStyle(
              color: MonexColors.ink,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final reminder = appState.addReminder(
                      title: 'Kiểm tra ngân sách',
                      amount:
                          appState.highestBudgetRisk?.spent ??
                          appState.currentMonthExpenseTotal,
                      dueDate: DateTime.now().add(const Duration(days: 1)),
                      frequency: 'Không lặp lại',
                    );
                    notificationService.scheduleReminder(reminder);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã thêm nhắc kiểm tra ngân sách'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.alarm_add_outlined, size: 18),
                  label: const FittedBox(child: Text('Nhắc lại')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MonexColors.primary,
                    side: const BorderSide(color: MonexColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openInsightAction(context, insight),
                  icon: const Icon(Icons.pie_chart_outline, size: 18),
                  label: FittedBox(child: Text(insight.primaryAction)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MonexColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openInsightAction(
    BuildContext context,
    AssistantInsight insight,
  ) async {
    final action = insight.primaryAction.toLowerCase();
    if (action.contains('thêm')) {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddTransactionPage(),
      );
      return;
    }

    if (action.contains('phân tích')) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const AnalyticsPage()));
      return;
    }
    if (action.contains('hóa đơn')) {
      setState(() => _selectedActionIndex = 1);
      return;
    }
    if (action.contains('ngân sách')) {
      setState(() => _selectedActionIndex = 2);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionsSearchPage()),
    );
  }

  Color _insightColor(InsightSeverity severity) {
    return switch (severity) {
      InsightSeverity.danger => MonexColors.expense,
      InsightSeverity.warning => MonexColors.accent,
      InsightSeverity.good => MonexColors.income,
      InsightSeverity.info => MonexColors.info,
    };
  }

  Widget _buildActionButtons() {
    final actions = [
      (Icons.savings_outlined, 'Tiết kiệm'),
      (Icons.notifications_active_outlined, 'Nhắc nhở'),
      (Icons.pie_chart_outline, 'Ngân sách'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MonexColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MonexColors.line),
      ),
      child: Row(
        children: List.generate(actions.length, (index) {
          final action = actions[index];
          final isSelected = _selectedActionIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedActionIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? MonexColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action.$1,
                      size: 18,
                      color: isSelected ? Colors.white : MonexColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        action.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : MonexColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExportButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => reportService.shareMonthlyPdf(appState),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const FittedBox(child: Text('Xuất PDF')),
            style: OutlinedButton.styleFrom(
              foregroundColor: MonexColors.primary,
              side: const BorderSide(color: MonexColors.line),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => reportService.shareMonthlyExcel(appState),
            icon: const Icon(Icons.table_chart_outlined, size: 18),
            label: const FittedBox(child: Text('Excel')),
            style: OutlinedButton.styleFrom(
              foregroundColor: MonexColors.primary,
              side: const BorderSide(color: MonexColors.line),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicContent() {
    switch (_selectedActionIndex) {
      case 0:
        final goals = appState.goals.take(4).toList();
        return _buildContentContainer(
          title: 'Mục tiêu gần đây',
          actionText: '${appState.goals.length} mục tiêu',
          itemCount: goals.length,
          emptyText: 'Chưa có mục tiêu',
          itemBuilder: (index) => _buildSavingsRow(goals[index]),
        );
      case 1:
        final reminders = [...appState.reminders]
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        return _buildContentContainer(
          title: 'Lời nhắc sắp tới',
          actionText: '${reminders.length} mục',
          itemCount: reminders.length,
          emptyText: 'Chưa có lời nhắc',
          itemBuilder: (index) => _buildReminderRow(reminders[index]),
        );
      case 2:
        final budgets = appState.budgets;
        return _buildContentContainer(
          title: 'Ngân sách',
          actionText: 'Tháng này',
          itemCount: budgets.length,
          emptyText: 'Chưa có ngân sách',
          itemBuilder: (index) => _buildBudgetRow(budgets[index]),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContentContainer({
    required String title,
    required String actionText,
    required int itemCount,
    required String emptyText,
    required Widget Function(int index) itemBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MonexTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: MonexColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                actionText,
                style: const TextStyle(
                  color: MonexColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (itemCount == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                emptyText,
                style: const TextStyle(color: MonexColors.muted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) => itemBuilder(index),
              separatorBuilder: (context, index) =>
                  const Divider(height: 24, color: MonexColors.line),
            ),
        ],
      ),
    );
  }

  Widget _buildSavingsRow(SavingsGoal goal) {
    return Row(
      children: [
        _buildIconTile(goal.icon, MonexColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRowTitle(goal.title),
              const SizedBox(height: 4),
              Text(
                'Còn ${money((goal.targetAmount - goal.currentAmount).clamp(0, goal.targetAmount).toDouble())} trước ${shortDate(goal.deadline)}',
                style: const TextStyle(color: MonexColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: goal.progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: MonexColors.line,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  MonexColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          money(goal.currentAmount),
          style: const TextStyle(
            color: MonexColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildReminderRow(ReminderEntry reminder) {
    return Row(
      children: [
        _buildIconTile(Icons.notifications_active_outlined, MonexColors.info),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRowTitle(reminder.title),
              const SizedBox(height: 4),
              Text(
                'Đến hạn ${shortDate(reminder.dueDate)} • ${reminder.frequency}',
                style: const TextStyle(color: MonexColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          money(reminder.amount),
          style: const TextStyle(
            color: MonexColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetRow(BudgetInfo budget) {
    final progress = budget.progress.clamp(0.0, 1.0).toDouble();

    return Row(
      children: [
        _buildIconTile(budget.icon, budget.color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRowTitle(budget.category),
              const SizedBox(height: 4),
              Text(
                '${money(budget.spent)} / ${money(budget.limit)}',
                style: const TextStyle(color: MonexColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                backgroundColor: MonexColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(budget.color),
              ),
              Text(
                '${(budget.progress * 100).round()}%',
                style: const TextStyle(
                  color: MonexColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconTile(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildRowTitle(String title) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: MonexColors.ink,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
