import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeys {
  ApiKeys._();

  static const _storage = FlutterSecureStorage();

  static const _resendKey = 'api_resend';
  static const _deepseekKey = 'api_deepseek';
  static const _telegramBotTokenKey = 'api_telegram_bot_token';

  static Future<String> getResendApiKey() async {
    return await _storage.read(key: _resendKey) ?? '';
  }

  static Future<String> getDeepSeekApiKey() async {
    return await _storage.read(key: _deepseekKey) ?? '';
  }

  static Future<String> getTelegramBotToken() async {
    return await _storage.read(key: _telegramBotTokenKey) ?? '';
  }

  static Future<void> saveResendApiKey(String key) async {
    await _storage.write(key: _resendKey, value: key);
  }

  static Future<void> saveDeepSeekApiKey(String key) async {
    await _storage.write(key: _deepseekKey, value: key);
  }

  static Future<void> saveTelegramBotToken(String token) async {
    await _storage.write(key: _telegramBotTokenKey, value: token);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
