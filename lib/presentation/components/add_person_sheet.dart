import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/data/model/person.dart';

/// Ortak "Kişi Ekle" alt sayfası — ad, soyad, doğum tarihi ve cinsiyet toplar.
/// Doğum tarihi yaş grubu (yetişkin/yaşlı/çocuk) hesabı için zorunludur.
/// Eklenen kişiyi (id/userId boş) döndürür; iptal edilirse null.
Future<Person?> showAddPersonSheet(BuildContext context) {
  return showModalBottomSheet<Person>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AddPersonSheet(),
  );
}

class _AddPersonSheet extends StatefulWidget {
  const _AddPersonSheet();

  @override
  State<_AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends State<_AddPersonSheet> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  DateTime? _birthDate;
  Gender _gender = Gender.male;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Doğum tarihini seçin',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Lütfen ad girin');
      return;
    }
    if (_birthDate == null) {
      setState(() => _error = 'Lütfen doğum tarihi seçin');
      return;
    }
    Navigator.pop(
      context,
      Person(
        id: '',
        userId: '',
        name: name,
        surname: _surnameController.text.trim(),
        birthDate: _birthDate!,
        gender: _gender,
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  InputDecoration _fieldDecoration(String label, String hint) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Kişi Ekle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: _fieldDecoration('Ad', 'Örn: Ata'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _surnameController,
              textCapitalization: TextCapitalization.words,
              decoration: _fieldDecoration('Soyad', 'Örn: Yılmaz'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _fieldDecoration('Doğum Tarihi', ''),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    Text(
                      _birthDate == null
                          ? 'Tarih seçin'
                          : _formatDate(_birthDate!),
                      style: TextStyle(
                        color: _birthDate == null
                            ? Colors.grey.shade600
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Cinsiyet',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final g in Gender.values) ...[
                  if (g != Gender.values.first) const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(g == Gender.male ? 'Erkek' : 'Kadın'),
                      selected: _gender == g,
                      onSelected: (_) => setState(() => _gender = g),
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: _gender == g
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
