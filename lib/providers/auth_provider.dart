import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, unauthenticated, loading, authenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.email,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  final _authService = AuthService.instance;

  Future<void> sendCode(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authService.sendVerificationCode(email);
      state = state.copyWith(status: AuthStatus.unauthenticated, email: email);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: '发送验证码失败: $e',
      );
    }
  }

  Future<void> login(String email, String code) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final userId = await _authService.login(email, code);
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: userId,
        email: email,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: '登录失败: $e',
      );
    }
  }

  Future<void> register(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final userId = await _authService.register(email);
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: userId,
        email: email,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: '注册失败: $e',
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
