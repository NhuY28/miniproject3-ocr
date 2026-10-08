import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../widgets/expense_chart.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _timeFilter = 'Month';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics', style: AppTextStyles.heading2),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Week', 'Month', 'Year'].map((filter) {
                final isSelected = filter == _timeFilter;
                return GestureDetector(
                  onTap: () => setState(() => _timeFilter = filter),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimens.xl),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Spending',
                    CurrencyFormatter.vnd(provider.totalMonthlyExpense),
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: _buildSummaryCard(
                    'Transactions',
                    '${provider.expenses.length}',
                    Icons.receipt_long,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xl),

            // Custom Chart
            const Text('Spending Trend', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimens.md),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              elevation: 0,
              color: AppColors.surface,
              child: const ExpenseChart(),
            ),
            const SizedBox(height: AppDimens.xl),

            // Category Breakdown
            const Text('Category Breakdown', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimens.md),
            _buildCategoryRow('Food', 0.45, AppColors.primary),
            _buildCategoryRow('Shopping', 0.25, Colors.orange),
            _buildCategoryRow('Transport', 0.15, Colors.green),
            _buildCategoryRow('Bills', 0.10, Colors.purple),
            _buildCategoryRow('Other', 0.05, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: AppDimens.sm),
          Text(title, style: AppTextStyles.caption),
          const SizedBox(height: AppDimens.xs),
          Text(value, style: AppTextStyles.heading2),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String title, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.body),
              Text('${(percentage * 100).toInt()}%',
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppDimens.xs),
          LinearProgressIndicator(
            value: percentage,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
