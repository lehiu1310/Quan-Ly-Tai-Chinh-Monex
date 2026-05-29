import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';

class CategoryNameDialog extends StatefulWidget {
  const CategoryNameDialog({
    super.key,
    required this.title,
    required this.hintText,
  });

  final String title;
  final String hintText;

  @override
  State<CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<CategoryNameDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context, rootNavigator: true).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Thêm')),
      ],
    );
  }
}

class CategoryDraft {
  const CategoryDraft(this.type, this.name);

  final TransactionType type;
  final String name;
}

class CategoryDraftDialog extends StatefulWidget {
  const CategoryDraftDialog({super.key});

  @override
  State<CategoryDraftDialog> createState() => _CategoryDraftDialogState();
}

class _CategoryDraftDialogState extends State<CategoryDraftDialog> {
  final _controller = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop(CategoryDraft(_selectedType, name));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm danh mục'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<TransactionType>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: const [
              DropdownMenuItem(
                value: TransactionType.income,
                child: Text('Danh mục thu nhập'),
              ),
              DropdownMenuItem(
                value: TransactionType.expense,
                child: Text('Danh mục chi phí'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedType = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Tên danh mục mới'),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Thêm')),
      ],
    );
  }
}
