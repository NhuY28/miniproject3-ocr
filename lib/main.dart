import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: const OCRExpenseTrackerApp(),
    ),
  );
}

class OCRExpenseTrackerApp extends StatelessWidget {
  const OCRExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainNavigationScreen(),
    );
  }
}