import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.heading2),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.lg),
        children: [
          // Section: Appearance
          const Text('Appearance', style: AppTextStyles.subtitle),
          const SizedBox(height: AppDimens.sm),
          Card(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: const ListTile(
              leading: Icon(Icons.palette_outlined, color: AppColors.primary),
              title: Text('Theme Mode'),
              subtitle: Text('System Default'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: AppDimens.xl),

          // Section: Data
          const Text('Data & Storage', style: AppTextStyles.subtitle),
          const SizedBox(height: AppDimens.sm),
          Card(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Clear All Expenses', style: TextStyle(color: AppColors.error)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Clear'),
                    content: const Text('Are you sure you want to delete all saved expenses?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () {
                          provider.clearAllData();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All data cleared')),
                          );
                        },
                        child: const Text('Clear', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimens.xl),

          // Section: About
          const Text('About', style: AppTextStyles.subtitle),
          const SizedBox(height: AppDimens.sm),
          Card(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text('App Version'),
                  trailing: Text('1.0.0 (Build 1)', style: AppTextStyles.caption),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.document_scanner_outlined, color: AppColors.primary),
                  title: Text('OCR Engine'),
                  trailing: Text('Google ML Kit', style: AppTextStyles.caption),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}