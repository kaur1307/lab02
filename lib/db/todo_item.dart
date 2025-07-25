import 'package:floor/floor.dart';

/// Represents a shopping list item entity in the database.
@entity
class TodoItem {
  @PrimaryKey(autoGenerate: true)

  final int? id;

  final String item;
  final String quantity;

  TodoItem({
    this.id,
    required this.item,
    required this.quantity,
  });
}
