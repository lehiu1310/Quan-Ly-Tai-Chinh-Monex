import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TransactionType { income, expense }

class UserAccount {
  const UserAccount({
    required this.username,
    required this.email,
    required this.password,
  });

  final String username;
  final String email;
  final String password;
}

class TransactionEntry {
  TransactionEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.icon,
  });

  final String id;
  final TransactionType type;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final IconData icon;

  bool get isIncome => type == TransactionType.income;
}

class SavingsGoal {
  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.frequency,
    required this.icon,
  });

  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  final DateTime deadline;
  final String frequency;
  final IconData icon;

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0).toDouble();
  }
}

class ReminderEntry {
  ReminderEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.reminderDate,
    required this.dueDate,
    required this.frequency,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime reminderDate;
  final DateTime dueDate;
  final String frequency;
}

class BudgetInfo {
  const BudgetInfo({
    required this.category,
    required this.limit,
    required this.spent,
    required this.icon,
    required this.color,
  });

  final String category;
  final double limit;
  final double spent;
  final IconData icon;
  final Color color;

  double get progress {
    if (limit <= 0) return 0;
    return (spent / limit).clamp(0.0, 1.2).toDouble();
  }

  bool get isHigh => progress >= 0.75;
}

class _AccountLedger {
  _AccountLedger({
    List<TransactionEntry>? transactions,
    List<SavingsGoal>? goals,
    List<ReminderEntry>? reminders,
    List<String>? incomeCategories,
    List<String>? expenseCategories,
    Map<String, double>? budgetLimits,
  }) : transactions = List<TransactionEntry>.of(transactions ?? []),
       goals = List<SavingsGoal>.of(goals ?? []),
       reminders = List<ReminderEntry>.of(reminders ?? []),
       incomeCategories = List<String>.of(
         incomeCategories ?? ['Lương', 'Thưởng', 'Freelance'],
       ),
       expenseCategories = List<String>.of(
         expenseCategories ?? ['Ăn uống', 'Giao thông', 'Mua sắm', 'Hóa đơn'],
       ),
       budgetLimits =
           budgetLimits ??
           {'Ăn uống': 500, 'Mua sắm': 500, 'Giao thông': 100, 'Hóa đơn': 250};

  final List<TransactionEntry> transactions;
  final List<SavingsGoal> goals;
  final List<ReminderEntry> reminders;
  final List<String> incomeCategories;
  final List<String> expenseCategories;
  final Map<String, double> budgetLimits;
}

class MonexAppState extends ChangeNotifier {
  MonexAppState() {
    _seedDemoAccount();
  }

  static const String _storageKey = 'monex_app_state_v1';
  static const String _guestKey = '__guest__';

  final List<UserAccount> _accounts = [];
  final Map<String, _AccountLedger> _ledgers = {};

  SharedPreferences? _prefs;
  bool _hasLoaded = false;

  UserAccount? _currentAccount;
  String _displayName = 'Minh';

  List<UserAccount> get accounts => List.unmodifiable(_accounts);
  List<TransactionEntry> get transactions =>
      List.unmodifiable(_activeLedger.transactions);
  List<SavingsGoal> get goals => List.unmodifiable(_activeLedger.goals);
  List<ReminderEntry> get reminders =>
      List.unmodifiable(_activeLedger.reminders);
  List<String> get incomeCategories =>
      List.unmodifiable(_activeLedger.incomeCategories);
  List<String> get expenseCategories =>
      List.unmodifiable(_activeLedger.expenseCategories);
  UserAccount? get currentAccount => _currentAccount;
  String get displayName => _displayName;

  List<TransactionEntry> get incomes => _activeLedger.transactions
      .where((entry) => entry.type == TransactionType.income)
      .toList(growable: false);

  List<TransactionEntry> get expenses => _activeLedger.transactions
      .where((entry) => entry.type == TransactionType.expense)
      .toList(growable: false);

  List<TransactionEntry> get recentTransactions {
    final items = [..._activeLedger.transactions];
    items.sort((a, b) => b.date.compareTo(a.date));
    return items.take(8).toList(growable: false);
  }

  List<TransactionEntry> transactionsInRange(DateTime start, DateTime end) {
    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(end.year, end.month, end.day);
    return _activeLedger.transactions
        .where((entry) {
          final date = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          return !date.isBefore(from) && date.isBefore(to);
        })
        .toList(growable: false);
  }

