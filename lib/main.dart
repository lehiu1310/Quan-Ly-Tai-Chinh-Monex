// lib/main.dart

import 'package:flutter/material.dart';
import 'package:monex/data/app_preferences.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/onboarding/onboarding_screen.dart';
import 'package:monex/services/home_widget_service.dart';
import 'package:monex/services/notification_service.dart';

import 'screens/auths/login_screen.dart'; // <-- Import màn hình đăng nhập từ file mới
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appPreferences.load();
  await appState.load();
  await notificationService.init();
  appState.addListener(() {
    homeWidgetService.update(appState);
  });
  await homeWidgetService.update(appState);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appPreferences,
      builder: (context, _) {
        return MaterialApp(
          title: 'Monex',
          theme: MonexTheme.light(),
          darkTheme: MonexTheme.dark(),
          themeMode: appPreferences.themeMode,
          home: appPreferences.hasSeenOnboarding
              ? const LoginScreen()
              : const OnboardingScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
