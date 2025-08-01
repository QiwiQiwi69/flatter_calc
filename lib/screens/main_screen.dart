import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/telegram_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _messageController = TextEditingController();
  late TelegramProvider _telegramProvider;

  @override
  void initState() {
    super.initState();
    _telegramProvider = Provider.of<TelegramProvider>(context, listen: false);
    _telegramProvider.initTelegramWebApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Mini App'),
        backgroundColor: const Color(0xFF3390EC),
      ),
      body: Consumer<TelegramProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.user == null) {
            return const Center(child: Text('Пользователь не авторизован'));
          }

          final user = provider.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.photoUrl != null)
                  Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl!),
                      radius: 50,
                    ),
                  ),
                const SizedBox(height: 20),
                Text('ID: ${user.id}'),
                Text('Имя: ${user.firstName}'),
                if (user.lastName != null) Text('Фамилия: ${user.lastName}'),
                if (user.username != null) Text('@${user.username}'),
                const SizedBox(height: 30),
                const Text(
                  'Отправить сообщение через бота:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Сообщение',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3390EC),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    if (_messageController.text.isEmpty) return;
                    
                    try {
                      await provider.sendMessage(
                        _messageController.text,
                        'YOUR_BOT_TOKEN', // Замените на реальный токен бота
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сообщение отправлено')),
                      );
                      _messageController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка: ${e.toString()}')),
                      );
                    }
                  },
                  child: const Text('Отправить'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3390EC),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    // Закрыть WebApp
                    _closeWebApp();
                  },
                  child: const Text('Закрыть приложение'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _closeWebApp() {
    // Вызов метода закрытия WebApp Telegram
    // В реальном приложении нужно использовать platform-specific код или js-интероп
    Navigator.of(context).pop();
  }
}