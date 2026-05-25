import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/pages/set_reminder_page.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({super.key});

  Future<void> _openSetReminder(BuildContext context) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const SetReminderPage()),
    );
    if (added != true || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm lời nhắc'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final reminders = [...appState.reminders]
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

        return Scaffold(
          backgroundColor: MonexColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Lời nhắc'),
            actions: [
              IconButton(
                onPressed: () => _openSetReminder(context),
                icon: const Icon(Icons.add, color: MonexColors.ink, size: 28),
              ),
            ],
          ),
          body: MonexBackground(
            child: reminders.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có lời nhắc nào',
                      style: TextStyle(color: MonexColors.muted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      return _buildReminderItem(reminders[index]);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildReminderItem(ReminderEntry reminder) {
    final daysLeft = reminder.dueDate.difference(DateTime.now()).inDays;
    final dueLabel = daysLeft < 0
        ? 'Đã quá hạn'
        : daysLeft == 0
        ? 'Hôm nay'
        : 'Còn $daysLeft ngày';

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
                  'Ngày nhắc: ${shortDate(reminder.reminderDate)}',
                  style: const TextStyle(
                    color: MonexColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: MonexColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  reminder.frequency,
                  style: const TextStyle(
                    color: MonexColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: MonexColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      money(reminder.amount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MonexColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dueLabel,
                    style: const TextStyle(
                      color: MonexColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shortDate(reminder.dueDate),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: MonexColors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
