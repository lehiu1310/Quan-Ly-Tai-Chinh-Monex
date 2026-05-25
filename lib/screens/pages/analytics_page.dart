import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final months = _buildMonths();
    final stats = months.map(_monthStats).toList();
    final current = stats.last;
    final previous = stats.length > 1
        ? stats[stats.length - 2]
        : _MonthStats.zero();
    final expenseDelta = previous.expense == 0
        ? 0.0
        : ((current.expense - previous.expense) / previous.expense) * 100;

    return Scaffold(
      backgroundColor: MonexColors.background,
      appBar: AppBar(
        title: const Text('Phân tích'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: MonexBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            _buildSummary(current, previous, expenseDelta),
            const SizedBox(height: 18),
            _buildCard(
              title: 'Thu / chi theo tháng',
              child: SizedBox(height: 240, child: _buildBarChart(stats)),
            ),
            const SizedBox(height: 18),
            _buildCard(
              title: 'Xu hướng 6 tháng',
              child: SizedBox(height: 240, child: _buildLineChart(stats)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
    _MonthStats current,
    _MonthStats previous,
    double delta,
  ) {
    final better = delta <= 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: MonexTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng kết tháng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _summaryMetric(
                  'Thu nhập',
                  money(current.income),
                  MonexColors.income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  'Chi tiêu',
                  money(current.expense),
                  MonexColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (better ? MonexColors.income : MonexColors.expense)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  better ? Icons.trending_down : Icons.trending_up,
                  color: better ? MonexColors.income : MonexColors.expense,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    previous.expense == 0
                        ? 'Chưa đủ dữ liệu tháng trước để so sánh.'
                        : 'Chi tiêu ${better ? 'giảm' : 'tăng'} ${delta.abs().toStringAsFixed(1)}% so với tháng trước.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: MonexColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildBarChart(List<_MonthStats> stats) {
    final maxY = stats.fold<double>(
      100,
      (max, item) =>
          [max, item.income, item.expense].reduce((a, b) => a > b ? a : b),
    );

    return BarChart(
      BarChartData(
        maxY: maxY * 1.25,
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
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= stats.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MM').format(stats[index].month),
                    style: const TextStyle(
                      fontSize: 11,
                      color: MonexColors.muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(stats.length, (index) {
          final item = stats[index];
          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: item.income,
                width: 11,
                color: MonexColors.income,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: item.expense,
                width: 11,
                color: MonexColors.expense,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(List<_MonthStats> stats) {
    final maxY = stats.fold<double>(
      100,
      (max, item) => item.expense > max ? item.expense : max,
    );
    final avg =
        stats.fold<double>(0, (sum, item) => sum + item.expense) / stats.length;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.3,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: avg,
              color: MonexColors.accent.withValues(alpha: 0.5),
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
              checkToShowDot: (spot, barData) => spot.y > avg * 1.35,
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

  List<DateTime> _buildMonths() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final offset = 5 - index;
      return DateTime(now.year, now.month - offset);
    });
  }

  _MonthStats _monthStats(DateTime month) {
    final income = appState.incomes
        .where(
          (item) =>
              item.date.year == month.year && item.date.month == month.month,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
    final expense = appState.expenses
        .where(
          (item) =>
              item.date.year == month.year && item.date.month == month.month,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
    return _MonthStats(month: month, income: income, expense: expense);
  }
}

class _MonthStats {
  const _MonthStats({
    required this.month,
    required this.income,
    required this.expense,
  });

  factory _MonthStats.zero() =>
      _MonthStats(month: DateTime.now(), income: 0, expense: 0);

  final DateTime month;
  final double income;
  final double expense;
}
