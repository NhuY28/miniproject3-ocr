import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.lg),
        children: const [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, size: 48, color: AppColors.primary),
          ),
          SizedBox(height: AppDimens.md),
          Center(
              child:
                  Text('Expense Tracker User', style: AppTextStyles.heading2)),
          SizedBox(height: AppDimens.xs),
          Center(
              child: Text('user@expense.app', style: AppTextStyles.subtitle)),
          SizedBox(height: AppDimens.xl),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline, color: AppColors.primary),
                  title: Text('Full name'),
                  subtitle: Text('Expense Tracker User'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.email_outlined, color: AppColors.primary),
                  title: Text('Email'),
                  subtitle: Text('user@expense.app'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.account_circle_outlined,
                      color: AppColors.primary),
                  title: Text('Account type'),
                  subtitle: Text('Personal account'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
