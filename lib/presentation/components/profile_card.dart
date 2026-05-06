import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String? email;
  final VoidCallback? onEditPressed;
  final VoidCallback? onLogoutPressed;

  const ProfileCard({
    super.key,
    required this.name,
    this.email,
    this.onEditPressed,
    this.onLogoutPressed,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    return (parts.length >= 2)
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: AppShadows.cardShadowLight,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.secondary,
            child: Text(
              _initials,
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMedium),
                if (email != null)
                  Text(
                    email!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.black.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (onEditPressed != null)
            IconButton(
              onPressed: onEditPressed,
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: AppSpacing.iconLg,
              ),
            ),
          if (onLogoutPressed != null)
            IconButton(
              onPressed: onLogoutPressed,
              icon: const Icon(
                Icons.logout,
                color: AppColors.error,
                size: AppSpacing.iconMd,
              ),
            ),
        ],
      ),
    );
  }
}
