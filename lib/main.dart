import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // jsonEncode(map); jsonDecode(String)

void main() {
  runApp(const TaskManagerApp()); // Запуск древа FlutterUI
}

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
  
  Map<String, dynamic> toMap() { // Map<keyType, valueType> name() =>
    return {
      'title': title,
      'isDone': isDone
    };
  }

  factory Task.fromMap(Map<String, dynamic> map){ 
    return Task(
      title: map['title'], 
      isDone: map['isDone']);
  }
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Task Manager",
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 221, 182, 255),
        primarySwatch: Colors.deepPurple, // Поле для дефолтного цвета приложения
      ),
      home: const TaskPage()
    );      
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
    loadTasks();
  }
  
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawData = prefs.getStringList('tasks') ?? [];
    setState(() {
      tasks = rawData.map((item) {
        Map<String, dynamic> map = jsonDecode(item); // Превращает из JSON в Map<String, dynamic>
        return Task.fromMap(map);
      }).toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stringTasks = tasks.map((task) {
      final String data = json.encode(task.toMap());
      return data;
    }).toList();

    await prefs.setStringList('tasks', stringTasks);
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
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
                      tasks.add(Task(title: controller.text, isDone: false));
                      controller.clear();
                    });
                    _saveTasks();
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
                    _saveTasks();
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