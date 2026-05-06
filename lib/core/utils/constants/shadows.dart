import 'package:flutter/material.dart';
import 'colors.dart';

/// Uygulama genelinde kullanılan gölge stilleri.
/// Tutarlı bir tasarım için bu değerleri kullanın.
class AppShadows {
  AppShadows._();

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppColors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowLight => [
    BoxShadow(
      color: AppColors.outlineVariant,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowMedium => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: Colors.blue.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get emergencyButtonShadow => [
    BoxShadow(
      color: Colors.red.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // INPUT SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get inputShadow => [
    BoxShadow(
      color: AppColors.outlineVariant,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // SOFT SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get softer => [
    BoxShadow(
      color: Colors.grey.withOpacity(0.08),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // NO SHADOW
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> get none => [];
}
