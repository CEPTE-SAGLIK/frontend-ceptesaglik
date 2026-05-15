import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:health_asistants/core/utils/snackbar_helper.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/presentation/components/error_state_widget.dart';
import 'package:health_asistants/presentation/reminder/viewmodel/reminder_list_viewmodel.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/presentation/components/dialogs/confirm_dialog.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderListViewModel>().loadReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatırlatmalar'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Tamamlanan'),
          ],
        ),
        actions: [
          PopupMenuButton<ReminderType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              context.read<ReminderListViewModel>().setFilter(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Tümü')),
              const PopupMenuItem(
                value: ReminderType.medicine,
                child: Text('İlaçlar'),
              ),
              const PopupMenuItem(
                value: ReminderType.vaccine,
                child: Text('Aşılar'),
              ),
              const PopupMenuItem(
                value: ReminderType.appointment,
                child: Text('Randevular'),
              ),
              const PopupMenuItem(
                value: ReminderType.custom,
                child: Text('Diğer'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ReminderListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.status == ReminderListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.status == ReminderListStatus.error) {
            return ErrorStateWidget.fromMessage(
              viewModel.errorMessage ?? 'Bir hata oluştu',
              onRetry: viewModel.loadReminders,
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReminderList(viewModel.activeReminders, viewModel),
              _buildReminderList(viewModel.completedReminders, viewModel),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderList(
    List<Reminder> reminders,
    ReminderListViewModel viewModel,
  ) {
    if (reminders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Hatırlatma bulunamadı',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _ReminderCard(
            reminder: reminder,
            onToggle: () => viewModel.toggleComplete(reminder.id),
            onDelete: () =>
                _showDeleteConfirmation(context, viewModel, reminder),
            onEdit: () => _showEditReminderSheet(context, viewModel, reminder),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ReminderListViewModel viewModel,
    Reminder reminder,
  ) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Hatırlatmayı Sil',
      message:
          '"${reminder.title}" hatırlatmasını silmek istediğinizden emin misiniz?',
      confirmText: 'Sil',
      cancelText: 'İptal',
      isDestructive: true,
    );

    if (confirmed == true) {
      await viewModel.deleteReminder(reminder.id);
    }
  }

  void _showAddReminderSheet(BuildContext context) {
    SnackbarHelper.showInfo(context, 'Hatırlatma ekleme ekranı yakında');
  }

  void _showEditReminderSheet(
    BuildContext context,
    ReminderListViewModel viewModel,
    Reminder reminder,
  ) {
    final titleController = TextEditingController(text: reminder.title);
    final descController =
        TextEditingController(text: reminder.description ?? '');
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
            left: 24,
            right: 24,
            top: 24,
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(DateFormat('d MMMM yyyy, HH:mm', 'tr_TR')
                            .format(selectedDate)),
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
                        DropdownMenuItem(
                            value: RepeatType.none,
                            child: Text('Tekrar yok')),
                        DropdownMenuItem(
                            value: RepeatType.daily,
                            child: Text('Her gün')),
                        DropdownMenuItem(
                            value: RepeatType.weekly,
                            child: Text('Her hafta')),
                        DropdownMenuItem(
                            value: RepeatType.monthly,
                            child: Text('Her ay')),
                      ],
                      onChanged: (v) =>
                          setModalState(() => selectedRepeat = v!),
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
                      final success =
                          await viewModel.updateReminder(updated);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (success && context.mounted) {
                        SnackbarHelper.showSuccess(context, 'Hatırlatma güncellendi');
                      } else if (!success && context.mounted) {
                        SnackbarHelper.showError(
                          context,
                          viewModel.errorMessage ?? 'Güncellenemedi',
                        );
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
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm', 'tr_TR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(reminder.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) async => true,
        onDismissed: (_) => onDelete(),
        child: InkWell(
          onLongPress: onEdit,
          child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getTypeColor(reminder.type).withValues(alpha: 0.2),
            child: Icon(
              _getTypeIcon(reminder.type),
              color: _getTypeColor(reminder.type),
            ),
          ),
          title: Text(
            reminder.title,
            style: TextStyle(
              decoration: !reminder.isActive
                  ? TextDecoration.lineThrough
                  : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reminder.description != null)
                Text(
                  reminder.description!,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(reminder.dateTime),
                style: TextStyle(
                  fontSize: 12,
                  color: reminder.dateTime.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.grey,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.teal),
                onPressed: onEdit,
              ),
              Checkbox(
                value: !reminder.isActive,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          isThreeLine: reminder.description != null,
          ),   // ListTile
        ),     // InkWell
      ),       // Dismissible
    );         // Card
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
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

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medicine:
        return Icons.medication;
      case ReminderType.vaccine:
        return Icons.vaccines;
      case ReminderType.appointment:
        return Icons.medical_services;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }
}

