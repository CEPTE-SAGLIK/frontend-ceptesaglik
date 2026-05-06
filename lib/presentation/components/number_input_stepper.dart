import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';

class NumberInputStepper extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(int) onArrowPressed;

  const NumberInputStepper({
    super.key,
    required this.label,
    required this.controller,
    required this.onArrowPressed,
  });

  @override
  Widget build(BuildContext context) {
    int currentValue = int.tryParse(controller.text) ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        Container(
          width: 130,
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            //   boxShadow: [AppShadows.softer],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: const TextSelectionThemeData(
                        cursorColor: AppColors.textPrimary,
                        selectionColor: Colors.transparent,
                        selectionHandleColor: AppColors.textPrimary,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      cursorColor: AppColors.textPrimary,
                      style: AppTextStyles.headingSmall,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        filled: false,
                      ),
                      // Kullanıcı elle yazarsa diye boş bırakıyoruz,
                      // asıl kontrol parent'ta veya oklarda.
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => onArrowPressed(currentValue + 1),
                    child: Icon(
                      Icons.arrow_drop_up,
                      size: AppSpacing.iconMd,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => onArrowPressed(currentValue - 1),
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: AppSpacing.iconMd,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
