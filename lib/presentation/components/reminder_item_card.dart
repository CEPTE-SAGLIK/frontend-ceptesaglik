import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class ReminderItemCard extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final bool isCustomIcon;
  final Color? customIconColor;

  const ReminderItemCard({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    required this.isChecked,
    required this.onChanged,
    this.isCustomIcon = false,
    this.customIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardMargin),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          isCustomIcon && title == "Aspirin"
              ? const Text("💊", style: TextStyle(fontSize: 20))
              : Icon(
                  icon,
                  color: customIconColor ?? AppColors.navUnselected,
                  size: AppSpacing.iconMd,
                ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            time,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: AppColors.checkboxActive,
              side: const BorderSide(color: AppColors.textSecondary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
