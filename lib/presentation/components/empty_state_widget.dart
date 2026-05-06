import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';

/// Boş durum widget'ı
///
/// Kullanım:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.vaccines_rounded,
///   iconColor: AppColors.catHealth,
///   title: 'Henüz aşı kaydınız yok',
///   description: 'Aşı takviminizi oluşturmak için ilk aşınızı ekleyin.',
///   actionLabel: 'Aşı Ekle',
///   onAction: () => Navigator.pushNamed(context, '/add-reminder'),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateStyle style;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.style = EmptyStateStyle.card,
  });

  /// Hatırlatma yok durumu
  factory EmptyStateWidget.noReminders({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.notifications_off_outlined,
      iconColor: AppColors.catGeneral,
      title: 'Hatırlatma bulunmuyor',
      description: 'Yeni bir hatırlatma ekleyerek başlayın.',
      actionLabel: 'Hatırlatma Ekle',
      onAction: onAction,
    );
  }

  /// Bugün hatırlatma yok durumu
  factory EmptyStateWidget.noRemindersToday() {
    return EmptyStateWidget(
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.success,
      title: 'Bugün için hatırlatma yok 🎉',
      description: 'Tüm görevlerinizi tamamladınız!',
      style: EmptyStateStyle.minimal,
    );
  }

  /// Aşı kaydı yok durumu
  factory EmptyStateWidget.noVaccines({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.vaccines_rounded,
      iconColor: AppColors.catHealth,
      title: 'Henüz aşı kaydınız yok',
      description: 'Aşı takviminizi oluşturmak için ilk aşınızı ekleyin.',
      actionLabel: 'Aşı Ekle',
      onAction: onAction,
    );
  }

  /// İlaç kaydı yok durumu
  factory EmptyStateWidget.noMedicines({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.medication_outlined,
      iconColor: AppColors.catMedicine,
      title: 'Henüz ilaç kaydınız yok',
      description: 'Düzenli kullandığınız ilaçları ekleyerek hatırlatma alın.',
      actionLabel: 'İlaç Ekle',
      onAction: onAction,
    );
  }

  /// Etkinlik yok durumu (takvim)
  factory EmptyStateWidget.noEvents({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.event_available_rounded,
      iconColor: AppColors.catMeeting,
      title: 'Bu tarihte etkinlik yok',
      description: 'Yeni bir etkinlik eklemek için aşağıdaki butona tıklayın.',
      actionLabel: 'Etkinlik Ekle',
      onAction: onAction,
      style: EmptyStateStyle.card,
    );
  }

  /// Arama sonucu yok durumu
  factory EmptyStateWidget.noSearchResults({String? query}) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      iconColor: AppColors.textSecondary,
      title: 'Sonuç bulunamadı',
      description: query != null
          ? '"$query" için sonuç bulunamadı. Farklı bir arama deneyin.'
          : 'Arama kriterlerinize uygun sonuç bulunamadı.',
      style: EmptyStateStyle.minimal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      EmptyStateStyle.card => _buildCard(),
      EmptyStateStyle.minimal => _buildMinimal(),
      EmptyStateStyle.fullPage => _buildFullPage(),
    };
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconContainer(),
          SizedBox(height: AppSpacing.lg),
          _buildTitle(),
          if (description != null) ...[
            SizedBox(height: AppSpacing.sm),
            _buildDescription(),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: AppSpacing.lg),
            _buildActionButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimal() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: (iconColor ?? AppColors.textSecondary).withOpacity(0.6),
          ),
          SizedBox(height: AppSpacing.md),
          _buildTitle(),
          if (description != null) ...[
            SizedBox(height: AppSpacing.xs),
            _buildDescription(),
          ],
        ],
      ),
    );
  }

  Widget _buildFullPage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconContainer(size: 120),
            SizedBox(height: AppSpacing.xl),
            _buildTitle(fontSize: 20),
            if (description != null) ...[
              SizedBox(height: AppSpacing.md),
              _buildDescription(),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.xl),
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer({double size = 80}) {
    final color = iconColor ?? AppColors.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }

  Widget _buildTitle({double fontSize = 16}) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      description!,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  Widget _buildActionButton() {
    return FilledButton.icon(
      onPressed: onAction,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(actionLabel!),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

/// Empty state stilleri
enum EmptyStateStyle {
  /// Kart içinde gösterim (default)
  card,

  /// Minimal gösterim (sadece icon ve metin)
  minimal,

  /// Tam sayfa gösterim
  fullPage,
}
