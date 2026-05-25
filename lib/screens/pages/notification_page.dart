import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/pages/add_transaction_page.dart';
import 'package:monex/screens/pages/analytics_page.dart';
import 'package:monex/screens/pages/transactions_search_page.dart';
import 'package:monex/screens/widgets/empty_state.dart';
import 'package:monex/services/insight_service.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final insight = insightService.buildAssistantInsight(appState);
        final notifications = insightService.buildNotifications(appState);

        return Scaffold(
          backgroundColor: MonexColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Thông báo'),
            centerTitle: true,
          ),
          body: MonexBackground(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
              children: [
                _AssistantCard(insight: insight),
                const SizedBox(height: 18),
                _buildSectionTitle(notifications.length),
                const SizedBox(height: 12),
                if (notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 34),
                    child: MonexEmptyState(
                      title: 'Chưa có thông báo cần xử lý',
                      subtitle:
                          'App sẽ chỉ hiện cảnh báo khi có dữ liệu thật: hóa đơn đến hạn, ngân sách rủi ro hoặc giao dịch bất thường.',
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _NotificationTile(item: notifications[index]);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(int count) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Cảnh báo thông minh',
            style: TextStyle(
              color: MonexColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: MonexColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count mục',
            style: const TextStyle(
              color: MonexColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({required this.insight});

  final AssistantInsight insight;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(insight.severity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: MonexTheme.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: MonexTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(_severityIcon(insight.severity), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trợ lý chi tiêu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      insight.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  insight.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: insight.progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            insight.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            insight.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.38,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInsightTarget(context, insight),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: FittedBox(child: Text(insight.primaryAction)),
              style: ElevatedButton.styleFrom(
                foregroundColor: MonexColors.primary,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInsightTarget(
    BuildContext context,
    AssistantInsight insight,
  ) async {
    final text = insight.primaryAction.toLowerCase();
    if (text.contains('thêm')) {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddTransactionPage(),
      );
      return;
    }

    if (text.contains('phân tích') || text.contains('ngân sách')) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const AnalyticsPage()));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionsSearchPage()),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final SmartNotification item;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(item.severity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: MonexTheme.cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: MonexColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SeverityChip(severity: item.severity),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.34,
                    color: MonexColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: color.withValues(alpha: 0.9),
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.source,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      item.timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MonexColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity});

  final InsightSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(severity);
    final label = switch (severity) {
      InsightSeverity.danger => 'Gấp',
      InsightSeverity.warning => 'Cần xem',
      InsightSeverity.good => 'Tốt',
      InsightSeverity.info => 'Tin',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

Color _severityColor(InsightSeverity severity) {
  return switch (severity) {
    InsightSeverity.danger => MonexColors.expense,
    InsightSeverity.warning => MonexColors.accent,
    InsightSeverity.good => MonexColors.income,
    InsightSeverity.info => MonexColors.info,
  };
}

IconData _severityIcon(InsightSeverity severity) {
  return switch (severity) {
    InsightSeverity.danger => Icons.priority_high_rounded,
    InsightSeverity.warning => Icons.psychology_alt_outlined,
    InsightSeverity.good => Icons.check_circle_outline_rounded,
    InsightSeverity.info => Icons.auto_awesome,
  };
}
