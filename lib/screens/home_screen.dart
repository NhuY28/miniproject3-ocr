import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../providers/expense_provider.dart';
import 'scan_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/recent_expenses_section.dart';
import '../widgets/total_expense_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: AppDimens.xl),
              TotalExpenseCard(amount: provider.totalMonthlyExpense),
              const SizedBox(height: AppDimens.xl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLg)),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text('Scan Receipt', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppDimens.xxl),

              RecentExpensesSection(expenses: provider.expenses),
            ],
          ),
        ),
      ),
    );
  }
}