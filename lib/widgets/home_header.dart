import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../screens/profile_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good evening 👋', style: AppTextStyles.subtitle),
            Text('Track your spending smarter', style: AppTextStyles.heading2),
          ],
        ),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
