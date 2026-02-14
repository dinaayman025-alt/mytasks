import 'package:flutter/material.dart';
import 'package:mytask/feature/auth/presentation/ui/login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController taskController = TextEditingController();

  List<Map<String, dynamic>> tasks = [
    {"title": "Review today’s lecture", "done": false},
    {"title": "Complete assignments", "done": false},
    {"title": "Drink enough water", "done": false},
    {"title": "Exercise for 30 minutes", "done": false},
    {"title": "Read 10 pages of a book", "done": false},
    {"title": "Clean personal workspace", "done": false},
    {"title": "Clean room", "done": false},
  ];

  void addTask() {
    if (taskController.text.trim().isEmpty) return;

    setState(() {
      tasks.add({
        "title": taskController.text.trim(),
        "done": false,
      });
    });

    taskController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          },
        ),
        title: const Text(
          "My Tasks",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  task["done"] = !task["done"];
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: task["done"],
                      activeColor: const Color(0xFF1565C0),
                      onChanged: (value) {
                        setState(() {
                          task["done"] = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        task["title"],
                        maxLines: null,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: task["done"]
                              ? Colors.grey
                              : Colors.black87,
                          decoration: task["done"]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationThickness: 3, // 👈 بس ده اللي اتغير
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          tasks.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Add New Task",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        hintText: "Enter task",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF1565C0),
                        ),
                        onPressed: addTask,
                        child: const Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
