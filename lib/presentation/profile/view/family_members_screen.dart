import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/audience_helper.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/reminder.dart' show AudienceGroup;
import 'package:health_asistants/presentation/components/add_person_sheet.dart';
import 'package:health_asistants/presentation/profile/viewmodel/family_members_viewmodel.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyMembersViewModel>().load();
    });
  }

  Future<void> _confirmDelete(Person person) async {
    final viewModel = context.read<FamilyMembersViewModel>();
    final fullName = '${person.name} ${person.surname}'.trim();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kişiyi Sil'),
        content: Text('"$fullName" kişisini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await viewModel.deleteMember(person.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '$fullName silindi' : viewModel.errorMessage ?? 'Silinemedi'),
        backgroundColor: ok ? Colors.orange : Colors.red,
      ),
    );
  }

  Future<void> _addPerson() async {
    final viewModel = context.read<FamilyMembersViewModel>();
    final draft = await showAddPersonSheet(context);
    if (draft == null) return;
    final ok = await viewModel.addMember(draft);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '${draft.name} eklendi'
            : viewModel.errorMessage ?? 'Kişi eklenemedi'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Yakınlarım'), centerTitle: true),
      body: Consumer<FamilyMembersViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.status == FamilyMembersStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.status == FamilyMembersStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(viewModel.errorMessage ?? 'Bir hata oluştu'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: viewModel.load,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }
          if (viewModel.members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_outlined,
                      size: 64,
                      color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Henüz yakın eklenmemiş',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: viewModel.members.length,
            itemBuilder: (context, index) =>
                _buildMemberCard(viewModel.members[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPerson,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Kişi Ekle', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMemberCard(Person person) {
    final fullName = '${person.name} ${person.surname}'.trim();
    final group = audienceForPerson(person);
    return Dismissible(
      key: ValueKey(person.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        await _confirmDelete(person);
        return false; // silme viewmodel içinde yapıldı, Dismissible'ın listeden çıkarmasına gerek yok
      },
      child: GestureDetector(
        onLongPress: () => _confirmDelete(person),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                child: Text(
                  person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty ? 'İsimsiz' : fullName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(person.birthDate),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _audienceBadge(group),
            ],
          ),
        ),
      ),
    );
  }

  Widget _audienceBadge(AudienceGroup group) {
    final (String label, Color color) = switch (group) {
      AudienceGroup.adult => ('Yetişkin', AppColors.primaryBlue),
      AudienceGroup.elderly => ('Yaşlı', Colors.deepOrange),
      AudienceGroup.child => ('Çocuk', Colors.teal),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}
