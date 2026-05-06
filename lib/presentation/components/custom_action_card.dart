import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class CustomActionCard extends StatelessWidget {
  final String title;
  final String timeText;
  final String periodText;
  final bool isCompleted;
  final VoidCallback onStatusChanged;
  final Color? backgroundColor;
  final String? iconPath;
  final double? width;
  final double? height;
  final double borderRadius;

  const CustomActionCard({
    super.key,
    required this.title,
    required this.onStatusChanged,
    this.isCompleted = false,
    required this.timeText,
    required this.periodText,
    this.backgroundColor,
    this.iconPath,
    this.width,
    this.height,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.medCardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        //   boxShadow: [AppShadows. cardShadowLight],
      ),
      child: Row(
        children: [
          if (iconPath != null) ...[
            Image.asset(
              iconPath!,
              width: AppSpacing.iconXl,
              height: AppSpacing.iconXl,
            ),
            SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                SizedBox(height: AppSpacing.xs),
                Text(timeText, style: AppTextStyles.cardBody),
                SizedBox(height: AppSpacing.xs),
                Text(
                  periodText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
