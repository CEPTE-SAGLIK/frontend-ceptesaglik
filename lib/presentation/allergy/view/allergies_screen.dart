import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      context.read<AllergyViewModel>().fetchAllergies();
    });
  }

  // Silme Onay Kutusu
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
              final success = await context
                  .read<AllergyViewModel>()
                  .deleteAllergy(id);
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alerji silindi'),
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

  // Ekleme Penceresi (Zaten Yapmıştık)
  void _showAddAllergyDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Yeni Alerji Ekle',
          style: TextStyle(color: Colors.teal),
        ),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Alerji Adı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final success = await context
                    .read<AllergyViewModel>()
                    .addAllergy(nameController.text);
                if (success && context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
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
        onPressed: () => _showAddAllergyDialog(context),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<AllergyViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (viewModel.allergies.isEmpty)
            return const Center(child: Text('Alerji bulunamadı.'));

          return ListView.builder(
            itemCount: viewModel.allergies.length,
            itemBuilder: (context, index) {
              final allergy = viewModel.allergies[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.warning, color: Colors.orange),
                  ),
                  title: Text(
                    allergy.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Kayıt: ${allergy.createdDate.day}/${allergy.createdDate.month}/${allergy.createdDate.year}',
                  ),
                  trailing: IconButton(
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
