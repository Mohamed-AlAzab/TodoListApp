import 'package:flutter/material.dart';
import 'package:todoapp/services/database_sevice.dart';
import '../models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  String? _task = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _addTaskButton(),
      appBar: AppBar(
        centerTitle: true,
        title: Text('ToDo List'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 24),
        child: _tasksList(),
      ),
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      backgroundColor: Colors.orange,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _task = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write your task...',
                  ),
                ),
                MaterialButton(
                  color: Colors.orange,
                  onPressed: () {
                    if (_task == null || _task == "") return;
                    _databaseService.addTask(_task!);
                    setState(() {
                      _task = null;
                    });
                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: const Icon(
        Icons.add,
      ),
    );
  }

  Widget _tasksList() {
    return FutureBuilder<List<Task>>(
      future: _databaseService.getTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            Task task = snapshot.data![index];
            return ListTile(
              leading: Checkbox(
                value: task.status == 1,
                activeColor: Colors.orange,
                checkColor: Colors.black,
                onChanged: (value) {
                  _databaseService.updateTaskStatus(
                    task.id,
                    value == true ? 1 : 0,
                  );
                  setState(() {});
                },
              ),
              title: Text(task.content),
              trailing: Wrap(
                spacing: 0,
                children: [
                  IconButton(
                    iconSize: 24,
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () {
                      _showEditDialog(task);
                    },
                  ),
                  IconButton(
                    iconSize: 24,
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      _databaseService.deleteTask(
                        task.id,
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(Task task) {
    String updatedTaskContent = task.content;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: task.content),
              onChanged: (value) {
                updatedTaskContent = value;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Edit your task...',
              ),
            ),
            MaterialButton(
              color: Colors.orange,
              onPressed: () {
                if (updatedTaskContent.isNotEmpty) {
                  _databaseService.updateTaskContent(
                      task.id, updatedTaskContent);
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Update",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
