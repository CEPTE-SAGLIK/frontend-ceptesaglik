import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/presentation/components/custom_selector_field.dart';

// Enum yapısını buraya taşıdık, böylece bileşenle birlikte taşınır.
enum Frequency {
  noRepeat("Tekrarı Yok"),
  onceDaily("Günde 1 kere"),
  twiceDaily("Günde 2 kere"),
  onceWeekly("Haftada 1 kere"),
  twiceWeekly("Haftada 2 kere"),
  onceMonthly("Ayda 1 kere"),
  other("Diğer...");

  final String label;
  const Frequency(this.label);
}

class FrequencySelector extends StatelessWidget {
  final String label;
  final Frequency? selectedFrequency;
  final ValueChanged<Frequency> onFrequencyChanged;

  const FrequencySelector({
    super.key,
    this.label = "Sıklık", // Varsayılan etiket
    required this.selectedFrequency,
    required this.onFrequencyChanged,
  });

  void _showFrequencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: Frequency.values.map((freq) {
              return ListTile(
                title: Text(freq.label),
                trailing: selectedFrequency == freq
                    ? Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  onFrequencyChanged(freq); // Seçimi dışarı bildir
                  Navigator.pop(context); // Menüyü kapat
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Senin hazır CustomSelectorField bileşenini kullanıyoruz
    return CustomSelectorField(
      label: label,
      value: selectedFrequency?.label ?? "Seçiniz",
      iconData: Icons.keyboard_arrow_down,
      onTap: () => _showFrequencyPicker(context),
    );
  }
}
