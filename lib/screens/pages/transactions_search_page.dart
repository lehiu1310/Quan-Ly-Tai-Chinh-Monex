import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/widgets/empty_state.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

enum _DateFilter { all, week, month }

enum _TypeFilter { all, income, expense }

class TransactionsSearchPage extends StatefulWidget {
  const TransactionsSearchPage({super.key});

  @override
  State<TransactionsSearchPage> createState() => _TransactionsSearchPageState();
}

class _TransactionsSearchPageState extends State<TransactionsSearchPage> {
  final _searchController = TextEditingController();
  _DateFilter _dateFilter = _DateFilter.all;
  _TypeFilter _typeFilter = _TypeFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final entries = _filteredEntries();
        return Scaffold(
          backgroundColor: MonexColors.background,
          appBar: AppBar(
            title: const Text('Tìm giao dịch'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: MonexBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo tên hoặc danh mục',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilters(),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: MonexEmptyState(
                      title: 'Không tìm thấy giao dịch',
                      subtitle: 'Thử đổi từ khóa hoặc bộ lọc.',
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, index) =>
                        _buildEntry(entries[index]),
                    separatorBuilder: (context, index) =>
                        const Divider(color: MonexColors.line),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        SegmentedButton<_TypeFilter>(
          segments: const [
            ButtonSegment(value: _TypeFilter.all, label: Text('Tất cả')),
            ButtonSegment(value: _TypeFilter.income, label: Text('Thu')),
            ButtonSegment(value: _TypeFilter.expense, label: Text('Chi')),
          ],
          selected: {_typeFilter},
          onSelectionChanged: (value) {
            setState(() => _typeFilter = value.first);
          },
        ),
        const SizedBox(height: 10),
        SegmentedButton<_DateFilter>(
          segments: const [
            ButtonSegment(value: _DateFilter.all, label: Text('Tất cả')),
            ButtonSegment(value: _DateFilter.week, label: Text('Tuần')),
            ButtonSegment(value: _DateFilter.month, label: Text('Tháng')),
          ],
          selected: {_dateFilter},
          onSelectionChanged: (value) {
            setState(() => _dateFilter = value.first);
          },
        ),
      ],
    );
  }

  Widget _buildEntry(TransactionEntry entry) {
    final color = entry.isIncome ? MonexColors.income : MonexColors.expense;
    final sign = entry.isIncome ? '+' : '-';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: MonexTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
                const SizedBox(height: 3),
                Text(
                  '${entry.category} • ${shortDate(entry.date)}',
                  style: const TextStyle(
                    color: MonexColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign ${money(entry.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  List<TransactionEntry> _filteredEntries() {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final entries = appState.transactions.where((entry) {
      if (_typeFilter == _TypeFilter.income && !entry.isIncome) return false;
      if (_typeFilter == _TypeFilter.expense && entry.isIncome) return false;
      if (_dateFilter == _DateFilter.week && entry.date.isBefore(startOfWeek)) {
        return false;
      }
      if (_dateFilter == _DateFilter.month &&
          (entry.date.month != now.month || entry.date.year != now.year)) {
        return false;
      }
      if (query.isEmpty) return true;
      return entry.title.toLowerCase().contains(query) ||
          entry.category.toLowerCase().contains(query);
    }).toList();

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }
}
