import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';

enum AppErrorType { network, server, auth, validation, unknown }

class AppError {
  final AppErrorType type;
  final String message;

  const AppError({required this.type, required this.message});

  factory AppError.network() => const AppError(
        type: AppErrorType.network,
        message:
            'İnternet bağlantısı yok.\nLütfen bağlantınızı kontrol edip tekrar deneyin.',
      );

  factory AppError.server([String? msg]) => AppError(
        type: AppErrorType.server,
        message:
            msg ?? 'Sunucuda bir sorun oluştu.\nLütfen daha sonra tekrar deneyin.',
      );

  factory AppError.auth() => const AppError(
        type: AppErrorType.auth,
        message: 'Oturum süreniz doldu.\nLütfen yeniden giriş yapın.',
      );

  factory AppError.validation(String msg) => AppError(
        type: AppErrorType.validation,
        message: msg,
      );

  factory AppError.unknown([String? msg]) => AppError(
        type: AppErrorType.unknown,
        message: msg ?? 'Beklenmeyen bir hata oluştu.\nLütfen tekrar deneyin.',
      );

  factory AppError.fromString(String error) {
    if (_isNetworkError(error)) return AppError.network();
    if (_isAuthError(error)) return AppError.auth();
    if (_isServerError(error)) return AppError.server();
    return AppError.unknown(error);
  }

  static bool _isNetworkError(String e) =>
      e.contains('SocketException') ||
      e.contains('NetworkException') ||
      e.contains('İnternet bağlantısı') ||
      e.contains('Connection refused') ||
      e.contains('Failed host lookup') ||
      e.contains('Connection timed out') ||
      e.contains('bağlantı yok');

  static bool _isAuthError(String e) =>
      e.contains('401') || e.contains('Oturum süresi');

  static bool _isServerError(String e) =>
      e.contains('500') ||
      e.contains('502') ||
      e.contains('503') ||
      e.contains('504');

  IconData get icon {
    switch (type) {
      case AppErrorType.network:
        return Icons.wifi_off_rounded;
      case AppErrorType.server:
        return Icons.cloud_off_rounded;
      case AppErrorType.auth:
        return Icons.lock_outline_rounded;
      case AppErrorType.validation:
        return Icons.warning_amber_rounded;
      case AppErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  Color get color {
    switch (type) {
      case AppErrorType.network:
        return AppColors.warning;
      case AppErrorType.server:
        return AppColors.error;
      case AppErrorType.auth:
        return AppColors.primary;
      case AppErrorType.validation:
        return AppColors.warning;
      case AppErrorType.unknown:
        return AppColors.error;
    }
  }
}

extension StringToAppError on String? {
  AppError? get asAppError =>
      this != null ? AppError.fromString(this!) : null;
}
