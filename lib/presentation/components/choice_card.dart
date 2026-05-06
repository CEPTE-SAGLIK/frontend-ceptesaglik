import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class ChoiceCard extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final List<Widget>? subItems;

  const ChoiceCard({super.key, required this.title, this.onTap, this.subItems});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      boxShadow: AppShadows.cardShadowLight,
    );

    return (subItems != null && subItems!.isNotEmpty)
        ? Container(
            decoration: decoration,
            child: ExpansionTile(
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              collapsedShape: const RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 0,
              ),
              childrenPadding: EdgeInsets.zero,
              dense: true,
              title: Text(title, style: AppTextStyles.bodyLarge),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: subItems!,
                  ),
                ),
              ],
            ),
          )
        : InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: decoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  const Icon(
                    Icons.arrow_forward,
                    size: AppSpacing.iconMd,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          );
  }
}
