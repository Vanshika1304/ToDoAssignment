import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/network_utils/todo_utils.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _taskController = TextEditingController();
  final _descController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Todo Screen"),
      ),
      body: Container(
        child: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              List<Todo> todoList = snapshot.data ?? [];

              return ListView.builder(
                itemBuilder: (_, position) {
                  return ListTile(
                    title: Text(todoList[position].title ?? ''),
                    subtitle: Text(todoList[position].description ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showUpdateDialog(todoList[position]);
                            }),
                        IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade200,
                            ),
                            onPressed: () {
                              deleteTodo(todoList[position].objectId ?? '');
                            })
                      ],
                    ),
                  );
                },
                itemCount: todoList.length,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
          future: getTodoList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTodoDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showUpdateDialog(Todo todo) {
    _taskController.text = todo.title ?? '';
    _descController.text = todo.description ?? '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: "Enter updated task  title",
                      ),
                    ),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: "Enter updated task description",
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      todo.title = _taskController.text;
                      updateTodo(todo);
                    },
                    child: Text("Update")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
              ],
            ));
  }

  Future<List<Todo>> getTodoList() async {
    List<Todo> todoList = [];

    Response response = await TodoUtils.getTodoList();
    print("Code is ${response.statusCode}");
    print("Response is ${response.body}");

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      var results = body["results"];

      for (var todo in results) {
        todoList.add(Todo.fromJson(todo));
      }
    } else {
      //Handle error
    }

    return todoList;
  }

  void showAddTodoDialog() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: "Enter title",
                      ),
                    ),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: "Enter description",
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      addTodo();
                    },
                    child: Text("Add")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
              ],
            ));
  }

  void addTodo() {
    if (_taskController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill the field '),
        duration: Duration(seconds: 1),
      ));

      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          Text("Adding task"),
          CircularProgressIndicator(),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      duration: Duration(minutes: 1),
    ));

    Todo todo =
        Todo(title: _taskController.text, description: _descController.text);

    TodoUtils.addTodo(todo).then((res) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      Response response = res;
      if (response.statusCode == 201) {
        //Successful
        _taskController.text = "";
        _descController.text = "";

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Todo added!"),
          duration: Duration(seconds: 1),
        ));

        setState(() {});
      }
    });
  }

  void updateTodo(Todo todo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Updating todo"),
            CircularProgressIndicator(),
          ],
        ),
        duration: Duration(minutes: 1),
      ),
    );

    TodoUtils.updateTodo(todo).then((res) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      Response response = res;
      if (response.statusCode == 200) {
        //Successfully Deleted
        _taskController.text = "";
        _descController.text = "";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: (Text("Updated!"))));
        setState(() {});
      } else {
        //Handle error
      }
    });
  }

  void deleteTodo(String objectId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Deleting todo"),
            CircularProgressIndicator(),
          ],
        ),
        duration: Duration(minutes: 1),
      ),
    );

    TodoUtils.deleteTodo(objectId).then((res) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      Response response = res;
      if (response.statusCode == 200) {
        //Successfully Deleted
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: (Text("Deleted!")),
          duration: Duration(seconds: 1),
        ));
        setState(() {});
      } else {
        //Handle error
      }
    });
  }
}
