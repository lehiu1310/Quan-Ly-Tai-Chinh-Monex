import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    final shoppingIndex = appState.expenseCategories.indexOf('Mua sắm');
    _selectedCategoryIndex = shoppingIndex >= 0 ? shoppingIndex : 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    appState.addExpense(
      title: _titleController.text,
      amount: parseMoney(_amountController.text)!,
      category: appState.expenseCategories[_selectedCategoryIndex],
      date: _selectedDay,
    );

    Navigator.of(context).pop(true);
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final category = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm danh mục chi phí'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Ví dụ: Xăng xe'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    final value = category?.trim();
    if (value == null || value.isEmpty) return;

    appState.addCategory(TransactionType.expense, value);
    setState(() {
      _selectedCategoryIndex = appState.expenseCategories.indexWhere(
        (item) => item.toLowerCase() == value.toLowerCase(),
      );
      if (_selectedCategoryIndex < 0) _selectedCategoryIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonexColors.background,
      appBar: AppBar(
        title: const Text('Thêm chi phí'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendar(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _titleController,
                label: 'Tiêu đề chi phí',
                hint: 'Mua xe',
                icon: Icons.edit_note_outlined,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Nhập tiêu đề chi phí';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _amountController,
                label: 'Số tiền',
                hint: '2,500',
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
              const SizedBox(height: 24),
              const Text(
                'Danh mục chi phí',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 36),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
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

  Widget _buildCategorySelector() {
    final categories = appState.expenseCategories;

    return Row(
      children: [
        InkWell(
          onTap: _addCategory,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 50,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: MonexColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MonexColors.line, width: 1.5),
            ),
            child: const Icon(Icons.add, color: MonexColors.muted),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return ChoiceChip(
                  label: Text(categories[index]),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : MonexColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedColor: MonexColors.expense,
                  backgroundColor: MonexColors.surface,
                  side: BorderSide(
                    color: isSelected ? MonexColors.expense : MonexColors.line,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('THÊM CHI PHÍ'),
        style: ElevatedButton.styleFrom(
          backgroundColor: MonexColors.expense,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
