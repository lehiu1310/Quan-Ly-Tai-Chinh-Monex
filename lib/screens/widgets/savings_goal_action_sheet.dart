import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/theme/app_theme.dart';

enum SavingsGoalActionMode { deposit, withdraw }

class SavingsGoalActionSheet extends StatefulWidget {
  const SavingsGoalActionSheet({
    super.key,
    required this.goal,
    this.initialMode = SavingsGoalActionMode.deposit,
  });

  final SavingsGoal goal;
  final SavingsGoalActionMode initialMode;

  @override
  State<SavingsGoalActionSheet> createState() => _SavingsGoalActionSheetState();
}

class _SavingsGoalActionSheetState extends State<SavingsGoalActionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  late SavingsGoalActionMode _mode;

  static const List<double> _quickAmounts = [100, 200, 500, 1000];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final remaining = (goal.targetAmount - goal.currentAmount)
        .clamp(0, goal.targetAmount)
        .toDouble();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: MonexColors.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: MonexColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(goal.icon, color: MonexColors.primary),
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
                              color: MonexColors.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Còn thiếu ${money(remaining)}',
                            style: const TextStyle(
                              color: MonexColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: MonexColors.line,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    MonexColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã có ${money(goal.currentAmount)}',
                      style: const TextStyle(
                        color: MonexColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Mục tiêu ${money(goal.targetAmount)}',
                      style: const TextStyle(
                        color: MonexColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: MonexColors.line,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildModeButton(
                        mode: SavingsGoalActionMode.deposit,
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Nạp tiền',
                      ),
                      _buildModeButton(
                        mode: SavingsGoalActionMode.withdraw,
                        icon: Icons.remove_circle_outline_rounded,
                        label: 'Rút tiền',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  validator: _validateAmount,
                  decoration: InputDecoration(
                    labelText: _mode == SavingsGoalActionMode.deposit
                        ? 'Số tiền muốn nạp'
                        : 'Số tiền muốn rút',
                    hintText: '100',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickAmounts.map((amount) {
                    return ActionChip(
                      label: Text(money(amount)),
                      onPressed: () {
                        _amountController.text = amount.toStringAsFixed(0);
                        _formKey.currentState?.validate();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: Icon(
                      _mode == SavingsGoalActionMode.deposit
                          ? Icons.savings_outlined
                          : Icons.shopping_bag_outlined,
                    ),
                    label: Text(
                      _mode == SavingsGoalActionMode.deposit
                          ? 'Nạp vào lợn đất'
                          : 'Rút ra để dùng',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required SavingsGoalActionMode mode,
    required IconData icon,
    required String label,
  }) {
    final selected = _mode == mode;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _mode = mode);
          _formKey.currentState?.validate();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? MonexColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : MonexColors.muted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : MonexColors.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    final amount = parseMoney(value ?? '');
    if (amount == null || amount <= 0) {
      return 'Nhập số tiền hợp lệ';
    }

    if (_mode == SavingsGoalActionMode.deposit) {
      final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
      if (remaining <= 0) return 'Mục tiêu này đã đủ tiền';
      if (amount > remaining) {
        return 'Mục tiêu còn thiếu ${money(remaining)} thôi';
      }
      return null;
    }

    if (widget.goal.currentAmount <= 0) {
      return 'Mục tiêu này chưa có tiền để rút';
    }
    if (amount > widget.goal.currentAmount) {
      return 'Không thể rút quá ${money(widget.goal.currentAmount)}';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = parseMoney(_amountController.text)!;
    final isDeposit = _mode == SavingsGoalActionMode.deposit;
    final success = isDeposit
        ? appState.depositSavings(goalId: widget.goal.id, amount: amount)
        : appState.withdrawSavings(goalId: widget.goal.id, amount: amount);
    if (!success) return;

    final action = isDeposit ? 'Đã nạp' : 'Đã rút';
    final direction = isDeposit ? 'vào' : 'từ';
    Navigator.of(
      context,
    ).pop('$action ${money(amount)} $direction ${widget.goal.title}');
  }
}
