import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/widgets/category_dialogs.dart';
import 'package:table_calendar/table_calendar.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryScrollController = ScrollController();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    if (appState.incomeCategories.length > 1) {
      _selectedCategoryIndex = 1;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    appState.addIncome(
      title: _titleController.text,
      amount: parseMoney(_amountController.text)!,
      category: appState.incomeCategories[_selectedCategoryIndex],
      date: _selectedDay,
    );

    Navigator.of(context).pop(true);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDay = date;
      _focusedDay = date;
    });
  }

  DateTime _sameDayPreviousMonth() {
    final targetMonth = DateTime(_selectedDay.year, _selectedDay.month - 1);
    final lastDayOfTargetMonth = DateTime(
      targetMonth.year,
      targetMonth.month + 1,
      0,
    ).day;
    final day = _selectedDay.day > lastDayOfTargetMonth
        ? lastDayOfTargetMonth
        : _selectedDay.day;
    return DateTime(targetMonth.year, targetMonth.month, day);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035, 12, 31),
      helpText: 'Chọn ngày thu nhập',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked == null) return;
    _selectDate(picked);
  }

  Future<void> _addCategory() async {
    final category = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => const CategoryNameDialog(
        title: 'Thêm danh mục thu nhập',
        hintText: 'Ví dụ: Bán hàng',
      ),
    );
    final value = category?.trim();
    if (value == null || value.isEmpty) return;

    appState.addCategory(TransactionType.income, value);
    final newIndex = appState.incomeCategories.indexWhere(
      (item) => item.toLowerCase() == value.toLowerCase(),
    );
    setState(() {
      _selectedCategoryIndex = newIndex;
      if (_selectedCategoryIndex < 0) _selectedCategoryIndex = 0;
    });
    if (newIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_categoryScrollController.hasClients) return;
        _categoryScrollController.animateTo(
          _categoryScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonexColors.background,
      appBar: AppBar(
        title: const Text('Thêm thu nhập'),
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
              const Text(
                'Ngày thu nhập',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _buildCalendar(),
              const SizedBox(height: 12),
              _buildDateActions(MonexColors.income),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _titleController,
                label: 'Tiêu đề thu nhập',
                hint: 'Kinh doanh phụ',
                icon: Icons.edit_note_outlined,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Nhập tiêu đề thu nhập';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _amountController,
                label: 'Số tiền',
                hint: '1,368',
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
                'Danh mục thu nhập',
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
            color: MonexColors.income,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: MonexColors.income.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildDateActions(Color color) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined, size: 18),
            label: Text(
              shortDate(_selectedDay),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _selectDate(_sameDayPreviousMonth()),
            icon: const Icon(Icons.keyboard_double_arrow_left, size: 18),
            label: const Text('Tháng trước', overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(foregroundColor: color),
          ),
        ),
      ],
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
    final categories = appState.incomeCategories;

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
              controller: _categoryScrollController,
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
                  selectedColor: MonexColors.income,
                  backgroundColor: MonexColors.surface,
                  side: BorderSide(
                    color: isSelected ? MonexColors.income : MonexColors.line,
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
        label: const Text('THÊM THU NHẬP'),
        style: ElevatedButton.styleFrom(
          backgroundColor: MonexColors.income,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
