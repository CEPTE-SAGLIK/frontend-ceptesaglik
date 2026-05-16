import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/core/utils/navigation/app_routes.dart';
import 'package:health_asistants/presentation/medicine/viewmodel/medicine_list_viewmodel.dart';
import 'package:health_asistants/presentation/components/audience_filter_bar.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/presentation/components/dialogs/confirm_dialog.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineListViewModel>().loadMedicines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İlaçlar')),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İlaç ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MedicineListViewModel>().search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                context.read<MedicineListViewModel>().search(value);
              },
            ),
          ),

          // Yaş grubu filtresi
          Consumer<MedicineListViewModel>(
            builder: (context, vm, _) => AudienceFilterBar(
              selected: vm.audienceFilter,
              onSelect: vm.setAudienceFilter,
              accentColor: AppColors.catMedicine,
            ),
          ),

          // İlaç listesi
          Expanded(
            child: Consumer<MedicineListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.status == MedicineListStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.status == MedicineListStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(viewModel.errorMessage ?? 'Bir hata oluştu'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: viewModel.loadMedicines,
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.medicines.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'İlaç bulunamadı',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Yeni ilaç eklemek için + butonuna tıklayın',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: viewModel.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: viewModel.medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = viewModel.medicines[index];
                      return _MedicineCard(
                        medicine: medicine,
                        onTap: () => _showMedicineDetails(context, medicine),
                        onDelete: () => _showDeleteConfirmation(
                          context,
                          viewModel,
                          medicine,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMedicine(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    MedicineListViewModel viewModel,
    Medicine medicine,
  ) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      itemName: medicine.name,
    );

    if (confirmed == true) {
      await viewModel.deleteMedicine(medicine.id);
    }
  }

  void _showMedicineDetails(BuildContext context, Medicine medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _MedicineDetailSheet(medicine: medicine),
    );
  }

  Future<void> _openAddMedicine(BuildContext context) async {
    await AppRoutes.push(context, AppRoutes.addMedicine);
    if (!context.mounted) return;
    context.read<MedicineListViewModel>().loadMedicines();
  }

}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MedicineCard({
    required this.medicine,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(medicine.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) async => true,
        onDismissed: (_) => onDelete(),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.catMedicine.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: AppColors.catMedicine),
          ),
          title: Text(
            medicine.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${medicine.frequencyType.label} - ${medicine.timesPerDay}x',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                _isActive ? 'Aktif' : 'Pasif',
                style: TextStyle(
                  fontSize: 12,
                  color: _isActive ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        ),
      ),
    );
  }

  bool get _isActive {
    final now = DateTime.now();
    return medicine.endDate == null || medicine.endDate!.isAfter(now);
  }
}

class _MedicineDetailSheet extends StatelessWidget {
  final Medicine medicine;

  const _MedicineDetailSheet({required this.medicine});

  bool get _isActive {
    final now = DateTime.now();
    return medicine.endDate == null || medicine.endDate!.isAfter(now);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // İlaç ikonu ve adı
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.catMedicine.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: AppColors.catMedicine,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isActive ? 'Aktif' : 'Pasif',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Detaylar
              if (medicine.usageInstructions != null) ...[
                _DetailItem(
                  icon: Icons.description,
                  label: 'Kullanım Talimatı',
                  value: medicine.usageInstructions!,
                ),
                const SizedBox(height: 16),
              ],

              _DetailItem(
                icon: Icons.schedule,
                label: 'Kullanım Sıklığı',
                value:
                    '${medicine.frequencyType.label} - Günde ${medicine.timesPerDay} kez',
              ),
              const SizedBox(height: 16),

              _DetailItem(
                icon: Icons.calendar_today,
                label: 'Başlangıç Tarihi',
                value: dateFormat.format(medicine.startDate),
              ),
              const SizedBox(height: 16),

              if (medicine.endDate != null) ...[
                _DetailItem(
                  icon: Icons.event,
                  label: 'Bitiş Tarihi',
                  value: dateFormat.format(medicine.endDate!),
                ),
                const SizedBox(height: 16),
              ],

              if (medicine.notes != null) ...[
                _DetailItem(
                  icon: Icons.note,
                  label: 'Notlar',
                  value: medicine.notes!,
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Düzenle butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final listScreenContext = context;
                    Navigator.pop(context);
                    // Sheet kapandıktan sonra düzenleme ekranını aç
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!listScreenContext.mounted) return;
                      AppRoutes.push(
                        listScreenContext,
                        AppRoutes.addMedicine,
                        arguments: medicine,
                      ).then((_) {
                        if (listScreenContext.mounted) {
                          listScreenContext
                              .read<MedicineListViewModel>()
                              .loadMedicines();
                        }
                      });
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Düzenle'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
