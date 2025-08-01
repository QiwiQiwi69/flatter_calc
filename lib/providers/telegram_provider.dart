import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'dart:js' as js;

class TelegramProvider with ChangeNotifier {
  TelegramUser? _user;
  bool _isLoading = false;
  String? _error;

  TelegramUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Инициализация WebApp Telegram
  Future<void> initTelegramWebApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Проверяем, запущено ли приложение в Telegram WebView
      final bool isWebView = await _checkWebView();
      
      if (isWebView) {
        // Получаем данные пользователя из Telegram
        await _getUserData();
      } else {
        _error = 'Приложение должно быть запущено в Telegram';
      }
    } catch (e) {
      _error = 'Ошибка инициализации: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _checkWebView() async {
    // Проверяем наличие объекта Telegram WebApp
    try {
      final String isWebView = await _executeJavaScript('window.Telegram.WebApp.initData ? true : false');
      print("Raw result: =$isWebView"); // Выведет "=true" или "=false"

      final bool test = isWebView.toLowerCase() == 'true';
      print("Boolean value: $test");
      return test;
    } catch (e) {
      return false;
    }
  }

  Future<void> _getUserData() async {
    try {
      // Получаем initData от Telegram WebApp
      final String initData = await _executeJavaScript('window.Telegram.WebApp.initData');
      
      if (initData.isNotEmpty) {
        final Map<String, String> params = Uri.splitQueryString(initData);
        final userJson = jsonDecode(params['user'] ?? '{}');
        _user = TelegramUser.fromJson(userJson);
      }
    } catch (e) {
      throw Exception('Не удалось получить данные пользователя');
    }
  }

  Future<String> _executeJavaScript(String script) async {
    // Для web используем js-интероп, для мобильных платформ - webview_flutter
    // Это упрощенная реализация, в реальном приложении нужно адаптировать под платформы
    return _executeJavaScriptWeb(script);
  }

Future<String> _executeJavaScriptWeb(String script) async {
  try {
    // Используем dart:js для выполнения на вебе
    final result = js.context.callMethod('eval', [script]);
    return result.toString();
  } catch (e) {
    print('JS Error: $e');
    return 'false';
  }
}


  // Отправка сообщения через бота
  Future<void> sendMessage(String text, String botToken) async {
    if (_user == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://api.telegram.org/bot$botToken/sendMessage'),
        body: {
          'chat_id': _user!.id,
          'text': text,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка отправки сообщения');
      }
    } catch (e) {
      throw Exception('Ошибка отправки: ${e.toString()}');
    }
  }
}