import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class ChartData {
  ChartData({
    required this.category,
    required this.amount,
    required this.color,
  });

  final String category;
  final double amount;
  final Color color;
}

class TotalExpensesPage extends StatefulWidget {
  const TotalExpensesPage({super.key});

  @override
  State<TotalExpensesPage> createState() => _TotalExpensesPageState();
}

class _TotalExpensesPageState extends State<TotalExpensesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final List<Color> _chartColors = const [
    MonexColors.expense,
    MonexColors.accent,
    MonexColors.info,
    MonexColors.primary,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final budgetTotal = appState.budgets.fold(
          0.0,
          (sum, budget) => sum + budget.limit,
        );
        final percent = budgetTotal <= 0
            ? 0
            : ((appState.expenseTotal / budgetTotal) * 100).round();

        return Scaffold(
          backgroundColor: MonexColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Tổng chi phí'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildCalendar(),
                const SizedBox(height: 24),
                _buildTotalCircle(totalAmount: money(appState.expenseTotal)),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã chi tiêu tổng cộng\n$percent% ngân sách của bạn',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MonexColors.muted,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTabs(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: MonexTheme.cardDecoration(radius: 20),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.week,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: MonexColors.expense,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: MonexColors.expense.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCircle({required String totalAmount}) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MonexColors.expense.withValues(alpha: 0.1),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: MonexColors.expense,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                totalAmount,
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
    );
  }

  Widget _buildTabs() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: MonexColors.expense,
            labelColor: MonexColors.ink,
            unselectedLabelColor: MonexColors.muted,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Danh mục'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildSpendsList(), _buildCategoriesView()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendsList() {
    final expenses = [...appState.expenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có khoản chi phí',
          style: TextStyle(color: MonexColors.muted),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: expenses.length,
      itemBuilder: (context, index) => _buildTransactionRow(expenses[index]),
      separatorBuilder: (context, index) =>
          const Divider(color: MonexColors.line),
    );
  }

  Widget _buildCategoriesView() {
    final data = _groupByCategory(appState.expenses);
    final total = data.fold(0.0, (sum, item) => sum + item.amount);

    if (total <= 0) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu biểu đồ',
          style: TextStyle(color: MonexColors.muted),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 60,
                sections: _generateChartSections(data, total),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegend(data),
        ],
      ),
    );
  }

  List<ChartData> _groupByCategory(List<TransactionEntry> entries) {
    final grouped = <String, double>{};
    for (final entry in entries) {
      grouped.update(
        entry.category,
        (value) => value + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }

    var index = 0;
    return grouped.entries.map((entry) {
      final color = _chartColors[index % _chartColors.length];
      index++;
      return ChartData(category: entry.key, amount: entry.value, color: color);
    }).toList();
  }

  List<PieChartSectionData> _generateChartSections(
    List<ChartData> data,
    double total,
  ) {
    return data.map((item) {
      final percentage = (item.amount / total) * 100;
      return PieChartSectionData(
        color: item.color,
        value: item.amount,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 42,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<ChartData> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, color: item.color),
            const SizedBox(width: 8),
            Text('${item.category} (${money(item.amount)})'),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionRow(TransactionEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MonexColors.expense.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(entry.icon, color: MonexColors.expense),
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
                    fontWeight: FontWeight.w600,
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
                '- ${money(entry.amount)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: MonexColors.expense,
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
