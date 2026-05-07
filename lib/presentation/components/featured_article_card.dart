import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class FeaturedArticleCard extends StatelessWidget {
  final String title;
  final String author;
  final Color backgroundColor;
  final String? imageTitle;
  final VoidCallback onTap;

  const FeaturedArticleCard({
    super.key,
    required this.title,
    required this.author,
    required this.backgroundColor,
    required this.onTap,
    this.imageTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.cardRadius),
                ),
              ),
              child: Center(
                child: Text(
                  imageTitle ?? "",
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Text(
                title,
                style: AppTextStyles.headingSmall.copyWith(height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

