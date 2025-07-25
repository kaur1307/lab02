import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'todo_item.dart';
import 'todo_dao.dart';

part 'app_database.g.dart'; // This will be generated

/// The main database class using Floor ORM.
/// Includes all entities and DAOs.
@Database(version: 1, entities: [TodoItem])
abstract class AppDatabase extends FloorDatabase {
  /// Provides access to the TodoDao
  TodoDao get todoDao;
}
