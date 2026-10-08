import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense_model.dart';

class ExpenseDatabase {
  ExpenseDatabase._();

  static final ExpenseDatabase instance = ExpenseDatabase._();
  static const _databaseName = 'ocr_expense_tracker.db';
  static const _databaseVersion = 2;
  static const tableExpenses = 'expenses';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $tableExpenses (
            id TEXT PRIMARY KEY,
            user_id INTEGER NOT NULL,
            store_name TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            category TEXT NOT NULL,
            raw_ocr_text TEXT NOT NULL DEFAULT '',
            qr_code TEXT,
            image_path TEXT,
            is_verified INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('ALTER TABLE $tableExpenses ADD COLUMN qr_code TEXT');
        }
      },
    );
    return _database!;
  }

  Future<List<Expense>> getExpenses() async {
    final database = await this.database;
    final rows = await database.query(
      tableExpenses,
      orderBy: 'date DESC',
    );
    return rows.map((row) => Expense.fromMap(row)).toList();
  }

  Future<void> insertExpense(Expense expense) async {
    final database = await this.database;
    await database.insert(
      tableExpenses,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExpense(String id) async {
    final database = await this.database;
    await database.delete(
      tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearExpenses() async {
    final database = await this.database;
    await database.delete(tableExpenses);
  }

  Future<void> insertExpenses(List<Expense> expenses) async {
    if (expenses.isEmpty) return;

    final database = await this.database;
    final batch = database.batch();
    for (final expense in expenses) {
      batch.insert(
        tableExpenses,
        expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
