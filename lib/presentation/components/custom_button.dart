import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? borderRadius;
  final IconData? icon;
  final double? width;
  final bool disabled;
  final double paddingVertical;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.borderRadius,
    this.icon,
    this.width,
    this.disabled = false,
    this.paddingVertical = AppSpacing.buttonPaddingVertical,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.secondary;
    final handler = disabled ? null : onPressed;
    final color = disabled ? bgColor.withOpacity(0.5) : bgColor;

    return SizedBox(
      width: width ?? 180,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.buttonRadius,
        ),
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        child: InkWell(
          onTap: handler,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.buttonPaddingHorizontal,
              vertical: paddingVertical,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppSpacing.iconMd, color: AppColors.white),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Center(child: Text(text, style: AppTextStyles.buttonPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
