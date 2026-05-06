import 'dart:ui';

/// Sağlık Pusulası - Renk Paleti
///
/// Tasarım Felsefesi:
/// - Teal/Cyan ana renk: Güven, sakinlik, sağlık
/// - Yumuşak yeşil tonları: Şifa, doğallık
/// - Nötr gri arka planlar: Göz yormayan
/// - Pastel kategori renkleri: Tutarlı ve profesyonel
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // ANA RENKLER (Teal/Cyan Ailesi)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Ana renk - Teal (güven verici, sakin)
  static const Color primary = Color(0xFF0D9488); // Teal-600
  static const Color primaryLight = Color(0xFF14B8A6); // Teal-500
  static const Color primaryDark = Color(0xFF0F766E); // Teal-700

  /// İkincil renk - Cyan (tamamlayıcı)
  static const Color secondary = Color(0xFF06B6D4); // Cyan-500
  static const Color secondaryLight = Color(0xFF22D3EE); // Cyan-400
  static const Color secondaryDark = Color(0xFF0891B2); // Cyan-600

  /// Vurgu rengi - Emerald (sağlık/başarı)
  static const Color accent = Color(0xFF10B981); // Emerald-500
  static const Color accentLight = Color(0xFF34D399); // Emerald-400

  // ═══════════════════════════════════════════════════════════════════════════
  // ARKA PLAN RENKLERİ (Nötr Gri Tonları)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Ana arka plan - Çok açık gri (göz yormaz)
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color scaffoldBackground = Color(0xFFF1F5F9); // Slate-100
  static const Color surface = Color(0xFFE2E8F0); // Slate-200
  static const Color cardBackground = Color(0xFFFFFFFF); // Beyaz

  /// Özel kart arka planları (pastel tonlar)
  static const Color medCardBackground = Color(0xFFE0F2FE); // Sky-100
  static const Color healthCardBackground = Color(0xFFD1FAE5); // Emerald-100
  static const Color warningCardBackground = Color(0xFFFEF3C7); // Amber-100

  // ═══════════════════════════════════════════════════════════════════════════
  // METİN RENKLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // DURUM RENKLERİ (Yumuşak tonlar)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successLight = Color(0xFFD1FAE5); // Emerald-100
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber-100
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color errorLight = Color(0xFFFEE2E2); // Red-100
  static const Color info = Color(0xFF0EA5E9); // Sky-500
  static const Color infoLight = Color(0xFFE0F2FE); // Sky-100

  // ═══════════════════════════════════════════════════════════════════════════
  // KATEGORİ RENKLERİ (Pastel ve tutarlı)
  // ═══════════════════════════════════════════════════════════════════════════

  /// İlaç - Coral/Mercan (yumuşak kırmızı)
  static const Color catMedicine = Color(0xFFF87171); // Red-400
  static const Color catMedicineBg = Color(0xFFFEE2E2); // Red-100

  /// Sağlık/Aşı - Teal
  static const Color catHealth = Color(0xFF14B8A6); // Teal-500
  static const Color catHealthBg = Color(0xFFCCFBF1); // Teal-100

  /// Randevu/Diş - Mor (yumuşak)
  static const Color catTeeth = Color(0xFF8B5CF6); // Violet-500
  static const Color catTeethBg = Color(0xFFEDE9FE); // Violet-100

  /// Egzersiz - Turuncu (yumuşak)
  static const Color catExercise = Color(0xFFFB923C); // Orange-400
  static const Color catExerciseBg = Color(0xFFFED7AA); // Orange-200

  /// Toplantı - İndigo
  static const Color catMeeting = Color(0xFF6366F1); // Indigo-500
  static const Color catMeetingBg = Color(0xFFE0E7FF); // Indigo-100

  /// Genel - Amber
  static const Color catGeneral = Color(0xFFFBBF24); // Amber-400
  static const Color catGeneralBg = Color(0xFFFEF3C7); // Amber-100

  // ═══════════════════════════════════════════════════════════════════════════
  // KENAR / ÇERÇEVE RENKLERİ
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color outline = Color(0xFFE2E8F0); // Slate-200
  static const Color outlineVariant = Color(0xFFCBD5E1); // Slate-300
  static const Color divider = Color(0xFFE2E8F0); // Slate-200

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTON & İNTERAKTİF RENKLER
  // ═══════════════════════════════════════════════════════════════════════════

  /// Birincil buton - Ana teal rengi kullan
  static const Color primaryBlue = Color(
    0xFF0D9488,
  ); // primary ile aynı (tutarlılık)

  /// Acil durum - Kırmızı (dikkat çekici ama yumuşak)
  static const Color emergencyRed = Color(0xFFDC2626); // Red-600

  /// Aktif checkbox/toggle
  static const Color checkboxActive = Color(0xFF10B981); // Emerald-500

  // ═══════════════════════════════════════════════════════════════════════════
  // ÖZEL ALANLAR
  // ═══════════════════════════════════════════════════════════════════════════

  /// Takvim seçimi
  static const Color calendarSelection = Color(0xFFCCFBF1); // Teal-100
  static const Color calendarToday = Color(0xFF14B8A6); // Teal-500

  /// Öne çıkan içerik
  static const Color featuredBackground = Color(0xFFD1FAE5); // Emerald-100

  /// Navigasyon
  static const Color navUnselected = Color(0xFF94A3B8); // Slate-400
  static const Color navSelected = Color(0xFF0D9488); // Teal-600

  /// Öneri kartları
  static const Color suggestionCardBg = Color(0xFFF8FAFC); // Slate-50
  static const Color suggestionIcon = Color(0xFFFBBF24); // Amber-400

  // ═══════════════════════════════════════════════════════════════════════════
  // TEMEL RENKLER
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY - Geriye uyumluluk (eski kod için)
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color tertiary = accent;
  static const Color onPrimary = textOnPrimary;
  static const Color onSecondary = textOnPrimary;
  static const Color statusSuccess = success;
  static const Color statusWarning = warning;
  static const Color statusError = error;
  static const Color statusInfo = info;
  static const Color medCardBg = medCardBackground;
  static const Color brandPurple = catMeeting;
  static const Color brandPink = Color(0xFFF472B6); // Pink-400
}
