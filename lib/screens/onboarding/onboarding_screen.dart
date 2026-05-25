import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:monex/data/app_preferences.dart';
import 'package:monex/screens/auths/login_screen.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _slides = const [
    _OnboardingSlide(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Theo dõi tiền rõ ràng',
      body:
          'Ghi thu nhập, chi phí, danh mục và số dư riêng cho từng tài khoản.',
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: 'Trợ lý chi tiêu',
      body: 'App tự nhìn ngân sách và nhắc khi khoản chi bắt đầu có rủi ro.',
    ),
    _OnboardingSlide(
      icon: Icons.query_stats,
      title: 'Biểu đồ & báo cáo',
      body:
          'Xem xu hướng thu chi theo tháng và xuất báo cáo PDF/Excel khi cần.',
    ),
  ];

  Future<void> _finish() async {
    await appPreferences.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonexColors.background,
      body: MonexBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text('Bỏ qua'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'monex_onboarding_logo',
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                gradient: MonexTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(36),
                                boxShadow: MonexTheme.softShadow,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Lottie.asset(
                                    'lib/assets/lottie/finance_pulse.json',
                                  ),
                                  Icon(
                                    slide.icon,
                                    color: Colors.white,
                                    size: 56,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 38),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: MonexColors.ink,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: MonexColors.muted,
                              fontSize: 16,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    final selected = index == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: selected ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected
                            ? MonexColors.primary
                            : MonexColors.line,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_index == _slides.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: Text(
                      _index == _slides.length - 1 ? 'Bắt đầu' : 'Tiếp tục',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
