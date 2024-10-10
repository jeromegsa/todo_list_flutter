import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const TodoApp());
}

// Classe qui représente la structure de la donnée
class Todo {
  Todo({required this.name, required this.completed, required this.id});
  String id;
  String name;
  bool completed;
}

// Widget qui lance l'application
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TodoList(title: 'TodoList App'),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key, required this.title});
  final String title;
  @override
  State<TodoList> createState() => _TodoListState();
}

// Le widget qui va recevoir les tâches listées
class TodoItem extends StatelessWidget {
  TodoItem({
    required this.todo,
    required this.onTodoChanged,
    required this.callUpdateForm,
    required this.removeTodo,
  }) : super(key: ObjectKey(todo));

  final Todo todo;
  final void Function(Todo todo) onTodoChanged;
  final void Function(Todo todo) removeTodo;
  final void Function(Todo todo) callUpdateForm;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;
    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: Checkbox(
        checkColor: Colors.greenAccent,
        activeColor: Colors.red,
        value: todo.completed,
        onChanged: (value) {},
      ),
      title: Row(children: <Widget>[
        Expanded(
          child: Text(todo.name, style: _getTextStyle(todo.completed)),
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          alignment: Alignment.centerRight,
          onPressed: () {
            removeTodo(todo);
          },
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.update,
            color: Colors.lightGreen,
          ),
          alignment: Alignment.centerRight,
          onPressed: () {
            callUpdateForm(todo);
          },
        ),
      ]),
    );
  }
}

// Le widget qui définit l'état de l'application
class _TodoListState extends State<TodoList> {
  final List<Todo> _todos = <Todo>[];

  final TextEditingController _textFieldController = TextEditingController();
  var uuid = const Uuid(); // Instance de Uuid

  // Fonction pour générer un UUID
  String _generateUuid() {
    return uuid.v4(); // Générer un nouvel UUID (version 4)
  }

  // Fonction pour appeler un formulaire de modification
  Future<void> callUpdateForm(Todo todo) async {
    TextEditingController updateController = TextEditingController();
    updateController.text =
        todo.name; // Pré-remplir le champ avec le nom actuel

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Todo'),
          content: TextField(
            controller: updateController,
            decoration: const InputDecoration(hintText: 'Update your todo'),
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateTodoItem(todo.id, updateController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour ajouter une nouvelle tâche
  void _addTodoItem(String name) {
    setState(() {
      _todos.add(Todo(id: _generateUuid(), name: name, completed: false));
    });
  }

  // Fonction pour mettre à jour une tâche
  void _updateTodoItem(String id, String name) {
    setState(() {
      var index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index].name = name;
      }
    });
  }

  // Fonction pour changer l'état de la tâche
  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.completed = !todo.completed;
    });
  }

  // Fonction pour supprimer une tâche
  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.removeWhere((element) => element.id == todo.id);
    });
  }

  // Fonction pour afficher la liste des tâches si les tâches existent
  Widget displayList() {
    if (_todos.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _todos.map((Todo todo) {
          return TodoItem(
            todo: todo,
            onTodoChanged: _handleTodoChange,
            removeTodo: _deleteTodo,
            callUpdateForm: callUpdateForm,
          );
        }).toList(),
      );
    } else {
      return const Center(
        child: Text(
          "Aucune donnée à afficher.",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: displayList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _displayDialog();
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fonction pour afficher la boîte de dialogue d'ajout
  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a todo'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Type your todo'),
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
