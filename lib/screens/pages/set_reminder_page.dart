import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/services/notification_service.dart';
import 'package:monex/theme/app_theme.dart';

class SetReminderPage extends StatefulWidget {
  const SetReminderPage({super.key});

  @override
  State<SetReminderPage> createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  final List<String> _bills = [
    'Mua xe',
    'Vay xe',
    'Tiền thuê nhà',
    'Hóa đơn Internet',
    'Hóa đơn điện',
  ];

  final List<String> _frequencies = [
    'Không lặp lại',
    'Hàng ngày',
    'Hàng tuần',
    'Hàng tháng',
    'Hàng năm',
  ];

  String _selectedBill = 'Mua xe';
  String _selectedFrequency = 'Hàng tháng';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final reminder = appState.addReminder(
      title: _selectedBill,
      amount: parseMoney(_amountController.text)!,
      dueDate: _selectedDate,
      frequency: _selectedFrequency,
    );
    notificationService.scheduleReminder(reminder);

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonexColors.background,
      appBar: AppBar(
        title: const Text('Đặt lời nhắc'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              _buildDropdownField(
                label: 'Chọn hóa đơn',
                value: _selectedBill,
                items: _bills,
                icon: Icons.receipt_long_outlined,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedBill = value);
                },
              ),
              const SizedBox(height: 18),
              _buildAmountField(),
              const SizedBox(height: 18),
              _buildDropdownField(
                label: 'Tần suất',
                value: _selectedFrequency,
                items: _frequencies,
                icon: Icons.repeat,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedFrequency = value);
                },
              ),
              const SizedBox(height: 18),
              _buildDateField(),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.alarm_add_outlined),
                  label: const Text('ĐẶT LỜI NHẮC'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: MonexColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số tiền',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          validator: (value) {
            final amount = parseMoney(value ?? '');
            if (amount == null || amount <= 0) {
              return 'Nhập số tiền hợp lệ';
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: '12,000',
            prefixIcon: Icon(Icons.attach_money, color: MonexColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày đến hạn',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: _selectDate,
          decoration: const InputDecoration(
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: MonexColors.muted,
            ),
            suffixIcon: Icon(Icons.keyboard_arrow_down),
          ),
        ),
      ],
    );
  }
}
