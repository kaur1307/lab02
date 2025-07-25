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
      home: ListPage(todoDao)
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
  TodoItem? _selectedItem;

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

  void _selectItem(TodoItem item, bool isWideScreen) {
    if (isWideScreen) {
      setState(()=> _selectedItem = item);

    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage(
          item: item,
          onDelete: () async {
            await widget.todoDao.deleteTodo(item);
            setState((){
              _items.remove(item);
            });
            Navigator.pop(context);
          },
        ),
        ),
      );
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedItem != null) {
      await widget.todoDao.deleteTodo(_selectedItem!);
      setState(() {
        _items.remove(_selectedItem);
        _selectedItem = null;
      });
    }
  }

  void _closeDetail() {
    setState(() => _selectedItem = null);
  }


  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width> 600;



        return Scaffold(
          appBar: AppBar(
            title: const Text('Shopping List'),
            backgroundColor: Colors.purple[200],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isWideScreen
                ? Row(
              children: [
                Expanded(child: _buildListView(isWideScreen)),
                const VerticalDivider(),
                Expanded(
                  child: _selectedItem == null
                      ? const Center(child: Text("Select an item"))
                      : DetailPage(
                    item: _selectedItem!,
                    onDelete: _deleteSelected,
                    onClose: _closeDetail,
                  ),
                ),
              ],
            )
                : _buildListView(isWideScreen),
          ),
        );


  }

  Widget _buildListView(bool isWideScreen) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _itemController,
                decoration: const InputDecoration(hintText: 'Item'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Quantity'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _addItem, child: const Text('Add')),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text('No items in the list'))
              : ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                title: Text('${item.item} - ${item.quantity}'),
                onTap: () => _selectItem(item, isWideScreen),
              );
            },
          ),
        ),
      ],
    );
  }
}


class DetailPage extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onDelete;
  final VoidCallback? onClose;

  const DetailPage({
    super.key,
    required this.item,
    required this.onDelete,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Item ID: ${item.id}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Name: ${item.item}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Quantity: ${item.quantity}", style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onClose ?? () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onDelete,
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