  List<TransactionEntry> transactionsForMonth(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return transactionsInRange(start, end);
  }

  List<TransactionEntry> incomesForMonth(DateTime month) =>
      transactionsForMonth(month)
          .where((entry) => entry.type == TransactionType.income)
          .toList(growable: false);

  List<TransactionEntry> expensesForMonth(DateTime month) =>
      transactionsForMonth(month)
          .where((entry) => entry.type == TransactionType.expense)
          .toList(growable: false);

  List<TransactionEntry> get currentMonthTransactions =>
      transactionsForMonth(DateTime.now());
  List<TransactionEntry> get currentMonthIncomes =>
      incomesForMonth(DateTime.now());
  List<TransactionEntry> get currentMonthExpenses =>
      expensesForMonth(DateTime.now());

  double get incomeTotal => incomes.fold(0, (sum, item) => sum + item.amount);
  double get expenseTotal => expenses.fold(0, (sum, item) => sum + item.amount);
  double get balance => incomeTotal - expenseTotal;
  double incomeTotalForMonth(DateTime month) =>
      incomesForMonth(month).fold(0, (sum, item) => sum + item.amount);
  double expenseTotalForMonth(DateTime month) =>
      expensesForMonth(month).fold(0, (sum, item) => sum + item.amount);
  double balanceForMonth(DateTime month) =>
      incomeTotalForMonth(month) - expenseTotalForMonth(month);
  double get currentMonthIncomeTotal => incomeTotalForMonth(DateTime.now());
  double get currentMonthExpenseTotal => expenseTotalForMonth(DateTime.now());
  double get currentMonthBalance => balanceForMonth(DateTime.now());
  double get savingsTotal =>
      goals.fold(0, (sum, item) => sum + item.currentAmount);
  double get billsTotal => reminders.fold(0, (sum, item) => sum + item.amount);

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final rawState = _prefs?.getString(_storageKey);
    if (rawState == null) {
      _hasLoaded = true;
      await saveNow();
      return;
    }

    try {
      final decoded = jsonDecode(rawState);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Saved state is not a JSON object');
      }

