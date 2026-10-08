import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../models/expense_model.dart';
import '../screens/expense_detail_screen.dart';
import 'expense_card.dart';

class RecentExpensesSection extends StatelessWidget {
  final List<Expense> expenses;

  const RecentExpensesSection({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Expenses', style: AppTextStyles.heading2),
            TextButton(onPressed: () {}, child: const Text('See All')),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
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
      ],
    );
  }
}
