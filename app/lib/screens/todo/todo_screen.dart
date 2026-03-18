import 'package:flutter/material.dart';
import '../../services/todo_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> _todos = [];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await TodoService.getTodos();
    setState(() => _todos = todos);
  }

  Future<void> _addTodo() async {
    if (_controller.text.isEmpty) return;
    await TodoService.addTodo(_controller.text);
    _controller.clear();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('待办事项')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '添加待办...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTodo,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo['completed'],
                    onChanged: (_) async {
                      await TodoService.completeTodo(todo['id']);
                      _loadTodos();
                    },
                  ),
                  title: Text(
                    todo['title'],
                    style: TextStyle(
                      decoration: todo['completed']
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await TodoService.deleteTodo(todo['id']);
                      _loadTodos();
                    },
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
