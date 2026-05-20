import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/snackbar_helper.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/presentation/profile/viewmodel/family_viewmodel.dart';

class PersonDetailScreen extends StatefulWidget {
  final Person person;
  const PersonDetailScreen({super.key, required this.person});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FamilyViewModel>(
      builder: (context, viewModel, child) {
        final currentPerson = viewModel.children.firstWhere(
          (p) => p.id == widget.person.id,
          orElse: () => widget.person,
        );

        return Scaffold(
          appBar: AppBar(title: Text(currentPerson.name), centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPhysicalCard(currentPerson),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Aşı Takvimi',
                  Icons.vaccines,
                  onAddPressed: () => _showAddVaccineDialog(currentPerson),
                ),
                _buildVaccineList(currentPerson),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhysicalCard(Person person) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fiziksel Bilgiler', style: AppTextStyles.titleSmall),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                  onPressed: () => _showEditBottomSheet(person),
                ),
              ],
            ),
            const Divider(),
            _buildDetailRow('Boy', '${person.height ?? "-"} cm'),
            _buildDetailRow('Kilo', '${person.weight ?? "-"} kg'),
            _buildDetailRow(
                'Cinsiyet', person.gender == Gender.male ? 'Erkek' : 'Kadın'),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineList(Person person) {
    if (person.vaccines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Henüz aşı kaydı bulunmuyor.',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: person.vaccines.length,
      itemBuilder: (context, index) {
        final vaccine = person.vaccines[index];
        final isFuture = vaccine.date.isAfter(DateTime.now());
        return Card(
          child: ListTile(
            onLongPress: () =>
                _confirmDeleteVaccine(context, vaccine.id, vaccine.name),
            leading: Icon(
              isFuture ? Icons.schedule : Icons.check_circle,
              color: isFuture ? Colors.orange : Colors.green,
            ),
            title: Text(vaccine.name),
            subtitle: Text(
                'Tarih: ${vaccine.date.day}/${vaccine.date.month}/${vaccine.date.year}'),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon,
      {VoidCallback? onAddPressed}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.titleSmall),
        ]),
        if (onAddPressed != null)
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primaryBlue),
            onPressed: onAddPressed,
          ),
      ],
    );
  }

  void _showEditBottomSheet(Person person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhysicalInfoForm(person: person),
    );
  }

  void _confirmDeleteVaccine(
      BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aşıyı Sil'),
        content: Text("'$name' kaydını silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<FamilyViewModel>().deleteVaccineRecord(id);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddVaccineDialog(Person person) {
    const standardVaccines = [
      'Hepatit B', 'BCG (Verem)', 'DaBT-İPA-Hib',
      'KPA', 'KKK', 'OPA', 'Hepatit A', 'Suçiçeği',
    ];
    String? selectedVaccine = standardVaccines[0];
    DateTime selectedDate = DateTime.now();
    bool isOther = false;
    final otherController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni Aşı Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: isOther ? null : selectedVaccine,
                  items: [
                    ...standardVaccines.map(
                        (v) => DropdownMenuItem(value: v, child: Text(v))),
                    const DropdownMenuItem(
                        value: 'diğer', child: Text('Diğer')),
                  ],
                  onChanged: (val) => setDialogState(() {
                    isOther = val == 'diğer';
                    selectedVaccine = isOther ? null : val;
                  }),
                ),
                if (isOther)
                  TextField(
                    controller: otherController,
                    decoration:
                        const InputDecoration(labelText: 'Aşı Adı'),
                  ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Tarih: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                        const Icon(Icons.calendar_today,
                            size: 20, color: AppColors.primaryBlue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Vazgeç')),
            ElevatedButton(
              onPressed: () async {
                final name =
                    isOther ? otherController.text : selectedVaccine;
                if (name != null && name.isNotEmpty) {
                  await context
                      .read<FamilyViewModel>()
                      .addVaccineRecord(person.id, name, selectedDate);
                  if (context.mounted) Navigator.pop(dialogContext);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhysicalInfoForm extends StatefulWidget {
  final Person person;
  const _PhysicalInfoForm({required this.person});

  @override
  State<_PhysicalInfoForm> createState() => _PhysicalInfoFormState();
}

class _PhysicalInfoFormState extends State<_PhysicalInfoForm> {
  late TextEditingController heightController;
  late TextEditingController weightController;
  late Gender selectedGender;

  @override
  void initState() {
    super.initState();
    heightController =
        TextEditingController(text: widget.person.height?.toString() ?? '');
    weightController =
        TextEditingController(text: widget.person.weight?.toString() ?? '');
    selectedGender = widget.person.gender;
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fiziksel Bilgileri Düzenle',
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: 20),
              TextField(
                controller: heightController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Boy (cm)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    labelText: 'Kilo (kg)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              const Text('Cinsiyet',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              RadioGroup<Gender>(
                groupValue: selectedGender,
                onChanged: (v) {
                  if (v != null) setState(() => selectedGender = v);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<Gender>(
                        title: const Text('Erkek'),
                        value: Gender.male,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<Gender>(
                        title: const Text('Kadın'),
                        value: Gender.female,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<FamilyViewModel>(
                  builder: (context, vm, _) => ElevatedButton(
                    onPressed: vm.status == FamilyStatus.saving
                        ? null
                        : () async {
                            final h =
                                double.tryParse(heightController.text);
                            final w =
                                double.tryParse(weightController.text);
                            if (h != null && w != null) {
                              final success =
                                  await vm.updatePhysicalInfo(
                                      widget.person.id,
                                      h,
                                      w,
                                      selectedGender);
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                if (success) {
                                  // ignore: use_build_context_synchronously
                                  SnackbarHelper.showSuccess(context, 'Bilgiler güncellendi');
                                } else {
                                  // ignore: use_build_context_synchronously
                                  SnackbarHelper.showError(context, vm.errorMessage ?? 'Güncellenemedi');
                                }
                              }
                            } else {
                              SnackbarHelper.showError(context, 'Lütfen geçerli değerler girin');
                            }
                          },
                    child: Text(vm.status == FamilyStatus.saving
                        ? 'Kaydediliyor...'
                        : 'Bilgileri Kaydet'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
