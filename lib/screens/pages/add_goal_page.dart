import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/theme/app_theme.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  final List<String> _contributionTypes = [
    'Hàng ngày',
    'Hàng tuần',
    'Hàng tháng',
    'Hàng năm',
  ];

  String _selectedContributionType = 'Hàng tháng';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 90));

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
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

    appState.addGoal(
      title: _titleController.text,
      targetAmount: parseMoney(_amountController.text)!,
      deadline: _selectedDate,
      frequency: _selectedContributionType,
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonexColors.background,
      appBar: AppBar(
        title: const Text('Thêm mục tiêu'),
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
              _buildTextField(
                controller: _titleController,
                label: 'Tiêu đề mục tiêu',
                hint: 'Mua xe',
                icon: Icons.flag_outlined,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Nhập tiêu đề mục tiêu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _amountController,
                label: 'Số tiền mục tiêu',
                hint: '188,000',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final amount = parseMoney(value ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Nhập số tiền hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _buildDropdownField(),
              const SizedBox(height: 18),
              _buildDateField(),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.savings_outlined),
                  label: const Text('THÊM MỤC TIÊU'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: MonexColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại đóng góp',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedContributionType,
          items: _contributionTypes.map((value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedContributionType = value);
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.repeat, color: MonexColors.muted),
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
          'Hạn chót',
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
