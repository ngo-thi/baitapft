import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:untitled1/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Todo> TodoBox;

  @override
  void initState() {
    super.initState();
    TodoBox = Hive.box<Todo>("todo");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 174, 11, 11),
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text("Tài Khoản và Mật Khẩu ingame:"),
      ),
      body: ValueListenableBuilder(
        valueListenable: TodoBox.listenable(),
        builder: (context, Box<Todo> box, _) {
          return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                Todo todo = box.getAt(index)!;
                return Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: todo.isCompleted ? Colors.white38 : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Dismissible(
                    key: Key(todo.dateTime.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        todo.delete();
                      });
                    },
                    child: ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.description),
                      onTap: () => _editTodoDialog(context, todo),
                    ),
                  ),

                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTodoDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addTodoDialog(BuildContext context) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Thông Tin"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: "Tài Khoản"),
                  ),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(labelText: "Mật Khẩu"),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      _addTodo(_titleController.text, _descController.text);
                      Navigator.pop(context);
                    },
                    child: Text("Add")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Canel")),
              ],
            ));
  }

  void _editTodoDialog(BuildContext context, Todo todo) {
    TextEditingController _titleController =
    TextEditingController(text: todo.title);
    TextEditingController _descController =
    TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              todo.title = _titleController.text;
              todo.description = _descController.text;
              todo.save(); // Lưu lại thay đổi vào Hive
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _addTodo(String title, String decs) {
    if (title.isNotEmpty) {
      TodoBox.add(
        Todo(title: title, description: decs, dateTime: DateTime.now()),
      );
    }
  }
}
