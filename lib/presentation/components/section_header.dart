import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionHeader),
        const SizedBox(height: AppSpacing.xs),
        Divider(
          color: AppColors.textSecondary.withOpacity(0.3),
          thickness: 1.5,
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
