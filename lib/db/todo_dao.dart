import 'package:floor/floor.dart';
import 'todo_item.dart';

/// Data Access Object (DAO) for performing CRUD operations on TodoItem.
@dao
abstract class TodoDao {
  /// Fetches all ToDo items from the database.
  @Query('SELECT * FROM TodoItem')
  Future<List<TodoItem>> fetchTodos();

  /// Inserts a new ToDo item into the database.
  /// Returns the auto-generated ID of the inserted row.
  @insert
  Future<int> insertTodo(TodoItem todo);

  /// Deletes the specified ToDo item from the database.
  @delete
  Future<void> deleteTodo(TodoItem todo);
}