      _restoreFromJson(decoded);
      _hasLoaded = true;
    } catch (_) {
      _resetToDemoAccount();
      _hasLoaded = true;
      await saveNow();
    }
  }

  Future<void> saveNow() async {
    if (!_hasLoaded) return;
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_toJson()));
  }

  bool register({
    required String username,
    required String email,
    required String password,
  }) {
    final normalizedUsername = username.trim().toLowerCase();
    final normalizedEmail = email.trim().toLowerCase();
    final exists = _accounts.any(
      (account) =>
          account.username.toLowerCase() == normalizedUsername ||
          account.email.toLowerCase() == normalizedEmail,
    );
    if (exists) return false;

    final account = UserAccount(
      username: username.trim(),
      email: email.trim(),
      password: password,
    );
    _accounts.add(account);
    _ledgers[_accountKey(account)] = _AccountLedger();
    _currentAccount = account;
    _displayName = account.username.trim();
    _persistAndNotify();
    return true;
  }

  bool login({required String identity, required String password}) {
    final normalizedIdentity = identity.trim().toLowerCase();
    UserAccount? matched;
    for (final account in _accounts) {
      if ((account.username.toLowerCase() == normalizedIdentity ||
              account.email.toLowerCase() == normalizedIdentity) &&
          account.password == password) {
        matched = account;
        break;
      }
    }
    if (matched == null) return false;

    _currentAccount = matched;
    _displayName = matched.username;
    _ledgers.putIfAbsent(_accountKey(matched), _AccountLedger.new);
    _persistAndNotify();
    return true;
  }

  void useGuestAccount() {
    _currentAccount = null;
    _displayName = 'Khách';
    _ledgers.putIfAbsent(_guestKey, _AccountLedger.new);
    _persistAndNotify();
  }

  void logout() {
    _currentAccount = null;
    _displayName = 'Khách';
    _ledgers.putIfAbsent(_guestKey, _AccountLedger.new);
    _persistAndNotify();
  }

  void addIncome({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
  }) {
    final ledger = _activeLedger;
    ledger.transactions.add(
      TransactionEntry(
        id: _newId(),
        type: TransactionType.income,
        title: title.trim(),
        category: category,
        amount: amount,
        date: date,
        paymentMethod: 'Tiền mặt',
        icon: _incomeIcon(category),
      ),
    );
    _ensureCategory(ledger.incomeCategories, category);
    _persistAndNotify();
  }

  void addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
  }) {
    final ledger = _activeLedger;
    ledger.transactions.add(
      TransactionEntry(
        id: _newId(),
        type: TransactionType.expense,
        title: title.trim(),
        category: category,
        amount: amount,
        date: date,
        paymentMethod: 'Tiền mặt',
        icon: _expenseIcon(category),
      ),
    );
    _ensureCategory(ledger.expenseCategories, category);
    ledger.budgetLimits.putIfAbsent(category, () => amount * 2);
    _persistAndNotify();
  }

  void addGoal({
    required String title,
    required double targetAmount,
    required DateTime deadline,
    required String frequency,
  }) {
    _activeLedger.goals.add(
      SavingsGoal(
        id: _newId(),
        title: title.trim(),
        targetAmount: targetAmount,
        currentAmount: 0,
        deadline: deadline,
        frequency: frequency,
        icon: _goalIcon(title),
      ),
    );
    _persistAndNotify();
  }

  bool depositSavings({required String goalId, required double amount}) {
    if (amount <= 0) return false;
    final goal = _findGoal(goalId);
    if (goal == null || goal.currentAmount >= goal.targetAmount) return false;

    goal.currentAmount = (goal.currentAmount + amount)
        .clamp(0, goal.targetAmount)
        .toDouble();
    _persistAndNotify();
    return true;
  }

  bool withdrawSavings({required String goalId, required double amount}) {
    if (amount <= 0) return false;
    final goal = _findGoal(goalId);
    if (goal == null || goal.currentAmount <= 0) return false;

    goal.currentAmount = (goal.currentAmount - amount)
        .clamp(0, goal.targetAmount)
        .toDouble();
    _persistAndNotify();
    return true;
  }

  ReminderEntry addReminder({
    required String title,
    required double amount,
    required DateTime dueDate,
    required String frequency,
  }) {
    final reminder = ReminderEntry(
      id: _newId(),
      title: title.trim(),
      amount: amount,
      reminderDate: DateTime.now(),
      dueDate: dueDate,
      frequency: frequency,
    );
    _activeLedger.reminders.add(reminder);
    _persistAndNotify();
    return reminder;
  }

  void addCategory(TransactionType type, String category) {
    final value = category.trim();
    if (value.isEmpty) return;
    final ledger = _activeLedger;
    _ensureCategory(
      type == TransactionType.income
          ? ledger.incomeCategories
          : ledger.expenseCategories,
      value,
    );
    if (type == TransactionType.expense) {
      ledger.budgetLimits.putIfAbsent(value, () => 300);
    }
    _persistAndNotify();
  }

  List<BudgetInfo> get budgets => budgetsForMonth(DateTime.now());

  List<BudgetInfo> budgetsForMonth(DateTime month) {
    final ledger = _activeLedger;
    final monthExpenses = expensesForMonth(month);
    return ledger.budgetLimits.entries
        .map((entry) {
          final spent = monthExpenses
              .where((expense) => expense.category == entry.key)
              .fold(0.0, (sum, expense) => sum + expense.amount);
          return BudgetInfo(
            category: entry.key,
            limit: entry.value,
            spent: spent,
            icon: _expenseIcon(entry.key),
            color: _budgetColor(entry.key),
          );
        })
        .toList(growable: false);
  }

  BudgetInfo? get highestBudgetRisk {
    final active = budgets.where((budget) => budget.spent > 0).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.progress.compareTo(a.progress));
    return active.first;
  }

  double spentForCategory(String category) {
    return currentMonthExpenses
        .where((expense) => expense.category == category)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  _AccountLedger get _activeLedger {
    return _ledgers.putIfAbsent(_currentLedgerKey, _AccountLedger.new);
  }

  String get _currentLedgerKey {
    final account = _currentAccount;
    return account == null ? _guestKey : _accountKey(account);
  }

  String _accountKey(UserAccount account) {
    return account.username.trim().toLowerCase();
  }

  SavingsGoal? _findGoal(String goalId) {
    for (final goal in _activeLedger.goals) {
      if (goal.id == goalId) return goal;
    }
    return null;
  }

  void _persistAndNotify() {
    notifyListeners();
    if (_hasLoaded) unawaited(saveNow());
  }

  Map<String, dynamic> _toJson() {
    return {
      'accounts': _accounts.map(_accountToJson).toList(growable: false),
      'ledgers': _ledgers.map(
        (key, ledger) => MapEntry(key, _ledgerToJson(ledger)),
      ),
      'currentLedgerKey': _currentLedgerKey,
      'displayName': _displayName,
    };
  }

  void _restoreFromJson(Map<String, dynamic> data) {
    _accounts.clear();
    _ledgers.clear();

    final accountsJson = data['accounts'];
    if (accountsJson is List) {
      for (final item in accountsJson) {
        final account = _accountFromJson(item);
        if (account == null) continue;
        final key = _accountKey(account);
        final alreadyExists = _accounts.any(
          (existing) => _accountKey(existing) == key,
        );
        if (!alreadyExists) _accounts.add(account);
      }
    }

    if (_accounts.isEmpty) {
      throw const FormatException('Saved state has no accounts');
    }

    final ledgersJson = data['ledgers'];
    if (ledgersJson is Map) {
      for (final entry in ledgersJson.entries) {
        final key = entry.key.toString();
        if (key.trim().isEmpty) continue;
        _ledgers[key] = _ledgerFromJson(entry.value);
      }
    }

    _ledgers.putIfAbsent(_guestKey, _AccountLedger.new);
    for (final account in _accounts) {
      _ledgers.putIfAbsent(_accountKey(account), _AccountLedger.new);
    }

    final currentKey = _stringFromJson(data['currentLedgerKey'], '');
    if (currentKey == _guestKey) {
      _currentAccount = null;
    } else {
      _currentAccount = _accountByKey(currentKey) ?? _accounts.first;
    }

    final savedName = _stringFromJson(data['displayName'], '').trim();
    _displayName = savedName.isNotEmpty
        ? savedName
        : (_currentAccount?.username ?? 'Khách');
  }

  UserAccount? _accountByKey(String key) {
    for (final account in _accounts) {
      if (_accountKey(account) == key) return account;
    }
    return null;
  }

  Map<String, dynamic> _accountToJson(UserAccount account) {
    return {
      'username': account.username,
      'email': account.email,
      'password': account.password,
    };
  }

  UserAccount? _accountFromJson(Object? value) {
    if (value is! Map) return null;
    final username = _stringFromJson(value['username'], '').trim();
    final email = _stringFromJson(value['email'], '').trim();
    final password = _stringFromJson(value['password'], '');
    if (username.isEmpty || email.isEmpty) return null;
    return UserAccount(username: username, email: email, password: password);
  }

  Map<String, dynamic> _ledgerToJson(_AccountLedger ledger) {
    return {
      'transactions': ledger.transactions
          .map(_transactionToJson)
          .toList(growable: false),
      'goals': ledger.goals.map(_goalToJson).toList(growable: false),
      'reminders': ledger.reminders
          .map(_reminderToJson)
          .toList(growable: false),
      'incomeCategories': ledger.incomeCategories,
      'expenseCategories': ledger.expenseCategories,
      'budgetLimits': ledger.budgetLimits,
    };
  }

  _AccountLedger _ledgerFromJson(Object? value) {
    if (value is! Map) return _AccountLedger();

    return _AccountLedger(
      transactions: _transactionsFromJson(value['transactions']),
      goals: _goalsFromJson(value['goals']),
      reminders: _remindersFromJson(value['reminders']),
      incomeCategories: _stringListFromJson(value['incomeCategories']),
      expenseCategories: _stringListFromJson(value['expenseCategories']),
      budgetLimits: _budgetLimitsFromJson(value['budgetLimits']),
    );
  }

  Map<String, dynamic> _transactionToJson(TransactionEntry entry) {
    return {
      'id': entry.id,
      'type': entry.type.name,
      'title': entry.title,
      'category': entry.category,
      'amount': entry.amount,
      'date': entry.date.toIso8601String(),
      'paymentMethod': entry.paymentMethod,
    };
  }

  TransactionEntry? _transactionFromJson(Object? value) {
    if (value is! Map) return null;
    final typeName = _stringFromJson(
      value['type'],
      TransactionType.expense.name,
    );
    final type = typeName == TransactionType.income.name
        ? TransactionType.income
        : TransactionType.expense;
    final category = _stringFromJson(
      value['category'],
      type == TransactionType.income ? 'Thu nhập' : 'Chi phí',
    );

    return TransactionEntry(
      id: _stringFromJson(value['id'], _newId()),
      type: type,
      title: _stringFromJson(value['title'], category),
      category: category,
      amount: _doubleFromJson(value['amount']),
      date: _dateFromJson(value['date'], DateTime.now()),
      paymentMethod: _stringFromJson(value['paymentMethod'], 'Tiền mặt'),
      icon: type == TransactionType.income
          ? _incomeIcon(category)
          : _expenseIcon(category),
    );
  }

  List<TransactionEntry>? _transactionsFromJson(Object? value) {
    if (value is! List) return null;
    final items = <TransactionEntry>[];
    for (final item in value) {
      final transaction = _transactionFromJson(item);
      if (transaction != null) items.add(transaction);
    }
    return items;
  }

  Map<String, dynamic> _goalToJson(SavingsGoal goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount,
      'deadline': goal.deadline.toIso8601String(),
      'frequency': goal.frequency,
    };
  }

  SavingsGoal? _goalFromJson(Object? value) {
    if (value is! Map) return null;
    final title = _stringFromJson(value['title'], '').trim();
    if (title.isEmpty) return null;

    return SavingsGoal(
      id: _stringFromJson(value['id'], _newId()),
      title: title,
      targetAmount: _doubleFromJson(value['targetAmount']),
      currentAmount: _doubleFromJson(value['currentAmount']),
      deadline: _dateFromJson(value['deadline'], DateTime.now()),
      frequency: _stringFromJson(value['frequency'], 'Hàng tháng'),
      icon: _goalIcon(title),
    );
  }

  List<SavingsGoal>? _goalsFromJson(Object? value) {
    if (value is! List) return null;
    final items = <SavingsGoal>[];
    for (final item in value) {
      final goal = _goalFromJson(item);
      if (goal != null) items.add(goal);
    }
    return items;
  }

  Map<String, dynamic> _reminderToJson(ReminderEntry reminder) {
    return {
      'id': reminder.id,
      'title': reminder.title,
      'amount': reminder.amount,
      'reminderDate': reminder.reminderDate.toIso8601String(),
      'dueDate': reminder.dueDate.toIso8601String(),
      'frequency': reminder.frequency,
    };
  }

  ReminderEntry? _reminderFromJson(Object? value) {
    if (value is! Map) return null;
    final title = _stringFromJson(value['title'], '').trim();
    if (title.isEmpty) return null;

    return ReminderEntry(
      id: _stringFromJson(value['id'], _newId()),
      title: title,
      amount: _doubleFromJson(value['amount']),
      reminderDate: _dateFromJson(value['reminderDate'], DateTime.now()),
      dueDate: _dateFromJson(value['dueDate'], DateTime.now()),
      frequency: _stringFromJson(value['frequency'], 'Không lặp lại'),
    );
  }

  List<ReminderEntry>? _remindersFromJson(Object? value) {
    if (value is! List) return null;
    final items = <ReminderEntry>[];
    for (final item in value) {
      final reminder = _reminderFromJson(item);
      if (reminder != null) items.add(reminder);
    }
    return items;
  }

  List<String>? _stringListFromJson(Object? value) {
    if (value is! List) return null;
    final items = value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return items.isEmpty ? null : items;
  }

  Map<String, double>? _budgetLimitsFromJson(Object? value) {
    if (value is! Map) return null;
    final limits = <String, double>{};
    for (final entry in value.entries) {
      final category = entry.key.toString().trim();
      if (category.isEmpty) continue;
      limits[category] = _doubleFromJson(entry.value);
    }
    return limits.isEmpty ? null : limits;
  }

  String _stringFromJson(Object? value, String fallback) {
    if (value is String) return value;
    return value?.toString() ?? fallback;
  }

  double _doubleFromJson(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  DateTime _dateFromJson(Object? value, DateTime fallback) {
    if (value is String) return DateTime.tryParse(value) ?? fallback;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return fallback;
  }

  void _resetToDemoAccount() {
    _accounts.clear();
    _ledgers.clear();
    _currentAccount = null;
    _displayName = 'Minh';
    _seedDemoAccount();
  }

  void _seedDemoAccount() {
    const demo = UserAccount(
      username: 'minh',
      email: 'minh@monex.vn',
      password: '123456',
    );
    _accounts.add(demo);
    _currentAccount = demo;
    _displayName = demo.username;

    final ledger = _AccountLedger();
    _ledgers[_accountKey(demo)] = ledger;
    _ledgers[_guestKey] = _AccountLedger();

    _addSeedIncome(
      ledger,
      title: 'Lương công ty',
      amount: 3200,
      category: 'Lương',
      date: DateTime.now().subtract(const Duration(days: 3)),
    );
    _addSeedIncome(
      ledger,
      title: 'Dự án Freelance',
      amount: 500,
      category: 'Freelance',
      date: DateTime.now().subtract(const Duration(days: 2)),
    );
    _addSeedExpense(
      ledger,
      title: 'Ăn trưa',
      amount: 125,
      category: 'Ăn uống',
      date: DateTime.now().subtract(const Duration(days: 1)),
    );
    _addSeedExpense(
      ledger,
      title: 'Mua sắm',
      amount: 250,
      category: 'Mua sắm',
      date: DateTime.now().subtract(const Duration(hours: 6)),
    );
    ledger.goals.addAll([
      SavingsGoal(
        id: _newId(),
        title: 'Xe máy mới',
        targetAmount: 600,
        currentAmount: 300,
        deadline: DateTime.now().add(const Duration(days: 90)),
        frequency: 'Hàng tháng',
        icon: Icons.motorcycle_outlined,
      ),
      SavingsGoal(
        id: _newId(),
        title: 'iPhone 15 Pro',
        targetAmount: 1000,
        currentAmount: 700,
        deadline: DateTime.now().add(const Duration(days: 120)),
        frequency: 'Hàng tháng',
        icon: Icons.phone_iphone_outlined,
      ),
    ]);
    ledger.reminders.addAll([
      ReminderEntry(
        id: _newId(),
        title: 'Thanh toán hóa đơn',
        amount: 200,
        reminderDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        frequency: 'Hàng tháng',
      ),
      ReminderEntry(
        id: _newId(),
        title: 'Vay mua xe',
        amount: 600,
        reminderDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 20)),
        frequency: 'Hàng tháng',
      ),
    ]);
  }

  void _addSeedIncome(
    _AccountLedger ledger, {
    required String title,
    required double amount,
    required String category,
    required DateTime date,
  }) {
    ledger.transactions.add(
      TransactionEntry(
        id: _newId(),
        type: TransactionType.income,
        title: title,
        category: category,
        amount: amount,
        date: date,
        paymentMethod: 'Tiền mặt',
        icon: _incomeIcon(category),
      ),
    );
  }

  void _addSeedExpense(
    _AccountLedger ledger, {
    required String title,
    required double amount,
    required String category,
    required DateTime date,
  }) {
    ledger.transactions.add(
      TransactionEntry(
        id: _newId(),
        type: TransactionType.expense,
        title: title,
        category: category,
        amount: amount,
        date: date,
        paymentMethod: 'Tiền mặt',
        icon: _expenseIcon(category),
      ),
    );
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  void _ensureCategory(List<String> categories, String category) {
    if (!categories.any(
      (item) => item.toLowerCase() == category.toLowerCase(),
    )) {
      categories.add(category);
    }
  }

  IconData _incomeIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('lương')) return Icons.work_outline;
    if (lower.contains('thưởng')) return Icons.card_giftcard_outlined;
    return Icons.account_balance_wallet_outlined;
  }

  IconData _expenseIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('ăn')) return Icons.fastfood_outlined;
    if (lower.contains('giao')) return Icons.directions_bus_outlined;
    if (lower.contains('mua')) return Icons.shopping_bag_outlined;
    if (lower.contains('hóa')) return Icons.receipt_long_outlined;
    return Icons.payments_outlined;
  }

  IconData _goalIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('xe')) return Icons.directions_car_filled_outlined;
    if (lower.contains('nhà')) return Icons.home_work_outlined;
    if (lower.contains('iphone') || lower.contains('điện thoại')) {
      return Icons.phone_iphone_outlined;
    }
    if (lower.contains('du lịch')) return Icons.flight_takeoff;
    return Icons.savings_outlined;
  }

  Color _budgetColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('ăn')) return const Color(0xFFE45D4F);
    if (lower.contains('mua')) return const Color(0xFFE5A935);
    if (lower.contains('giao')) return const Color(0xFF4A65D9);
    return const Color(0xFF146C63);
  }
}

final MonexAppState appState = MonexAppState();

double? parseMoney(String value) {
  final normalized = value
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^0-9.]'), '');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String money(double value) {
  final formatter = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: value % 1 == 0 ? 0 : 2,
  );
  return formatter.format(value);
}

String shortDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}
