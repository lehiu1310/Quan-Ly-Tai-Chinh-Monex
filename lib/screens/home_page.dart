import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/widgets/tab_navigator.dart';
import 'package:monex/services/insight_service.dart';
import 'package:monex/theme/app_theme.dart';

import 'pages/add_transaction_page.dart';
import 'pages/notification_page.dart';
import 'pages/overview_page.dart';
import 'pages/reminder_page.dart';
import 'pages/savings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  final List<Widget> _rootPages = [
    const OverviewPage(),
    const ReminderPage(),
    const NotificationPage(),
    const SavingsPage(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      _navigatorKeys[index]?.currentState?.popUntil((route) => route.isFirst);
      return;
    }

    setState(() => _selectedIndex = index);
  }

  void _switchTabBySwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null || velocity.abs() < 250) return;

    final nextIndex = velocity < 0 ? _selectedIndex + 1 : _selectedIndex - 1;
    if (nextIndex < 0 || nextIndex >= _rootPages.length) return;
    _onItemTapped(nextIndex);
  }

  Future<void> _openAddTransaction() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final currentNavigator = _navigatorKeys[_selectedIndex]!.currentState!;
        final didPopNestedRoute = await currentNavigator.maybePop();
        if (didPopNestedRoute) return;

        if (_selectedIndex != 0) {
          _onItemTapped(0);
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: _switchTabBySwipe,
          child: IndexedStack(
            index: _selectedIndex,
            children: List.generate(_rootPages.length, (index) {
              return TabNavigator(
                navigatorKey: _navigatorKeys[index]!,
                rootPage: _rootPages[index],
              );
            }),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: MonexTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: MonexColors.primary.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _openAddTransaction,
            backgroundColor: Colors.transparent,
            elevation: 0,
            tooltip: 'Thêm',
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            return BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
              elevation: 0,
              color: MonexColors.surface,
              child: Container(
                height: 76.0,
                decoration: BoxDecoration(
                  color: MonexColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: MonexColors.ink.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildNavItem(
                      activeIcon: Icons.home_rounded,
                      inactiveIcon: Icons.home_outlined,
                      label: 'Tổng quan',
                      index: 0,
                    ),
                    _buildNavItem(
                      activeIcon: Icons.calendar_month_rounded,
                      inactiveIcon: Icons.calendar_today_outlined,
                      label: 'Lời nhắc',
                      index: 1,
                      badgeCount: appState.reminders.length,
                    ),
                    const SizedBox(width: 40),
                    _buildNavItem(
                      activeIcon: Icons.notifications_rounded,
                      inactiveIcon: Icons.notifications_outlined,
                      label: 'Thông báo',
                      index: 2,
                      badgeCount: insightService
                          .buildNotifications(appState)
                          .length,
                    ),
                    _buildNavItem(
                      activeIcon: Icons.savings_rounded,
                      inactiveIcon: Icons.savings_outlined,
                      label: 'Tiết kiệm',
                      index: 3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required int index,
    int badgeCount = 0,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? MonexColors.primary : MonexColors.muted;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onItemTapped(index),
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 38 : 28,
                height: 4,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isSelected ? MonexColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      isSelected ? activeIcon : inactiveIcon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -10,
                      top: -8,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: MonexColors.expense,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1.4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
