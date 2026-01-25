import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

enum TaskFilter { all, active, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  final TextEditingController taskController = TextEditingController();

  TaskFilter currentFilter = TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  // ===== COUNTS & PROGRESS =====
  int get totalCount => tasks.length;
  int get doneCount => tasks.where((t) => t.isCompleted).length;

  double get progress {
    if (totalCount == 0) return 0;
    return doneCount / totalCount;
  }

  // ===== FILTER + SORT =====
  List<Task> get filteredTasks {
    switch (currentFilter) {
      case TaskFilter.active:
        return tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.all:
      default:
        return tasks;
    }
  }

  List<Task> get sortedTasks {
    final pending =
    filteredTasks.where((t) => !t.isCompleted).toList();
    final done =
    filteredTasks.where((t) => t.isCompleted).toList();
    return [...pending, ...done];
  }

  // ===== STORAGE =====
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList('tasks', list);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('tasks');
    if (list != null) {
      setState(() {
        tasks
          ..clear()
          ..addAll(list.map((e) => Task.fromMap(jsonDecode(e))));
      });
    }
  }

  // ===== ADD TASK =====
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: taskController,
          decoration:
          const InputDecoration(hintText: 'Enter task name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                setState(() {
                  tasks.add(Task(title: taskController.text));
                });
                _saveTasks();
                taskController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // ===== DATE FORMAT =====
  String _formatDate(DateTime date) {
    final time = TimeOfDay.fromDateTime(date).format(context);
    return '${date.day}/${date.month}/${date.year} • $time';
  }

  // ===== FILTER CHIPS =====
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: currentFilter == TaskFilter.all,
            onSelected: (_) =>
                setState(() => currentFilter = TaskFilter.all),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Pending'),
            selected: currentFilter == TaskFilter.active,
            onSelected: (_) =>
                setState(() => currentFilter = TaskFilter.active),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Done'),
            selected: currentFilter == TaskFilter.completed,
            onSelected: (_) =>
                setState(() => currentFilter = TaskFilter.completed),
          ),
        ],
      ),
    );
  }

  // ===== PROGRESS BAR =====
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress ${(progress * 100).toInt()}%',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E2E2),

      // ✅ APP BAR مع LOGOUT
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (_) => false,
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          _buildProgressBar(),
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              itemCount: sortedTasks.length,
              itemBuilder: (context, index) {
                final task = sortedTasks[index];

                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    child:
                    const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      tasks.remove(task);
                    });
                    _saveTasks();
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    color: task.isCompleted
                        ? Colors.green.withOpacity(0.08)
                        : Colors.white,
                    child: ListTile(
                      leading: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.isCompleted
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? Colors.black
                              : Colors.black87,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Colors.black54,
                          decorationThickness: 1.3,
                        ),
                      ),
                      subtitle: Text(
                        _formatDate(task.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          taskController.text = task.title;
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Edit Task'),
                              content:
                              TextField(controller: taskController),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    taskController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      task.title =
                                          taskController.text;
                                    });
                                    _saveTasks();
                                    taskController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        setState(() {
                          task.isCompleted = !task.isCompleted;
                        });
                        _saveTasks();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
