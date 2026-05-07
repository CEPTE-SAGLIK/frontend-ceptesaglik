import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class ReminderBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;
  final double width;

  const ReminderBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isWhiteBg = backgroundColor == AppColors.white;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.cardShadowLight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: backgroundColor, size: AppSpacing.iconXl),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isWhiteBg
                          ? AppColors.textPrimary
                          : AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: AppTextStyles.cardBody.copyWith(
                      color: isWhiteBg
                          ? AppColors.textSecondary
                          : AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

