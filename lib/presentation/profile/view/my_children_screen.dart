import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/presentation/components/custom_button.dart';
import 'package:health_asistants/presentation/profile/viewmodel/family_viewmodel.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/presentation/profile/view/person_detail_screen.dart';

class MyChildrenScreen extends StatefulWidget {
  const MyChildrenScreen({super.key});

  @override
  State<MyChildrenScreen> createState() => _MyChildrenScreenState();
}

class _MyChildrenScreenState extends State<MyChildrenScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyViewModel>().loadChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Çocuklarım / Aile Üyeleri'),
        centerTitle: true,
      ),
      body: Consumer<FamilyViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.status == FamilyStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.children.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: viewModel.children.length,
            itemBuilder: (context, index) =>
                _buildChildCard(context, viewModel.children[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddChildModal(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care,
              size: 64, color: AppColors.primaryBlue.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Henüz bir çocuk kaydı yok', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          CustomButton(
            text: 'İlk Kaydı Ekle',
            onPressed: () => _showAddChildModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(BuildContext context, Person person) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PersonDetailScreen(person: person)),
        ),
        onLongPress: () => _showDeleteConfirmation(context, person),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
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
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text('Kayıtlı Profil',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Person person) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profili Sil'),
        content: Text(
            '${person.name} profilini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final vm = context.read<FamilyViewModel>();
              final success = await vm.deleteChild(person.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? '${person.name} başarıyla silindi.'
                      : 'Silme hatası: ${vm.errorMessage ?? 'İşlem başarısız'}'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ));
              }
            },
            child:
                const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddChildModal(BuildContext context) {
    final nameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text('Yeni Profil Ekle', style: AppTextStyles.titleMedium),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Çocuğun Adı',
                  hintText: 'Örn: Ata',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Consumer<FamilyViewModel>(
                builder: (context, vm, _) => vm.errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(vm.errorMessage!,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.error),
                            textAlign: TextAlign.center),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              Consumer<FamilyViewModel>(
                builder: (context, vm, _) => CustomButton(
                  text: vm.status == FamilyStatus.saving
                      ? 'Kaydediliyor...'
                      : 'Profili Kaydet',
                  onPressed: () {
                    if (vm.status == FamilyStatus.saving) return;
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      vm.addChild(name, DateTime.now()).then((success) {
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Profil başarıyla oluşturuldu.')),
                          );
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

