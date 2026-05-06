import 'package:flutter/material.dart';
import 'package:health_asistants/presentation/components/custom_selector_field.dart';

class TimePickerSelector extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay>
  onTimeChanged; // Seçilen saati dışarıya bildirmek için

  const TimePickerSelector({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      onTimeChanged(time); // Yeni saati ana sayfaya gönder
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSelectorField(
      label: label,
      // Saati ekranda gösterme formatı (Örn: 14:05 veya --:--)
      value: selectedTime != null
          ? "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}"
          : "--:--",
      iconData: Icons.access_time,
      onTap: () => _showTimePicker(context),
    );
  }
}
