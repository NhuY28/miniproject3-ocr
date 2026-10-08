import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../utils/currency_formatter.dart';

class TotalExpenseCard extends StatelessWidget {
  final double amount;

  const TotalExpenseCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x292563EB),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Expenses',
                style: AppTextStyles.subtitle.copyWith(color: Colors.white70),
              ),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(CurrencyFormatter.vnd(amount), style: AppTextStyles.amountLarge),
          const SizedBox(height: AppDimens.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  '+8.4% compared to last month',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
