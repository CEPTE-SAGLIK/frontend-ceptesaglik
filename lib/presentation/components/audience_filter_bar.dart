import 'package:flutter/material.dart';
import 'package:health_asistants/data/model/reminder.dart' show AudienceGroup;

/// "Tümü / Yetişkin / Yaşlı / Çocuk" yaş grubu filtre çubuğu.
///
/// [selected] `null` ise "Tümü" seçili kabul edilir. Bir grup seçildiğinde
/// [onSelect] o grupla, "Tümü" seçildiğinde `null` ile çağrılır.
class AudienceFilterBar extends StatelessWidget {
  final AudienceGroup? selected;
  final void Function(AudienceGroup?) onSelect;
  final Color accentColor;

  const AudienceFilterBar({
    super.key,
    required this.selected,
    required this.onSelect,
    this.accentColor = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    const items = <(String, AudienceGroup?)>[
      ('Tümü', null),
      ('Yetişkin', AudienceGroup.adult),
      ('Yaşlı', AudienceGroup.elderly),
      ('Çocuk', AudienceGroup.child),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) {
            final isSelected = selected == item.$2;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(item.$1),
                selected: isSelected,
                selectedColor: accentColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => onSelect(item.$2),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
