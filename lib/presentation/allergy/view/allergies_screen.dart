import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/snackbar_helper.dart';
import 'package:health_asistants/data/model/allergy.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/presentation/allergy/viewmodel/allergy_viewmodel.dart';

class AllergiesScreen extends StatefulWidget {
  const AllergiesScreen({super.key});

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllergyViewModel>().loadPersons();
    });
  }

  Future<void> _showEditAllergySheet(
      BuildContext context, Allergy allergy) async {
    final nameController = TextEditingController(text: allergy.name);
    AllergyLevel selectedLevel = allergy.level;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
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
                      const Text(
                        'Alerjiyi Düzenle',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Alerji Adı *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Şiddet',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AllergyLevel>(
                        value: selectedLevel,
                        isExpanded: true,
                        items: AllergyLevel.values
                            .map((l) => DropdownMenuItem(
                                value: l, child: Text(l.label)))
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => selectedLevel = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          SnackbarHelper.showError(ctx, 'Lütfen alerji adını girin');
                          return;
                        }
                        final success = await context
                            .read<AllergyViewModel>()
                            .updateAllergy(
                              allergy.id,
                              nameController.text.trim(),
                              level: selectedLevel,
                            );
                        if (success && ctx.mounted) {
                          Navigator.pop(ctx);
                          if (context.mounted) {
                            SnackbarHelper.showSuccess(context, 'Alerji güncellendi');
                          }
                        }
                      },
                      child: const Text(
                        'Güncelle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alerjiyi Sil'),
        content: Text('"$name" kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success =
                  await context.read<AllergyViewModel>().deleteAllergy(id);
              if (success && context.mounted) {
                Navigator.pop(context);
                SnackbarHelper.showSuccess(context, 'Alerji silindi');
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddAllergySheet(BuildContext context) async {
    final viewModel = context.read<AllergyViewModel>();
    await viewModel.loadPersons();
    if (!context.mounted) return;

    final nameController = TextEditingController();
    AllergyLevel selectedLevel = AllergyLevel.mild;
    Person? selectedPerson = viewModel.selfPerson;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
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
                      const Text(
                        'Yeni Alerji Ekle',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kişi Seçici
                  if (viewModel.persons.length > 1) ...[
                    const Text('Kişi',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.persons.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (ctx, index) {
                          final person = viewModel.persons[index];
                          final isSelected =
                              selectedPerson?.id == person.id;
                          final isSelf =
                              person.id == viewModel.selfPerson?.id;
                          return ChoiceChip(
                            label: Text(
                              isSelf ? 'Ben' : person.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                            selected: isSelected,
                            onSelected: (_) => setModalState(
                                () => selectedPerson = person),
                            selectedColor: Colors.teal,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 13,
                            ),
                            side: isSelected
                                ? BorderSide.none
                                : const BorderSide(color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text('Alerji Adı *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Örn: Fıstık, Polen, İlaç',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Şiddet',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AllergyLevel>(
                        value: selectedLevel,
                        isExpanded: true,
                        items: AllergyLevel.values
                            .map((l) => DropdownMenuItem(
                                value: l, child: Text(l.label)))
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => selectedLevel = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          SnackbarHelper.showError(ctx, 'Lütfen alerji adını girin');
                          return;
                        }
                        final success = await context
                            .read<AllergyViewModel>()
                            .addAllergy(
                              nameController.text.trim(),
                              level: selectedLevel,
                              targetPersonId: selectedPerson?.id,
                            );
                        if (success && ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerjilerim'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAllergySheet(context),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AllergyViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isPersonsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Kişi filtre çubuğu
              if (viewModel.persons.length > 1)
                _PersonFilterBar(
                  persons: viewModel.persons,
                  selectedPerson: viewModel.selectedPerson,
                  selfPerson: viewModel.selfPerson,
                  onSelect: (p) => viewModel.selectPerson(p),
                ),

              // Alerji listesi
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (viewModel.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (viewModel.allergies.isEmpty) {
                      return const Center(
                          child: Text('Alerji bulunamadı.'));
                    }

                    return ListView.builder(
                      itemCount: viewModel.allergies.length,
                      itemBuilder: (context, index) {
                        final allergy = viewModel.allergies[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child:
                                  Icon(Icons.warning, color: Colors.orange),
                            ),
                            title: Text(
                              allergy.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Şiddet: ${allergy.level.label} · ${allergy.createdDate.day}/${allergy.createdDate.month}/${allergy.createdDate.year}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () =>
                                      _showEditAllergySheet(context, allergy),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _showDeleteConfirmation(
                                    context,
                                    allergy.id,
                                    allergy.name,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PersonFilterBar extends StatelessWidget {
  final List<Person> persons;
  final Person? selectedPerson;
  final Person? selfPerson;
  final void Function(Person) onSelect;

  const _PersonFilterBar({
    required this.persons,
    required this.selectedPerson,
    required this.selfPerson,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: persons.map((p) {
            final isSelected = selectedPerson?.id == p.id;
            final isSelf = p.id == selfPerson?.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(isSelf ? 'Ben' : p.name),
                selected: isSelected,
                selectedColor: Colors.teal,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => onSelect(p),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
