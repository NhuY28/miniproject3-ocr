import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../models/expense_model.dart';
import '../utils/currency_formatter.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.storeName, style: AppTextStyles.heading2.copyWith(color: Colors.white)),
                const SizedBox(height: AppDimens.sm),
                Text(
                  '-${CurrencyFormatter.vnd(expense.amount)}',
                  style: AppTextStyles.amountLarge,
                ),
                const SizedBox(height: AppDimens.xs),
                Text(expense.category, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          _DetailRow(label: 'Date', value: DateFormat('dd MMM yyyy, HH:mm').format(expense.date)),
          _DetailRow(label: 'Category', value: expense.category),
          _DetailRow(label: 'User ID', value: expense.userId.toString()),
          _DetailRow(label: 'Verified', value: expense.isVerified ? 'Yes' : 'No'),
          if (expense.rawOcrText.isNotEmpty) ...[
            const SizedBox(height: AppDimens.lg),
            const Text('Recognized OCR Text', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimens.sm),
            Container(
              padding: const EdgeInsets.all(AppDimens.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: SelectableText(
                expense.rawOcrText,
                style: const TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary),
              ),
            ),
          ],
          if (expense.qrCode != null && expense.qrCode!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.lg),
            const Text('QR Code', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimens.sm),
            SelectableText(expense.qrCode!),
          ],
          if (expense.imagePath != null && expense.imagePath!.isNotEmpty)
            _DetailRow(label: 'Image', value: expense.imagePath!),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
