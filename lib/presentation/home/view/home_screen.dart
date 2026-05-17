import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// Renkler ve Sabitler
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/navigation/app_routes.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
// Modeller ve ViewModel
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/core/error/app_error.dart';
import 'package:health_asistants/core/utils/snackbar_helper.dart';
import 'package:health_asistants/presentation/components/empty_state_widget.dart';
import 'package:health_asistants/presentation/components/error_state_widget.dart';
import 'package:health_asistants/presentation/home/viewmodel/home_viewmodel.dart';
import 'package:health_asistants/presentation/home/view/gemini_assistant_sheet.dart';
import 'package:health_asistants/presentation/navigator/viewmodel/navigator_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NavigatorViewModel _navigatorViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigatorViewModel = context.read<NavigatorViewModel>();
      _navigatorViewModel.addListener(_onTabChanged);
      context.read<HomeViewModel>().loadHomeData();
    });
  }

  @override
  void dispose() {
    _navigatorViewModel.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (_navigatorViewModel.currentTab == NavigationTab.home) {
      context.read<HomeViewModel>().loadHomeData();
    }
  }

  void _showEditReminderSheet(BuildContext context, Reminder reminder) {
    final viewModel = context.read<HomeViewModel>();
    final titleController = TextEditingController(text: reminder.title);
    final descController = TextEditingController(text: reminder.description ?? '');
    DateTime selectedDate = reminder.dateTime;
    RepeatType selectedRepeat = reminder.repeatType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hatırlatmayı Düzenle',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama (opsiyonel)',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date == null) return;
                    if (!ctx.mounted) return;
                    final time = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time != null) {
                      setModalState(() => selectedDate = DateTime(
                            date.year, date.month, date.day,
                            time.hour, time.minute,
                          ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(DateFormat('d MMMM yyyy, HH:mm', 'tr_TR').format(selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RepeatType>(
                      value: selectedRepeat,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: RepeatType.none, child: Text('Tekrar yok')),
                        DropdownMenuItem(value: RepeatType.daily, child: Text('Her gün')),
                        DropdownMenuItem(value: RepeatType.weekly, child: Text('Her hafta')),
                        DropdownMenuItem(value: RepeatType.monthly, child: Text('Her ay')),
                      ],
                      onChanged: (v) => setModalState(() => selectedRepeat = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;
                      final updated = reminder.copyWith(
                        title: titleController.text.trim(),
                        description: descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                        dateTime: selectedDate,
                        repeatType: selectedRepeat,
                      );
                      final success = await viewModel.updateReminder(updated);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (success && context.mounted) {
                        SnackbarHelper.showSuccess(context, 'Hatırlatma güncellendi');
                      }
                    },
                    child: const Text('Güncelle',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,

      // 1. BUTON TEKRAR BURADA (SAĞ ALT KÖŞE)
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "gemini_btn",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const GeminiAssistantSheet(),
              );
            },
            backgroundColor: Colors.purple,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add_btn",
            onPressed: () async {
              await AppRoutes.push(context, AppRoutes.addReminder);
              if (context.mounted) {
                context.read<HomeViewModel>().loadHomeData();
              }
            },
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),

      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.status == HomeStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.status == HomeStatus.error) {
              return _buildErrorState(viewModel);
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. ÜST KISIM (HEADER)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _buildHeader(viewModel),
                    ),
                    const SizedBox(height: 30),

                    // 2. ÖZET KARTLARI
                    _buildSummaryCards(viewModel),
                    const SizedBox(height: 30),

                    // 3. BUGÜNKÜ HATIRLATMALAR
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _buildTodayReminders(context, viewModel),
                    ),
                    const SizedBox(height: 30),

                    // 4. RANDEVULAR
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _buildUpcomingAppointments(context, viewModel),
                    ),

                    // 2. ALTAKİ BUTON KALDIRILDI
                    const SizedBox(
                      height: 80,
                    ), // Fab ile içerik çakışmasın diye biraz boşluk
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  Widget _buildHeader(HomeViewModel viewModel) {
    final greeting = _getGreeting();
    final personName = viewModel.personName;
    final today = DateFormat(
      'd MMMM yyyy, EEEE',
      'tr_TR',
    ).format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Merhaba $personName!',
              style: AppTextStyles.headingLarge.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Text('👋', style: TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            today,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(HomeViewModel viewModel) {
    final allTodayItems = _getAllTodayItems(viewModel);
    final medicineCount = allTodayItems
        .where((r) => r.type == ReminderType.medicine)
        .length;
    final vaccineCount = allTodayItems
        .where((r) => r.type == ReminderType.vaccine)
        .length;
    final appointmentCount = allTodayItems
        .where((r) => r.type == ReminderType.appointment)
        .length;
    final otherCount = allTodayItems
        .where((r) => r.type == ReminderType.custom)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Bugünün Özeti',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              _SummaryCard(
                icon: Icons.medication_rounded,
                count: medicineCount,
                label: 'İlaç',
                color: AppColors.catMedicine,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                icon: Icons.vaccines_rounded,
                count: vaccineCount,
                label: 'Aşı',
                color: AppColors.catHealth,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                icon: Icons.event_rounded,
                count: appointmentCount,
                label: 'Randevu',
                color: AppColors.catTeeth,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                icon: Icons.dashboard_rounded,
                count: otherCount,
                label: 'Diğer',
                color: AppColors.catGeneral,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayReminders(BuildContext context, HomeViewModel viewModel) {
    final allToday = _getAllTodayItems(viewModel);
    final todayReminders = allToday
        .where((r) => r.type != ReminderType.appointment)
        .toList();
    final timeFormat = DateFormat('HH:mm', 'tr_TR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⏰ Bugünkü Hatırlatmalar',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (todayReminders.isEmpty)
          EmptyStateWidget.noRemindersToday()
        else
          ...todayReminders
              .map(
                (reminder) => _ReminderTile(
                  key: Key(reminder.id),
                  reminder: reminder,
                  timeText: timeFormat.format(reminder.dateTime),
                  onEdit: () => _showEditReminderSheet(context, reminder),
                  onToggle: () => viewModel.toggleReminderComplete(reminder.id),
                  onDelete: () async {
                    final ok = await viewModel.deleteReminder(reminder.id);
                    if (!context.mounted) return false;
                    if (ok) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${reminder.title} silindi"),
                          action: SnackBarAction(
                            label: 'Geri Al',
                            textColor: AppColors.primaryBlue,
                            onPressed: () => viewModel.restoreReminder(reminder),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    } else {
                      SnackbarHelper.showError(context, 'Silinemedi, tekrar deneyin');
                    }
                    return ok;
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildUpcomingAppointments(
    BuildContext context,
    HomeViewModel viewModel,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final appointments = viewModel.upcomingReminders
        .where((r) => r.type == ReminderType.appointment && r.isActive)
        .where((r) => r.dateTime.compareTo(todayStart) >= 0)
        .toList();
    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (appointments.isEmpty) return const SizedBox.shrink();

    final dateFormat = DateFormat('d MMM', 'tr_TR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📅 Yaklaşan Randevular',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...appointments
            .take(5)
            .map(
              (appointment) => _AppointmentTile(
                key: Key(appointment.id),
                title: appointment.title,
                subtitle: appointment.description,
                dateText: dateFormat.format(appointment.dateTime),
                onDelete: () async {
                  final ok = await viewModel.deleteReminder(appointment.id);
                  if (!context.mounted) return false;
                  if (ok) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${appointment.title} silindi"),
                        action: SnackBarAction(
                          label: 'Geri Al',
                          textColor: AppColors.primaryBlue,
                          onPressed: () => viewModel.restoreReminder(appointment),
                        ),
                      ),
                    );
                  } else {
                    SnackbarHelper.showError(context, 'Silinemedi, tekrar deneyin');
                  }
                  return ok;
                },
              ),
            ),
      ],
    );
  }

  Widget _buildErrorState(HomeViewModel viewModel) {
    final appError = viewModel.errorMessage.asAppError ??
        AppError.unknown('Bir hata oluştu');
    return ErrorStateWidget(
      error: appError,
      onRetry: viewModel.refreshData,
    );
  }

  List<Reminder> _getAllTodayItems(HomeViewModel viewModel) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return viewModel.upcomingReminders
        .where((r) => _occursOnDay(r, today))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  bool _occursOnDay(Reminder r, DateTime day) {
    final start = DateTime(r.dateTime.year, r.dateTime.month, r.dateTime.day);
    if (day.isBefore(start)) return false;
    switch (r.repeatType) {
      case RepeatType.none:
        return day == start;
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return day.difference(start).inDays % 7 == 0;
      case RepeatType.monthly:
        return day.day == start.day;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Günaydın ☀️';
    if (hour >= 12 && hour < 17) return 'Tünaydın 🌤️';
    if (hour >= 17 && hour < 21) return 'İyi Akşamlar 🌙';
    return 'İyi Geceler ✨';
  }
}

// =====================
// CUSTOM WIDGETS
// =====================

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$count',
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final String timeText;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final Future<bool> Function() onDelete;

  const _ReminderTile({
    super.key,
    required this.reminder,
    required this.timeText,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = !reminder.isActive;

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await onDelete();
      },
      onDismissed: (direction) {
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isCompleted
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
            border: isCompleted
                ? Border.all(color: AppColors.outline.withValues(alpha: 0.5))
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.textSecondary.withValues(alpha: 0.1)
                      : _getTypeColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: isCompleted
                      ? AppColors.textSecondary
                      : _getTypeColor(),
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Builder(builder: (context) {
                  final sepIdx = reminder.title.indexOf(' — ');
                  final displayTitle = sepIdx > 0
                      ? reminder.title.substring(sepIdx + 3)
                      : reminder.title;
                  final personName =
                      sepIdx > 0 ? reminder.title.substring(0, sepIdx) : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (personName != null) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.textSecondary.withValues(alpha: 0.1)
                                : _getTypeColor().withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            personName,
                            style: TextStyle(
                              fontSize: 10,
                              color: isCompleted
                                  ? AppColors.textSecondary
                                  : _getTypeColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (reminder.description != null)
                        Text(
                          reminder.description!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  );
                }),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                timeText,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? AppColors.textSecondary
                      : _getTypeColor(),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, size: 18, color: Colors.teal),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isCompleted ? AppColors.success : AppColors.outline,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (reminder.type) {
      case ReminderType.medicine:
        return AppColors.catMedicine;
      case ReminderType.vaccine:
        return AppColors.catHealth;
      case ReminderType.appointment:
        return AppColors.catTeeth;
      case ReminderType.custom:
        return AppColors.catGeneral;
    }
  }

  IconData _getTypeIcon() {
    switch (reminder.type) {
      case ReminderType.medicine:
        return Icons.medication_rounded;
      case ReminderType.vaccine:
        return Icons.vaccines_rounded;
      case ReminderType.appointment:
        return Icons.medical_services_rounded;
      case ReminderType.custom:
        return Icons.notifications_rounded;
    }
  }
}

class _AppointmentTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String dateText;
  final Future<bool> Function() onDelete;

  const _AppointmentTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.dateText,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await onDelete();
      },
      onDismissed: (direction) {
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: AppColors.catTeeth, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_rounded,
              color: AppColors.catTeeth,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Builder(builder: (context) {
                final sepIdx = title.indexOf(' — ');
                final displayTitle =
                    sepIdx > 0 ? title.substring(sepIdx + 3) : title;
                final personName =
                    sepIdx > 0 ? title.substring(0, sepIdx) : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (personName != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.catTeeth.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          personName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.catTeeth,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                );
              }),
            ),
            Text(
              dateText,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.catTeeth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

