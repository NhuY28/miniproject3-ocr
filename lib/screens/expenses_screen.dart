import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import 'expense_detail_screen.dart';
import 'scan_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Food',
    'Shopping',
    'Transport',
    'Bills',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    final filteredExpenses = provider.expenses.where((expense) {
      final matchesSearch = expense.storeName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          expense.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses', style: AppTextStyles.heading2),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.md),

            // Category Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppDimens.sm),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimens.lg),

            // Expense List
            Expanded(
              child: filteredExpenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 64, color: AppColors.textMuted),
                          const SizedBox(height: AppDimens.md),
                          const Text('No expenses yet', style: AppTextStyles.heading2),
                          const SizedBox(height: AppDimens.xs),
                          const Text('Scan your first receipt to start tracking.',
                              style: AppTextStyles.subtitle),
                          const SizedBox(height: AppDimens.lg),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ScanScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Scan Receipt'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return ExpenseCard(
                          expense: expense,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpenseDetailScreen(expense: expense),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

