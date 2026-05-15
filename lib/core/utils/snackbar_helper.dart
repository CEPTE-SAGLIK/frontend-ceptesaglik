import 'package:flutter/material.dart';
import 'package:health_asistants/core/error/app_error.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void showError(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 4)}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline_rounded,
      duration: duration,
    );
  }

  static void showAppError(BuildContext context, AppError error,
      {VoidCallback? onRetry,
      Duration duration = const Duration(seconds: 4)}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(error.icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error.message.replaceAll('\n', ' '),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: error.type == AppErrorType.network
            ? AppColors.warning
            : AppColors.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Tekrar Dene',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
      duration: duration,
    );
  }

  static void showInfo(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 3)}) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline_rounded,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: action,
      ),
    );
  }
}
