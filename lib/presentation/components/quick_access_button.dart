import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class QuickAccessButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? iconColor;

  const QuickAccessButton({
    super.key,
    required this.text,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: AppShadows.buttonShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? AppColors.white,
              size: AppSpacing.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(text, style: AppTextStyles.buttonPrimary),
        ],
      ),
    );
  }
}
