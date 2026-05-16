import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:health_asistants/data/model/reminder.dart';
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage ?? 'Bir hata oluştu'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadReminders,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildAudienceFilter(viewModel),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReminderList(viewModel.activeReminders, viewModel),
                    _buildReminderList(
                        viewModel.completedReminders, viewModel),
                  ],
                ),
              ),
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

  Widget _buildAudienceFilter(ReminderListViewModel viewModel) {
    const options = <(AudienceGroup?, String)>[
      (null, 'Tümü'),
      (AudienceGroup.adult, 'Yetişkin'),
      (AudienceGroup.elderly, 'Yaşlı'),
      (AudienceGroup.child, 'Çocuk'),
    ];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = viewModel.audienceFilter == option.$1;
          return ChoiceChip(
            label: Text(option.$2),
            selected: selected,
            onSelected: (_) => viewModel.setAudienceFilter(option.$1),
          );
        },
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
    // TODO: Hatırlatma ekleme bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hatırlatma ekleme ekranı yakında')),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
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
              Row(
                children: [
                  Text(
                    dateFormat.format(reminder.dateTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: reminder.dateTime.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildAudienceBadge(reminder.audienceGroup),
                ],
              ),
            ],
          ),
          trailing: Checkbox(
            value: !reminder.isActive,
            onChanged: (_) => onToggle(),
          ),
          isThreeLine: reminder.description != null,
        ),
      ),
    );
  }

  Widget _buildAudienceBadge(AudienceGroup group) {
    final (String label, Color color) = switch (group) {
      AudienceGroup.adult => ('Yetişkin', AppColors.primaryBlue),
      AudienceGroup.elderly => ('Yaşlı', Colors.deepOrange),
      AudienceGroup.child => ('Çocuk', Colors.teal),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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

