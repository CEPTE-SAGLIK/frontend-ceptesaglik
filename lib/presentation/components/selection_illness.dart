import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class SelectionIllness extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final Color backgroundColor;
  final IconData? prefixIcon;
  final double width;
  final double height;

  const SelectionIllness({
    super.key,
    required this.title,
    this.onTap,
    this.backgroundColor = AppColors.background,
    this.prefixIcon,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text(title, style: AppTextStyles.bodyMedium)),
            const SizedBox(width: AppSpacing.xxxl),
            if (prefixIcon != null) Icon(prefixIcon),
          ],
        ),
      ),
    );
  }
}
