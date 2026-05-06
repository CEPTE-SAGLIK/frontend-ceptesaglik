import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/presentation/profile/viewmodel/my_vaccines_viewmodel.dart';

class AddVaccineScreen extends StatefulWidget {
  const AddVaccineScreen({super.key});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedPersonId;
  DateTime _selectedDate = DateTime.now();
  String _selectedFrequency = 'Tek Seferlik';

  final List<String> _frequencies = [
    'Tek Seferlik',
    '6 Ayda Bir',
    'Yıllık',
    '2 Yılda Bir',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyVaccinesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Aşı Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kişi Seçin',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPersonId,
                hint: const Text('Bir kişi seçin'),
                items: viewModel.peopleWithVaccines.map((p) {
                  return DropdownMenuItem<String>(
                    value: p.id,
                    child: Text(p.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPersonId = val),
                validator: (val) =>
                    val == null ? 'Lütfen bir kişi seçin' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              const Text('Aşı Adı',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Örn: Hepatit B',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Aşı adı gerekli' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              const Text('Sıklık',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                items: _frequencies.map((f) {
                  return DropdownMenuItem(value: f, child: Text(f));
                }).toList(),
                onChanged: (val) =>
                    setState(() => _selectedFrequency = val!),
                decoration:
                    const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: AppSpacing.md),

              const Text('Aşı Tarihi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 365)),
                    lastDate:
                        DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                title: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: viewModel.status == MyVaccinesStatus.loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedPersonId != null) {
                            final person =
                                viewModel.peopleWithVaccines.firstWhere(
                              (p) => p.id == _selectedPersonId,
                            );
                            final isChild =
                                person.relationship
                                    ?.toLowerCase()
                                    .contains('çocuk') ??
                                false;

                            final success = await viewModel.addNewVaccine(
                              targetId: person.id,
                              isChild: isChild,
                              name: _nameController.text,
                              date: _selectedDate,
                              frequency: _selectedFrequency,
                              description: _descController.text,
                            );

                            if (!mounted) return;
                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Aşı başarıyla eklendi!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Aşı eklenirken bir hata oluştu.')),
                              );
                            }
                          }
                        },
                  child: Text(
                    viewModel.status == MyVaccinesStatus.loading
                        ? 'Kaydediliyor...'
                        : 'KAYDET',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
