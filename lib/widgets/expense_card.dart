import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../models/expense_model.dart';
import '../utils/currency_formatter.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'bills':
        return Icons.receipt_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.xs,
        ),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryLight,
          child: Icon(
            _getCategoryIcon(expense.category),
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          expense.storeName,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${expense.category} • ${DateFormat('MMM dd').format(expense.date)}',
          style: AppTextStyles.caption,
        ),
        trailing: Text(
          '-${CurrencyFormatter.vnd(expense.amount)}',
          style: AppTextStyles.body.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}