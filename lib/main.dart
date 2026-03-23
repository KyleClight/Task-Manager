import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp()); // Запуск древа FlutterUI
}

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Task Manager", home: const TaskPage());
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  // controller, который управляет TextField (TextInput). Внутри него имеются методы, позволяющие читать, изменять и записывать информацию
  TextEditingController controller = TextEditingController();
  List<Task> tasks = []; // Общий пул задач, которые попадают туда через $TextField

  @override
  void initState() {
    // Состояние, вызываемое при первой компиляции приложения
    super.initState();
    // loadTasks();
  }
  
  // Future<void> loadTasks() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final loadedTasks = prefs.getStringList('tasks') ?? [];
  //   tasks = loadedTasks;
  //   setState(() {
  //     tasks = loadedTasks;
  //   });
  // }

  // Future<void> _saveTasks() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setStringList('tasks', tasks);
  // }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    // _saveTasks();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              // child: какой виджет должен находиться внутри штор
              padding: EdgeInsetsGeometry.all(0),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'Enter your task'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    setState(() {
                      tasks.add(Task(title: controller.text));
                      controller.clear();
                    });
                    // _saveTasks();
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              // "Займи всё оставшееся место на экране". Без Height
              children: tasks.asMap().entries.map((entry) {
                // asMap - получение пары key: Value;
                int index = entry.key;
                String task = entry.value.title;
                bool isDone = entry.value.isDone;
                
                return ListTile(
                  leading: Checkbox(value: isDone, onChanged: (bool? newValue) {
                    setState(() {
                      tasks[index].isDone = newValue ?? false;
                    });
                  }),
                  title: Text(
                    task,
                    style: TextStyle(
                      color: isDone ? Colors.grey : const Color.fromARGB(255, 11, 11, 11),
                      decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    )
                  ),
                  trailing: IconButton(onPressed: () => _deleteTask(index),
                  icon: Icon(Icons.delete, color: Colors.redAccent)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
