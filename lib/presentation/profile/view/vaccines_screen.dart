import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/shadows.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/data/model/child.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/presentation/profile/viewmodel/vaccines_viewmodel.dart';

/// Çocuk Aşı Takip Ekranı
///
/// - Çocuk ekleme / silme
/// - Yaşa göre otomatik aşı takvimi
/// - Aşı tamamlama / geri alma
/// - Manuel aşı ekleme
/// - Yaklaşan & gecikmiş aşı bildirimleri
class MyVaccinesScreen extends StatefulWidget {
  const MyVaccinesScreen({super.key});

  @override
  State<MyVaccinesScreen> createState() => _MyVaccinesScreenState();
}

class _MyVaccinesScreenState extends State<MyVaccinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaccinesViewModel>().loadChildren();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // _viewModel erişimi için getter – build'de watch ile yeniden çizim tetiklenir
  VaccinesViewModel get _viewModel => context.read<VaccinesViewModel>();

  @override
  Widget build(BuildContext context) {
    // watch ile yeniden çizim tetiklenir
    final viewModel = context.watch<VaccinesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çocuk Aşı Takibi'),
        centerTitle: true,
        actions: [
          if (viewModel.hasChildren)
            IconButton(
              icon: const Icon(Icons.person_add_rounded),
              tooltip: 'Çocuk Ekle',
              onPressed: () => _showAddChildDialog(context),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // ─────────────────────────────────────
  // Body
  // ─────────────────────────────────────

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.status == VaccineScreenStatus.error) {
      return _buildErrorState();
    }

    if (!_viewModel.hasChildren) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Çocuk seçici (üst kısım)
        _buildChildSelector(),

        // Aşı takvimi içeriği
        Expanded(child: _buildScheduleContent()),
      ],
    );
  }

  // ─────────────────────────────────────
  // Boş Durum — Hiç çocuk eklenmemiş
  // ─────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.catHealthBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.child_care_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Henüz çocuk eklenmedi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Çocuğunuzu ekleyerek yaşına uygun\naşı takvimini otomatik oluşturabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.icon(
              onPressed: () => _showAddChildDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Çocuk Ekle'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // Çocuk Seçici (Yatay Kaydırmalı)
  // ─────────────────────────────────────

  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _viewModel.children.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final child = _viewModel.children[index];
            final isSelected = child.id == _viewModel.selectedChild?.id;
            return _buildChildChip(child, isSelected);
          },
        ),
      ),
    );
  }

  Widget _buildChildChip(Child child, bool isSelected) {
    final overdueCount = child.vaccineSchedule
        .expand((s) => s.vaccines)
        .where((v) => v.isOverdue)
        .length;

    return GestureDetector(
      onTap: () => _viewModel.selectChild(child.id),
      onLongPress: () => _showChildOptionsSheet(child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  child.gender == ChildGender.male
                      ? Icons.boy_rounded
                      : Icons.girl_rounded,
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  child.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                if (overdueCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$overdueCount',
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              child.ageText,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.textOnPrimary.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // Aşı Takvimi İçeriği
  // ─────────────────────────────────────

  Widget _buildScheduleContent() {
    final child = _viewModel.selectedChild;
    if (child == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Uyarı kartları
          if (_viewModel.overdueVaccines.isNotEmpty) _buildWarningCard(),
          if (_viewModel.upcomingVaccines.isNotEmpty) _buildUpcomingCard(),

          // İlerleme çubuğu
          _buildProgressBar(),
          const SizedBox(height: AppSpacing.lg),

          // Aşı takvimi dönemleri
          ...child.vaccineSchedule.map(_buildScheduleCard),

          // Manuel aşı ekleme butonu
          const SizedBox(height: AppSpacing.md),
          _buildAddManualVaccineButton(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // Uyarı Kartları
  // ─────────────────────────────────────

  Widget _buildWarningCard() {
    final count = _viewModel.overdueVaccines.length;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gecikmiş Aşılar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  '$count adet aşının tarihi geçmiş. Lütfen doktorunuza danışın.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard() {
    final count = _viewModel.upcomingVaccines.length;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            color: AppColors.info,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yaklaşan Aşılar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.info,
                  ),
                ),
                Text(
                  '$count adet aşı 30 gün içinde yapılmalı.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // İlerleme Çubuğu
  // ─────────────────────────────────────

  Widget _buildProgressBar() {
    final progress = _viewModel.scheduleProgress;
    final child = _viewModel.selectedChild!;
    int totalVaccines = 0;
    int completedVaccines = 0;
    for (final s in child.vaccineSchedule) {
      totalVaccines += s.vaccines.length;
      completedVaccines += s.completedCount;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${child.name} — Aşı İlerleme',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$completedVaccines / $totalVaccines',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '%${(progress * 100).toInt()} tamamlandı',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // Dönem Kartları (Aşı Takvimi)
  // ─────────────────────────────────────

  Widget _buildScheduleCard(BabyVaccineSchedule schedule) {
    final allDone = schedule.isAllCompleted;
    final isPast = schedule.isPast && !allDone;
    final isUpcoming = schedule.isUpcoming;

    Color borderColor = AppColors.outlineVariant;
    if (allDone) {
      borderColor = AppColors.success.withValues(alpha: 0.3);
    } else if (isPast) {
      borderColor = AppColors.error.withValues(alpha: 0.3);
    } else if (isUpcoming) {
      borderColor = AppColors.info.withValues(alpha: 0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: !allDone && (isPast || isUpcoming),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: allDone
                  ? AppColors.successLight
                  : isPast
                  ? AppColors.errorLight
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              allDone
                  ? Icons.check
                  : isPast
                  ? Icons.schedule
                  : Icons.baby_changing_station,
              color: allDone
                  ? AppColors.success
                  : isPast
                  ? AppColors.error
                  : AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            schedule.period,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                allDone
                    ? 'Tamamlandı'
                    : '${schedule.completedCount}/${schedule.vaccines.length} Tamamlandı',
                style: TextStyle(
                  color: allDone ? AppColors.success : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                'Planlanan: ${_formatDate(schedule.scheduledDate)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  ...schedule.vaccines.map(
                    (vaccine) => _buildVaccineItem(schedule, vaccine),
                  ),
                  const SizedBox(height: 8),
                  // Döneme aşı ekle
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showAddVaccineToScheduleDialog(context, schedule),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Aşı Ekle',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineItem(BabyVaccineSchedule schedule, Vaccine vaccine) {
    final done = vaccine.isCompleted;
    final overdue = vaccine.isOverdue;

    return InkWell(
      onTap: () => _viewModel.toggleVaccineStatus(schedule.id, vaccine.id),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done
                  ? AppColors.success
                  : overdue
                  ? AppColors.error
                  : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccine.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        vaccine.dose,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (done && vaccine.completedDate != null) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                        Text(
                          _formatDate(vaccine.completedDate!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (done)
              const Chip(
                label: Text('Yapıldı', style: TextStyle(fontSize: 10)),
                backgroundColor: AppColors.successLight,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            else if (overdue)
              const Chip(
                label: Text('Gecikmiş', style: TextStyle(fontSize: 10)),
                backgroundColor: AppColors.errorLight,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            // Silme
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 18,
              onSelected: (val) {
                if (val == 'delete') {
                  _viewModel.deleteVaccine(schedule.id, vaccine.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sil',
                        style: TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // Manuel Aşı Ekleme Butonu
  // ─────────────────────────────────────

  Widget _buildAddManualVaccineButton() {
    return OutlinedButton.icon(
      onPressed: () {
        if (_viewModel.schedule.isNotEmpty) {
          _showAddVaccineToScheduleDialog(context, _viewModel.schedule.first);
        }
      },
      icon: const Icon(Icons.vaccines_rounded),
      label: const Text('Takvime Manuel Aşı Ekle'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  // ─────────────────────────────────────
  // Hata Durumu
  // ─────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            _viewModel.errorMessage ?? 'Bir hata oluştu',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _viewModel.refresh,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DIALOGLAR
  // ═══════════════════════════════════════════════════════════════════

  /// Çocuk Ekleme Dialog
  void _showAddChildDialog(BuildContext context) {
    final nameController = TextEditingController();
    DateTime birthDate = DateTime.now();
    ChildGender gender = ChildGender.male;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.child_care_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Çocuk Ekle'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Çocuğun Adı *',
                    hintText: 'Örn: Ali',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Cinsiyet
                Row(
                  children: [
                    const Text(
                      'Cinsiyet:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ChoiceChip(
                      label: const Text('Erkek'),
                      selected: gender == ChildGender.male,
                      selectedColor: AppColors.infoLight,
                      onSelected: (_) {
                        setDialogState(() => gender = ChildGender.male);
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ChoiceChip(
                      label: const Text('Kız'),
                      selected: gender == ChildGender.female,
                      selectedColor: AppColors.errorLight,
                      onSelected: (_) {
                        setDialogState(() => gender = ChildGender.female);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Doğum Tarihi
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.cake_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Doğum Tarihi'),
                  subtitle: Text(
                    _formatDate(birthDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  trailing: const Icon(Icons.edit_calendar_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: birthDate,
                      firstDate: DateTime(2015),
                      lastDate: DateTime.now(),
                      helpText: 'Doğum tarihini seçin',
                    );
                    if (picked != null) {
                      setDialogState(() => birthDate = picked);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.catHealthBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Doğum tarihine göre aşı takvimi otomatik oluşturulacak.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Çocuğun adını girin')),
                  );
                  return;
                }

                _viewModel.addChild(
                  name: name,
                  birthDate: birthDate,
                  gender: gender,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  /// Belirli bir döneme aşı ekleme dialog
  void _showAddVaccineToScheduleDialog(
    BuildContext context,
    BabyVaccineSchedule schedule,
  ) {
    final nameController = TextEditingController();
    final doseController = TextEditingController();
    VaccineStatus initialStatus = VaccineStatus.pending;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('${schedule.period} — Aşı Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Aşı Adı *',
                    hintText: 'Örn: Hepatit A',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: doseController,
                  decoration: const InputDecoration(
                    labelText: 'Doz *',
                    hintText: 'Örn: 1. Doz',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Durum seçimi
                Row(
                  children: [
                    const Text(
                      'Durum:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ChoiceChip(
                      label: const Text('Bekliyor'),
                      selected: initialStatus == VaccineStatus.pending,
                      onSelected: (_) {
                        setDialogState(
                          () => initialStatus = VaccineStatus.pending,
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ChoiceChip(
                      label: const Text('Yapıldı'),
                      selected: initialStatus == VaccineStatus.completed,
                      selectedColor: AppColors.successLight,
                      onSelected: (_) {
                        setDialogState(
                          () => initialStatus = VaccineStatus.completed,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final dose = doseController.text.trim();
                if (name.isEmpty || dose.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aşı adı ve doz zorunludur')),
                  );
                  return;
                }

                final vaccine = Vaccine(
                  id: '',
                  name: name,
                  date: schedule.scheduledDate,
                  dose: dose,
                  status: initialStatus,
                  completedDate: initialStatus == VaccineStatus.completed
                      ? DateTime.now()
                      : null,
                );
                _viewModel.addManualVaccine(schedule.id, vaccine);
                Navigator.pop(ctx);
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  /// Çocuk seçenekleri (uzun basma)
  void _showChildOptionsSheet(Child child) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                child.gender == ChildGender.male
                    ? Icons.boy_rounded
                    : Icons.girl_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                child.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(child.ageText),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Çocuğu Sil',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteChildConfirmation(child);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteChildConfirmation(Child child) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çocuğu Sil'),
        content: Text(
          '${child.name} ve tüm aşı kayıtları silinecek. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              _viewModel.deleteChild(child.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // Yardımcı
  // ─────────────────────────────────────

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
