import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Uygulama genelinde kullanılan metin stilleri.
/// Tüm component'ler bu stilleri kullanmalıdır.
class AppTextStyles {
  AppTextStyles._();

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADING STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // TITLE STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LABEL STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CAPTION STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary.withValues(alpha: 0.5),
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle cardBody = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CHIP STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle chipSelected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );

  static const TextStyle chipUnselected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION HEADER STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.textPrimary,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // KATEGORI STİLLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle categoryLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: AppColors.secondary,
  );
}

