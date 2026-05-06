import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';

class CustomDatePicker {
  /// Tarih seçiciyi açar ve seçilen tarihi (veya null) döndürür.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Renk ve Tema ayarları burada gizlenir
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
