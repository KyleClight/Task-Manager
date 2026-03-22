import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); // Запуск древа FlutterUI
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Task Manager",
      home: const TaskPage(),
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
  List<String> tasks = []; // Общий пул задач, которые попадают туда через $TextField
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SafeArea(child: Padding( // child: какой виджет должен находиться внутри штор
          padding:EdgeInsetsGeometry.all(0))
          ),
        Row(children: [
          Expanded(child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your task',
          ),
        )), 
        ElevatedButton(onPressed: () {
          setState(() {
            tasks.add(controller.text);
            controller.clear();
          });
        }, child: Text('Add')),
        ]),
        Expanded(child: ListView( // "Займи всё оставшееся место на экране". Без Height
            children: tasks.asMap().entries.map((entry) { // asMap - получение пары key: Value;
              int index = entry.key;
              String task = entry.value;

              return Dismissible(key: ValueKey(task),
              onDismissed: (direction) {
                setState(() {
                  tasks.removeAt(index);
                });
              }, 
              child: ListTile(title: Text(task),));
            }).toList(),
        )
        )
      ],
      ),
    );
  }
}