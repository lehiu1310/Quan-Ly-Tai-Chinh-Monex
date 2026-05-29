import 'package:home_widget/home_widget.dart';
import 'package:monex/data/app_state.dart';

class HomeWidgetService {
  Future<void> update(MonexAppState state) async {
    await HomeWidget.saveWidgetData<String>(
      'balance',
      money(state.currentMonthBalance),
    );
    await HomeWidget.saveWidgetData<String>(
      'income',
      '+ ${money(state.currentMonthIncomeTotal)}',
    );
    await HomeWidget.saveWidgetData<String>(
      'expense',
      '- ${money(state.currentMonthExpenseTotal)}',
    );
    await HomeWidget.saveWidgetData<String>('account', state.displayName);
    await HomeWidget.updateWidget(androidName: 'MonexHomeWidgetProvider');
  }
}

final HomeWidgetService homeWidgetService = HomeWidgetService();
