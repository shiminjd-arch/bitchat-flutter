import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../config/api_keys.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _dio = Dio(BaseOptions(
    baseUrl: 'https://api.resend.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  Future<void> sendVerificationCode(String email) async {
    final apiKey = await ApiKeys.getResendApiKey();
    if (apiKey.isEmpty) throw Exception('Resend API Key 未配置');

    final code = _generateCode();
    final hashedCode = sha256.convert(utf8.encode(code)).toString();

    await _dio.post(
      '/emails',
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      }),
      data: {
        'from': '匿匿 <noreply@bitchat.app>',
        'to': [email],
        'subject': '匿匿 验证码',
        'html': '''
          <div style="font-family:sans-serif;text-align:center;padding:40px">
            <h2>你的验证码</h2>
            <p style="font-size:32px;letter-spacing:8px;font-weight:bold;color:#4A90D9">$code</p>
            <p style="color:#888">验证码 10 分钟内有效，请勿泄露</p>
          </div>
        ''',
      },
    );
  }

  Future<String> login(String email, String code) async {
    // TODO: 验证 code 后生成/返回本地密钥对的公钥作为 user ID
    _currentUserId = _generateUserId(email);
    return _currentUserId!;
  }

  Future<String> register(String email) async {
    // TODO: 创建新账户，返回 user ID
    _currentUserId = _generateUserId(email);
    return _currentUserId!;
  }

  Future<void> logout() async {
    _currentUserId = null;
  }

  String _generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  String _generateUserId(String email) {
    final bytes = sha256.convert(utf8.encode('$email${DateTime.now().millisecondsSinceEpoch}'));
    return bytes.toString().substring(0, 32);
  }
}
