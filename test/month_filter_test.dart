import 'package:flutter_test/flutter_test.dart';
import 'package:monex/data/app_state.dart';

void main() {
  test('monthly totals only include transactions from the selected month', () {
    final state = MonexAppState();

    final registered = state.register(
      username: 'month_filter_user',
      email: 'month_filter_user@monex.test',
      password: '123456',
    );
    expect(registered, isTrue);

    state.addExpense(
      title: 'Khoan chi thang 4',
      amount: 100000,
      category: 'Mua sam',
      date: DateTime(2026, 4, 15),
    );
    state.addExpense(
      title: 'Khoan chi thang 5',
      amount: 25000,
      category: 'Mua sam',
      date: DateTime(2026, 5, 3),
    );
    state.addIncome(
      title: 'Thu nhap thang 5',
      amount: 50000,
      category: 'Luong',
      date: DateTime(2026, 5, 1),
    );

    expect(state.expenseTotalForMonth(DateTime(2026, 4)), 100000);
    expect(state.expenseTotalForMonth(DateTime(2026, 5)), 25000);
    expect(state.incomeTotalForMonth(DateTime(2026, 5)), 50000);
    expect(state.balanceForMonth(DateTime(2026, 5)), 25000);

    final mayBudget = state
        .budgetsForMonth(DateTime(2026, 5))
        .singleWhere((budget) => budget.category == 'Mua sam');
    expect(mayBudget.spent, 25000);
  });
}
