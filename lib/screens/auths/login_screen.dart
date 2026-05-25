// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:monex/data/app_state.dart';
import 'package:monex/screens/auths/forgot_password_screen.dart';
import 'package:monex/screens/auths/register_screen.dart';
import 'package:monex/screens/home_page.dart';
import 'package:monex/theme/app_theme.dart';
import 'package:monex/theme/monex_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    final loggedIn = appState.login(
      identity: _usernameController.text,
      password: _passwordController.text,
    );

    if (!loggedIn) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tài khoản hoặc mật khẩu chưa đúng'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _quickLogin(String label) {
    appState.useGuestAccount();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label đã sẵn sàng ở bản demo'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MonexColors.background,
      body: MonexBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrandPanel(),
                          const SizedBox(height: 24),
                          const Text(
                            'Chào mừng trở lại',
                            style: TextStyle(
                              color: MonexColors.ink,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Đăng nhập vào tài khoản Monex của bạn',
                            style: TextStyle(
                              color: MonexColors.muted,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _buildInput(
                            controller: _usernameController,
                            hint: 'Tên đăng nhập hoặc email',
                            icon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tài khoản';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildInput(
                            controller: _passwordController,
                            hint: 'Mật khẩu',
                            icon: Icons.lock_outline,
                            obscureText: _isPasswordObscured,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitLogin(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu tối thiểu 6 ký tự';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildLoginOptions(context),
                          const SizedBox(height: 8),
                          _buildPrimaryButton(),
                          const SizedBox(height: 14),
                          _buildQuickLoginActions(),
                          const SizedBox(height: 22),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: MonexColors.line)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'Hoặc',
                                  style: TextStyle(color: MonexColors.muted),
                                ),
                              ),
                              Expanded(child: Divider(color: MonexColors.line)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildSocialButton(
                            asset: 'lib/assets/images/google_logo.png',
                            label: 'Tiếp tục với Google',
                          ),
                          const SizedBox(height: 12),
                          _buildSocialButton(
                            asset: 'lib/assets/images/apple_logo.png',
                            label: 'Tiếp tục với Apple',
                          ),
                          const SizedBox(height: 24),
                          _buildRegisterLink(context),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: MonexTheme.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: MonexTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'monex',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Quản lý thu nhập, chi tiêu, mục tiêu và lời nhắc theo từng tài khoản.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _LoginFeatureChip(
                icon: Icons.lock_outline,
                label: 'Dữ liệu riêng',
              ),
              _LoginFeatureChip(
                icon: Icons.savings_outlined,
                label: 'Tiết kiệm',
              ),
              _LoginFeatureChip(
                icon: Icons.notifications_active_outlined,
                label: 'Lời nhắc',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: MonexColors.muted),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildLoginOptions(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          activeColor: MonexColors.primary,
          visualDensity: VisualDensity.compact,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? true;
            });
          },
        ),
        const Expanded(
          child: Text(
            'Ghi nhớ đăng nhập',
            style: TextStyle(
              color: MonexColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgotPasswordScreen(),
              ),
            );
          },
          child: const Text('Quên mật khẩu?'),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: MonexTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: MonexTheme.softShadow,
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Đăng nhập'),
      ),
    );
  }

  Widget _buildQuickLoginActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.fingerprint,
            label: 'Vân tay',
            onTap: () => _quickLogin('Đăng nhập vân tay'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.person_pin_circle_outlined,
            label: 'Chế độ khách',
            onTap: () => _quickLogin('Chế độ khách'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: FittedBox(child: Text(label)),
      style: OutlinedButton.styleFrom(
        foregroundColor: MonexColors.primary,
        backgroundColor: MonexColors.surface,
        side: const BorderSide(color: MonexColors.line),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildSocialButton({required String asset, required String label}) {
    return OutlinedButton.icon(
      onPressed: () {
        appState.useGuestAccount();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      icon: Image.asset(asset, height: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: MonexColors.ink,
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: Colors.white,
        side: const BorderSide(color: MonexColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chưa có tài khoản? ',
          style: TextStyle(color: MonexColors.muted),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text(
            'Đăng ký',
            style: TextStyle(
              color: MonexColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginFeatureChip extends StatelessWidget {
  const _LoginFeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
