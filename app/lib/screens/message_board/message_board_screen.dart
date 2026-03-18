import 'package:flutter/material.dart';
import '../../services/message_board_service.dart';

class MessageBoardScreen extends StatefulWidget {
  const MessageBoardScreen({super.key});

  @override
  State<MessageBoardScreen> createState() => _MessageBoardScreenState();
}

class _MessageBoardScreenState extends State<MessageBoardScreen> {
  List<Map<String, dynamic>> _messages = [];
  final _authorController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await MessageBoardService.getMessages();
    setState(() => _messages = messages);
  }

  Future<void> _addMessage() async {
    if (_authorController.text.isEmpty || _contentController.text.isEmpty) return;
    await MessageBoardService.addMessage(_authorController.text, _contentController.text);
    _authorController.clear();
    _contentController.clear();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('留言板')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: '你的名字',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '留言内容',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addMessage,
                  child: const Text('发布留言'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(msg['author']),
                    subtitle: Text(msg['content']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await MessageBoardService.deleteMessage(msg['id']);
                        _loadMessages();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
