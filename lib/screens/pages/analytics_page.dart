import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

enum _AnalyticsPeriod { month, year }

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  _AnalyticsPeriod _period = _AnalyticsPeriod.month;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedYear = DateTime(DateTime.now().year);

  @override
  Widget build(BuildContext context) {
    final report = _period == _AnalyticsPeriod.month
        ? _monthReport(_selectedMonth)
        : _yearReport(_selectedYear.year);
    final previous = _period == _AnalyticsPeriod.month
        ? _monthReport(DateTime(_selectedMonth.year, _selectedMonth.month - 1))
        : _yearReport(_selectedYear.year - 1);
    final buckets = _period == _AnalyticsPeriod.month
        ? _dailyBuckets(_selectedMonth)
        : _monthlyBuckets(_selectedYear.year);
    final trend = _buildTrendMonths();

    return Scaffold(
      backgroundColor: MonexColors.background,
      appBar: AppBar(
        title: const Text('Thống kê'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MonexBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            _buildPeriodControls(),
            const SizedBox(height: 16),
            _buildSummary(report, previous),
            const SizedBox(height: 18),
            _buildCard(
              title: _period == _AnalyticsPeriod.month
                  ? 'Thu / chi theo ngày'
                  : 'Thu / chi theo tháng',
              subtitle: report.label,
              child: SizedBox(height: 250, child: _buildBarChart(buckets)),
            ),
            const SizedBox(height: 18),
            _buildCard(
              title: 'Xu hướng 12 tháng',
              subtitle: 'Theo chi tiêu từng tháng',
              child: SizedBox(height: 220, child: _buildTrendChart(trend)),
            ),
            const SizedBox(height: 18),
            _buildCategoryBreakdown(report),
            const SizedBox(height: 18),
            _buildTransactions(report),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: MonexTheme.cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<_AnalyticsPeriod>(
              segments: const [
                ButtonSegment(
                  value: _AnalyticsPeriod.month,
                  icon: Icon(Icons.calendar_view_month_outlined),
                  label: Text('Tháng'),
                ),
                ButtonSegment(
                  value: _AnalyticsPeriod.year,
                  icon: Icon(Icons.calendar_today_outlined),
                  label: Text('Năm'),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (value) {
                setState(() => _period = value.first);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _periodButton(icon: Icons.chevron_left, onTap: _movePrevious),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _periodLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _period == _AnalyticsPeriod.month
                          ? 'Xem đúng dữ liệu theo tháng đã chọn'
                          : 'Tổng hợp cả năm và so với năm trước',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: MonexColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _periodButton(icon: Icons.chevron_right, onTap: _moveNext),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _movePrevious,
                  icon: const Icon(Icons.keyboard_double_arrow_left, size: 18),
                  label: Text(
                    _period == _AnalyticsPeriod.month
                        ? 'Tháng trước'
                        : 'Năm trước',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _jumpToCurrent,
                  icon: const Icon(Icons.today_outlined, size: 18),
                  label: const Text(
                    'Hiện tại',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodButton({required IconData icon, required VoidCallback onTap}) {
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: MonexColors.primary.withValues(alpha: 0.08),
        foregroundColor: MonexColors.primary,
      ),
    );
  }

  Widget _buildSummary(_PeriodReport report, _PeriodReport previous) {
    final expenseDelta = _percentDelta(report.expense, previous.expense);
    final incomeDelta = _percentDelta(report.income, previous.income);
    final balanceColor = report.balance >= 0
        ? MonexColors.income
        : MonexColors.expense;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: MonexTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng kết kỳ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.label,
                      style: const TextStyle(
                        color: MonexColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _smallPill('${report.entries.length} giao dịch'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _summaryMetric(
                  'Thu nhập',
                  money(report.income),
                  MonexColors.income,
                  Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  'Chi tiêu',
                  money(report.expense),
                  MonexColors.expense,
                  Icons.north_east_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _summaryMetric(
                  'Số dư',
                  money(report.balance),
                  balanceColor,
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  'Tỉ lệ chi',
                  report.income == 0
                      ? '0%'
                      : '${(report.expense / report.income * 100).round()}%',
                  MonexColors.info,
                  Icons.pie_chart_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _comparisonTile(
            icon: Icons.trending_up,
            title: 'So với ${previous.label.toLowerCase()}',
            body: previous.entries.isEmpty
                ? 'Chưa có dữ liệu kỳ trước để so sánh.'
                : 'Thu nhập ${_deltaText(incomeDelta)}, chi tiêu ${_deltaText(expenseDelta)} so với kỳ trước.',
            color: expenseDelta <= 0 ? MonexColors.income : MonexColors.expense,
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MonexColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonTile({
    required IconData icon,
    required String title,
    required String body,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: MonexColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MonexTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: MonexColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
          const SizedBox(height: 12),
          const Row(
            children: [
              _LegendDot(color: MonexColors.income, label: 'Thu nhập'),
              SizedBox(width: 14),
              _LegendDot(color: MonexColors.expense, label: 'Chi tiêu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<_BucketStats> buckets) {
    final maxY = buckets.fold<double>(
      100,
      (max, item) =>
          [max, item.income, item.expense].reduce((a, b) => a > b ? a : b),
    );

    return BarChart(
      BarChartData(
        maxY: maxY * 1.25,
        minY: 0,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: MonexColors.line, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == maxY) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _compactMoney(value),
                  style: const TextStyle(
                    color: MonexColors.muted,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= buckets.length) {
                  return const SizedBox.shrink();
                }
                final item = buckets[index];
                if (!_shouldShowBucketLabel(index, buckets.length)) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: MonexColors.muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(buckets.length, (index) {
          final item = buckets[index];
          return BarChartGroupData(
            x: index,
            barsSpace: buckets.length > 20 ? 1 : 4,
            barRods: [
              BarChartRodData(
                toY: item.income,
                width: buckets.length > 20 ? 4 : 9,
                color: MonexColors.income,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: item.expense,
                width: buckets.length > 20 ? 4 : 9,
                color: MonexColors.expense,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTrendChart(List<_BucketStats> stats) {
    final maxY = stats.fold<double>(
      100,
      (max, item) => item.expense > max ? item.expense : max,
    );
    final average =
        stats.fold<double>(0, (sum, item) => sum + item.expense) / stats.length;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.3,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= stats.length || index.isOdd) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    stats[index].label,
                    style: const TextStyle(
                      color: MonexColors.muted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: average,
              color: MonexColors.accent.withValues(alpha: 0.55),
              strokeWidth: 2,
              dashArray: [6, 6],
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              stats.length,
              (index) => FlSpot(index.toDouble(), stats[index].expense),
            ),
            isCurved: true,
            color: MonexColors.expense,
            barWidth: 4,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) => spot.y > average * 1.35,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: MonexColors.expense.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(_PeriodReport report) {
    final rows = report.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MonexTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh mục chi tiêu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            report.label,
            style: const TextStyle(
              color: MonexColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            _emptyText('Chưa có chi tiêu trong kỳ này.')
          else
            ...rows.map(
              (entry) => _categoryRow(
                entry.key,
                entry.value,
                report.expense == 0 ? 0 : entry.value / report.expense,
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoryRow(String category, double amount, double ratio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(ratio * 100).round()}%',
                style: const TextStyle(
                  color: MonexColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                money(amount),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: ratio.clamp(0.0, 1.0),
              color: MonexColors.expense,
              backgroundColor: MonexColors.expense.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions(_PeriodReport report) {
    final entries = [...report.entries]
      ..sort((a, b) => b.date.compareTo(a.date));
    final visible = entries.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MonexTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giao dịch trong kỳ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            report.label,
            style: const TextStyle(
              color: MonexColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            _emptyText('Chưa có giao dịch trong kỳ này.')
          else
            ...visible.map(_transactionRow),
        ],
      ),
    );
  }

  Widget _transactionRow(TransactionEntry entry) {
    final color = entry.isIncome ? MonexColors.income : MonexColors.expense;
    final sign = entry.isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.category} • ${shortDate(entry.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MonexColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$sign ${money(entry.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _smallPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: MonexColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: MonexColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _emptyText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: MonexColors.line.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: MonexColors.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _movePrevious() {
    setState(() {
      if (_period == _AnalyticsPeriod.month) {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
        );
      } else {
        _selectedYear = DateTime(_selectedYear.year - 1);
      }
    });
  }

  void _moveNext() {
    setState(() {
      if (_period == _AnalyticsPeriod.month) {
        _selectedMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
        );
      } else {
        _selectedYear = DateTime(_selectedYear.year + 1);
      }
    });
  }

  void _jumpToCurrent() {
    final now = DateTime.now();
    setState(() {
      _selectedMonth = DateTime(now.year, now.month);
      _selectedYear = DateTime(now.year);
    });
  }

  String get _periodLabel {
    if (_period == _AnalyticsPeriod.month) {
      return 'Tháng ${_selectedMonth.month}/${_selectedMonth.year}';
    }
    return 'Năm ${_selectedYear.year}';
  }

  _PeriodReport _monthReport(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return _reportForRange(
      start: start,
      end: end,
      label: 'Tháng ${start.month}/${start.year}',
    );
  }

  _PeriodReport _yearReport(int year) {
    final start = DateTime(year);
    final end = DateTime(year + 1);
    return _reportForRange(start: start, end: end, label: 'Năm $year');
  }

  _PeriodReport _reportForRange({
    required DateTime start,
    required DateTime end,
    required String label,
  }) {
    final entries = appState.transactions
        .where(
          (entry) => !entry.date.isBefore(start) && entry.date.isBefore(end),
        )
        .toList();
    final income = entries
        .where((entry) => entry.isIncome)
        .fold(0.0, (sum, entry) => sum + entry.amount);
    final expense = entries
        .where((entry) => !entry.isIncome)
        .fold(0.0, (sum, entry) => sum + entry.amount);
    final expenseByCategory = <String, double>{};
    for (final entry in entries.where((entry) => !entry.isIncome)) {
      expenseByCategory[entry.category] =
          (expenseByCategory[entry.category] ?? 0) + entry.amount;
    }

    return _PeriodReport(
      start: start,
      end: end,
      label: label,
      entries: entries,
      income: income,
      expense: expense,
      expenseByCategory: expenseByCategory,
    );
  }

  List<_BucketStats> _dailyBuckets(DateTime month) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(days, (index) {
      final day = DateTime(month.year, month.month, index + 1);
      final next = day.add(const Duration(days: 1));
      final report = _reportForRange(start: day, end: next, label: '');
      return _BucketStats(
        label: '${index + 1}',
        income: report.income,
        expense: report.expense,
      );
    });
  }

  List<_BucketStats> _monthlyBuckets(int year) {
    return List.generate(12, (index) {
      final month = DateTime(year, index + 1);
      final report = _monthReport(month);
      return _BucketStats(
        label: '${index + 1}',
        income: report.income,
        expense: report.expense,
      );
    });
  }

  List<_BucketStats> _buildTrendMonths() {
    final end = _period == _AnalyticsPeriod.month
        ? _selectedMonth
        : DateTime(_selectedYear.year, 12);
    return List.generate(12, (index) {
      final month = DateTime(end.year, end.month - (11 - index));
      final report = _monthReport(month);
      return _BucketStats(
        label: '${month.month}/${month.year.toString().substring(2)}',
        income: report.income,
        expense: report.expense,
      );
    });
  }

  bool _shouldShowBucketLabel(int index, int total) {
    if (total <= 12) return true;
    return index == 0 || index == total - 1 || (index + 1) % 5 == 0;
  }

  double _percentDelta(double current, double previous) {
    if (previous == 0) return current == 0 ? 0 : 100;
    return ((current - previous) / previous) * 100;
  }

  String _deltaText(double delta) {
    if (delta == 0) return 'không đổi';
    return '${delta > 0 ? 'tăng' : 'giảm'} ${delta.abs().toStringAsFixed(1)}%';
  }

  String _compactMoney(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}

class _PeriodReport {
  const _PeriodReport({
    required this.start,
    required this.end,
    required this.label,
    required this.entries,
    required this.income,
    required this.expense,
    required this.expenseByCategory,
  });

  final DateTime start;
  final DateTime end;
  final String label;
  final List<TransactionEntry> entries;
  final double income;
  final double expense;
  final Map<String, double> expenseByCategory;

  double get balance => income - expense;
}

class _BucketStats {
  const _BucketStats({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: MonexColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
