import 'package:flutter/material.dart';
import 'db/todo_item.dart';
import 'db/todo_dao.dart';
import 'db/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('todo_database.db').build();
  runApp(ShoppingListApp(database.todoDao));
}

class ShoppingListApp extends StatelessWidget {
  final TodoDao todoDao;

  const ShoppingListApp(this.todoDao, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List Lab',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
          backgroundColor: Colors.purple[200],
        ),
        body: ListPage(todoDao),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  final TodoDao todoDao;

  const ListPage(this.todoDao, {super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<TodoItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await widget.todoDao.fetchTodos();
    setState(() {
      _items = todos;
    });
  }

  Future<void> _addItem() async {
    String itemName = _itemController.text.trim();
    String quantity = _quantityController.text.trim();

    if (itemName.isNotEmpty && quantity.isNotEmpty) {
      final newItem = TodoItem(item: itemName, quantity: quantity);
      final id = await widget.todoDao.insertTodo(newItem);
      setState(() {
        _items.add(TodoItem(id: id, item: itemName, quantity: quantity));
        _itemController.clear();
        _quantityController.clear();
      });
    }
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await widget.todoDao.deleteTodo(_items[index]);
                setState(() {
                  _items.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(
                    hintText: 'Type the item here',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Type the quantity here',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addItem,
                child: const Text('Click here'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('There are no items in the list'))
                : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onLongPress: () => _deleteItem(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${index + 1}: ${item.item}  quantity: ${item.quantity}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
