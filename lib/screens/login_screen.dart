import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _bgColor = Color(0xFF0D1117);
const _surfaceColor = Color(0xFF161B22);
const _primaryColor = Color(0xFF4A90D9);
const _borderColor = Color(0xFF30363D);
const _errorColor = Color(0xFFF85149);
const _textSecondary = Color(0xFF8B949E);

final _isLoginModeProvider = StateProvider<bool>((ref) => true);
final _emailProvider = StateProvider<String>((ref) => '');
final _codeProvider = StateProvider<String>((ref) => '');
final _usernameProvider = StateProvider<String>((ref) => '');
final _passwordProvider = StateProvider<String>((ref) => '');
final _confirmPasswordProvider = StateProvider<String>((ref) => '');
final _errorProvider = StateProvider<String?>((ref) => null);
final _sendingCodeProvider = StateProvider<bool>((ref) => false);
final _countdownProvider = StateProvider<int>((ref) => 0);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isLogin = ref.watch(_isLoginModeProvider);
    final error = ref.watch(_errorProvider);
    final sendingCode = ref.watch(_sendingCodeProvider);
    final countdown = ref.watch(_countdownProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/login_illustration.png',
                    height: 120,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.chat_bubble_outline,
                          size: 48, color: _primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '匿匿',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '隐私优先的去中心化通讯',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _textSecondary,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Error
                  if (error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _errorColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(error,
                          style: const TextStyle(
                              color: _errorColor, fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!isLogin) ...[
                    // Email
                    _buildInput(
                      label: '邮箱',
                      hint: '请输入邮箱地址',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) =>
                          ref.read(_emailProvider.notifier).state = v,
                    ),
                    const SizedBox(height: 16),

                    // Send Code
                    Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            label: '验证码',
                            hint: '6位验证码',
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            onChanged: (v) =>
                                ref.read(_codeProvider.notifier).state = v,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: sendingCode || countdown > 0
                                ? null
                                : () => _sendCode(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _surfaceColor,
                              foregroundColor: _primaryColor,
                              side: const BorderSide(color: _borderColor),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(
                              countdown > 0 ? '${countdown}s' : '发送验证码',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Username
                    _buildInput(
                      label: '用户名',
                      hint: '请输入用户名',
                      onChanged: (v) =>
                          ref.read(_usernameProvider.notifier).state = v,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (isLogin) ...[
                    // Username (login)
                    _buildInput(
                      label: '用户名',
                      hint: '请输入用户名',
                      onChanged: (v) =>
                          ref.read(_usernameProvider.notifier).state = v,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Password
                  _buildInput(
                    label: '密码',
                    hint: '请输入密码',
                    obscure: true,
                    onChanged: (v) =>
                        ref.read(_passwordProvider.notifier).state = v,
                  ),
                  const SizedBox(height: 16),

                  if (!isLogin) ...[
                    // Confirm Password
                    _buildInput(
                      label: '确认密码',
                      hint: '请再次输入密码',
                      obscure: true,
                      onChanged: (v) =>
                          ref.read(_confirmPasswordProvider.notifier).state = v,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isLogin ? '登录' : '注册',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle
                  TextButton(
                    onPressed: () {
                      ref.read(_isLoginModeProvider.notifier).state = !isLogin;
                      ref.read(_errorProvider.notifier).state = null;
                    },
                    child: Text(
                      isLogin ? '没有账号？立即注册' : '已有账号？立即登录',
                      style: const TextStyle(color: _primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged,
          maxLength: maxLength,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _textSecondary, fontSize: 14),
            filled: true,
            fillColor: _surfaceColor,
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  void _sendCode() {
    final email = ref.read(_emailProvider);
    if (email.isEmpty || !email.contains('@')) {
      ref.read(_errorProvider.notifier).state = '请输入有效的邮箱地址';
      return;
    }
    ref.read(_sendingCodeProvider.notifier).state = true;
    ref.read(_errorProvider.notifier).state = null;
    // TODO: 接入邮箱发送验证码 API
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ref.read(_sendingCodeProvider.notifier).state = false;
        ref.read(_countdownProvider.notifier).state = 60;
        _startCountdown();
      }
    });
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      final current = ref.read(_countdownProvider);
      if (current <= 1) {
        ref.read(_countdownProvider.notifier).state = 0;
        return false;
      }
      ref.read(_countdownProvider.notifier).state = current - 1;
      return true;
    });
  }

  void _submit() {
    ref.read(_errorProvider.notifier).state = null;
    final isLogin = ref.read(_isLoginModeProvider);
    final username = ref.read(_usernameProvider);
    final password = ref.read(_passwordProvider);

    if (username.isEmpty || password.isEmpty) {
      ref.read(_errorProvider.notifier).state = '请填写所有必填字段';
      return;
    }

    if (!isLogin) {
      final confirm = ref.read(_confirmPasswordProvider);
      if (password != confirm) {
        ref.read(_errorProvider.notifier).state = '两次输入的密码不一致';
        return;
      }
      if (password.length < 6) {
        ref.read(_errorProvider.notifier).state = '密码长度至少6位';
        return;
      }
    }

    // TODO: 接入登录/注册逻辑
  }
}
