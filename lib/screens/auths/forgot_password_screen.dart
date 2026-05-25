// lib/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:monex/screens/auths/update_success_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controller để lắng nghe thay đổi trong ô nhập mật khẩu
  final TextEditingController _passwordController = TextEditingController();

  // Trạng thái cho các ô nhập mật khẩu
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // Trạng thái cho các tiêu chí mật khẩu
  bool _hasMin8Chars = false;
  bool _hasSymbolOrNumber = false;
  // Giả sử chúng ta có tên người dùng và email
  final String _username = "fisher";
  final String _email = "fisher@example.com";
  bool _doesNotContainNameOrEmail = false;

  @override
  void initState() {
    super.initState();
    // Thêm listener để cập nhật UI mỗi khi người dùng gõ
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMin8Chars = password.length >= 8;

      // Kiểm tra có ký tự đặc biệt hoặc số
      final symbolOrNumberRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>0-9]');
      _hasSymbolOrNumber = symbolOrNumberRegex.hasMatch(password);

      // Kiểm tra không chứa tên hoặc email
      if (password.isNotEmpty) {
        _doesNotContainNameOrEmail =
            !password.toLowerCase().contains(_username.toLowerCase()) &&
            !password.toLowerCase().contains(_email.toLowerCase());
      } else {
        _doesNotContainNameOrEmail = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Tiêu đề
                const Text(
                  'Tạo mật khẩu mới',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E232C),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mật khẩu mới của bạn phải khác với mật khẩu trước đó.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Ô nhập mật khẩu mới
                TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  decoration: InputDecoration(
                    hintText: '@fisher123|',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Ô xác nhận mật khẩu
                TextField(
                  obscureText: _isConfirmPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordObscured =
                              !_isConfirmPasswordObscured;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Các tiêu chí mật khẩu
                _buildValidationRow(
                  text: 'Không được chứa tên hoặc email của bạn',
                  isValid: _doesNotContainNameOrEmail,
                ),
                const SizedBox(height: 15),
                _buildValidationRow(
                  text: 'Ít nhất 8 ký tự',
                  isValid: _hasMin8Chars,
                ),
                const SizedBox(height: 15),
                _buildValidationRow(
                  text: 'Chứa ký tự đặc biệt hoặc số',
                  isValid: _hasSymbolOrNumber,
                ),
                const SizedBox(height: 50),

                // Nút Reset Password
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.lightBlueAccent],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpdateSuccessScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'ĐẶT LẠI MẬT KHẨU',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  // Widget con để hiển thị một dòng tiêu chí
  Widget _buildValidationRow({required String text, required bool isValid}) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.check_circle_outline,
          color: isValid ? Colors.blue : Colors.grey,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.blue : Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
