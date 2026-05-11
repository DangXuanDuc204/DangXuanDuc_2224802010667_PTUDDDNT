import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import 'add_edit_todo_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTodos());
  }

  Future<void> _loadTodos() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      await context.read<TodoProvider>().fetchTodos(token);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  Future<void> _logout() async {
    context.read<TodoProvider>().clear();
    await context.read<AuthProvider>().logout();
  }

  Future<void> _toggle(Todo todo) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      await context.read<TodoProvider>().toggleTodo(token: token, todo: todo);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  Future<void> _delete(Todo todo) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    try {
      await context.read<TodoProvider>().deleteTodo(token: token, todo: todo);
      if (mounted) _showMessage('Đã xóa công việc');
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openEditor([Todo? todo]) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddEditTodoScreen(todo: todo)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final todoProvider = context.watch<TodoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Công việc của tôi'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: _loadTodos,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTodos,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          children: [
            _SummaryHeader(
              name: auth.user?.fullName ?? '',
              total: todoProvider.todos.length,
              done: todoProvider.doneCount,
              pending: todoProvider.pendingCount,
            ),
            const SizedBox(height: 18),
            if (todoProvider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (todoProvider.todos.isEmpty)
              const _EmptyState()
            else
              ...todoProvider.todos.map(
                (todo) => _TodoItem(
                  todo: todo,
                  onToggle: () => _toggle(todo),
                  onEdit: () => _openEditor(todo),
                  onDelete: () => _delete(todo),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm'),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.name,
    required this.total,
    required this.done,
    required this.pending,
  });

  final String name;
  final int total;
  final int done;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, $name',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hôm nay mình xử lý từng việc một cách gọn gàng nhé.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatChip(label: 'Tổng', value: total),
              const SizedBox(width: 10),
              _StatChip(label: 'Xong', value: done),
              const SizedBox(width: 10),
              _StatChip(label: 'Còn lại', value: pending),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _TodoItem extends StatelessWidget {
  const _TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Checkbox(value: todo.isDone, onChanged: (_) => onToggle()),
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.black45 : Colors.black87,
          ),
        ),
        subtitle: todo.description.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(todo.description),
              ),
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              tooltip: 'Sửa',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Xóa',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 72,
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có công việc',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text('Nhấn nút Thêm để tạo công việc đầu tiên.'),
        ],
      ),
    );
  }
}
