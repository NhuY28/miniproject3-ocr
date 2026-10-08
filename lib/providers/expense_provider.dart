import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/expense_model.dart';
import '../services/expense_database.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  final ExpenseDatabase _database = ExpenseDatabase.instance;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    loadExpenses();
  }

  double get totalMonthlyExpense {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _database.getExpenses();

      if (_expenses.isEmpty) {
        await _migrateLegacyData();
      }

      if (_expenses.isEmpty) {
        _expenses = [
          Expense(
            id: '1',
            userId: 1,
            storeName: 'Vinmart',
            amount: 70.0,
            date: DateTime.now(),
            category: 'Shopping',
          ),
          Expense(
            id: '2',
            userId: 1,
            storeName: 'Highlands Coffee',
            amount: 45.0,
            date: DateTime.now().subtract(const Duration(days: 1)),
            category: 'Food',
          ),
          Expense(
            id: '3',
            userId: 1,
            storeName: 'Grab',
            amount: 85.0,
            date: DateTime.now().subtract(const Duration(days: 2)),
            category: 'Transport',
          ),
        ];
        await _database.insertExpenses(_expenses);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _migrateLegacyData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_expenses');
    if (data == null) return;

    final decoded = json.decode(data) as List<dynamic>;
    _expenses = decoded
        .map((item) => Expense.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
    await _database.insertExpenses(_expenses);
    await prefs.remove('user_expenses');
  }

  Future<void> addExpense(Expense expense) async {
    await _database.insertExpense(expense);

    debugPrint('========== SQLITE TEST ==========');
    debugPrint('Inserted ID: ${expense.id}');

    final savedExpenses = await _database.getExpenses();

    for (final item in savedExpenses) {
      debugPrint(
        'SQLite: '
        '${item.id} | '
        '${item.storeName} | '
        '${item.amount} | '
        '${item.category} | '
        'userId=${item.userId} | '
        'verified=${item.isVerified}',
      );
    }

    debugPrint('=================================');

    _expenses.insert(0, expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _database.deleteExpense(id);
    _expenses.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _database.clearExpenses();
    _expenses.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_expenses');
    notifyListeners();
  }
}
