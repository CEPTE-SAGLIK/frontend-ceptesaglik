import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class CustomInput extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onVisibilityToggle;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final double borderRadius;
  final ValueChanged<String>? onChanged;

  const CustomInput({
    super.key,
    required this.labelText,
    this.hintText = '',
    this.isPassword = false,
    this.obscureText = false,
    this.onVisibilityToggle,
    this.controller,
    this.prefixIcon,
    this.borderRadius = AppSpacing.radiusMd,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty) ...[
          Text(labelText, style: AppTextStyles.inputLabel),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: AppColors.white,
            boxShadow: AppShadows.inputShadow,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscureText : false,
            style: AppTextStyles.inputText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.inputHint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.inputPaddingHorizontal,
                vertical: AppSpacing.inputPaddingVertical,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.textSecondary,
                      size: AppSpacing.iconMd,
                    )
                  : null,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
