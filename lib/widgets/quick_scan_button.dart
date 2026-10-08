import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

class QuickScanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const QuickScanButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          elevation: 2,
        ),
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt_rounded, size: 20),
        ),
        label: const Text(
          'Scan Receipt',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}