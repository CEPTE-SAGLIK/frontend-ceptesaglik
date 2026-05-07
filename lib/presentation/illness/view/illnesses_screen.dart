import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/data/model/illness.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/presentation/illness/viewmodel/illness_viewmodel.dart';

String _statusLabel(IllnessStatus status) {
  switch (status) {
    case IllnessStatus.active:
      return 'Aktif';
    case IllnessStatus.recovered:
      return 'İyileşti';
    case IllnessStatus.monitoring:
      return 'Takipte';
  }
}

Color _statusColor(IllnessStatus status) {
  switch (status) {
    case IllnessStatus.active:
      return Colors.red;
    case IllnessStatus.recovered:
      return Colors.green;
    case IllnessStatus.monitoring:
      return Colors.orange;
  }
}

class IllnessesScreen extends StatefulWidget {
  const IllnessesScreen({super.key});

  @override
  State<IllnessesScreen> createState() => _IllnessesScreenState();
}

class _IllnessesScreenState extends State<IllnessesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IllnessViewModel>().loadPersons();
    });
  }

  void _showDeleteConfirmation(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: Text(
          '"$name" kaydını kalıcı olarak silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success =
                  await context.read<IllnessViewModel>().deleteIllness(id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kayıt başarıyla silindi'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddIllnessDialog(BuildContext context, IllnessViewModel viewModel) {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    IllnessStatus selectedStatus = IllnessStatus.active;
    Person? selectedPerson = viewModel.selectedPerson;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Yeni Hastalık Ekle',
                style: TextStyle(color: Colors.teal),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kişi seçimi (birden fazla kişi varsa)
                    if (viewModel.persons.length > 1) ...[
                      const Text(
                        'Kişi',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: viewModel.persons.map((p) {
                          final isSelected = selectedPerson?.id == p.id;
                          final isSelf = p.id == viewModel.persons.first.id;
                          return ChoiceChip(
                            label: Text(isSelf ? 'Ben' : p.name),
                            selected: isSelected,
                            selectedColor: Colors.teal,
                            labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.black87,
                              fontSize: 13,
                            ),
                            onSelected: (_) =>
                                setDialogState(() => selectedPerson = p),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Hastalık Adı (Örn: Grip)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<IllnessStatus>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Durum',
                        border: OutlineInputBorder(),
                      ),
                      items: IllnessStatus.values
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(_statusLabel(s)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) selectedStatus = v;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Doktor Notları (İsteğe Bağlı)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        selectedPerson != null) {
                      final success = await context
                          .read<IllnessViewModel>()
                          .addIllness(
                            nameController.text,
                            selectedStatus.name,
                            notesController.text.isEmpty
                                ? null
                                : notesController.text,
                            selectedPerson!.id,
                          );
                      if (success && context.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hastalıklarım'),
        backgroundColor: Colors.teal,
      ),
      body: Consumer<IllnessViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isPersonsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Kişi filtreleri
              if (viewModel.persons.length > 1)
                _PersonFilterBar(
                  persons: viewModel.persons,
                  selectedPerson: viewModel.selectedPerson,
                  onSelect: (p) => viewModel.selectPerson(p),
                ),

              // Hastalık listesi
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (viewModel.errorMessage != null) {
                      return Center(child: Text(viewModel.errorMessage!));
                    }
                    if (viewModel.illnesses.isEmpty) {
                      return const Center(
                        child: Text('Henüz bir hastalık kaydı bulunamadı.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: viewModel.illnesses.length,
                      itemBuilder: (context, index) {
                        final illness = viewModel.illnesses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.tealAccent,
                              child: Icon(Icons.medical_services,
                                  color: Colors.teal),
                            ),
                            title: Text(
                              illness.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Durum: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _statusColor(illness.status)
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _statusLabel(illness.status),
                                        style: TextStyle(
                                          color:
                                              _statusColor(illness.status),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (illness.doctorNotes != null)
                                  Text(
                                    'Not: ${illness.doctorNotes}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${illness.diagnosisDate.day}/${illness.diagnosisDate.month}/${illness.diagnosisDate.year}",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () => _showDeleteConfirmation(
                                      context, illness.id, illness.name),
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
      floatingActionButton: Consumer<IllnessViewModel>(
        builder: (context, viewModel, _) => FloatingActionButton(
          onPressed: () => _showAddIllnessDialog(context, viewModel),
          backgroundColor: Colors.teal,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _PersonFilterBar extends StatelessWidget {
  final List<Person> persons;
  final Person? selectedPerson;
  final void Function(Person) onSelect;

  const _PersonFilterBar({
    required this.persons,
    required this.selectedPerson,
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
            final isSelf = p.id == persons.first.id;
            final label = isSelf ? 'Ben' : p.name;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
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
