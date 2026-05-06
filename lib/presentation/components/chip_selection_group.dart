import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/presentation/components/category_chip.dart';
import 'package:health_asistants/presentation/components/add_option_button.dart';

class ChipSelectionGroup extends StatelessWidget {
  final String title;
  final List<String> allItems;
  final List<String> selectedItems;
  final Function(String) onToggle;
  final VoidCallback onAddTap;

  const ChipSelectionGroup({
    super.key,
    required this.title,
    required this.allItems,
    required this.selectedItems,
    required this.onToggle,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            ...allItems.map(
              (item) => CategoryChip(
                label: item,
                isSelected: selectedItems.contains(item),
                onTap: () => onToggle(item),
              ),
            ),
            AddOptionButton(onTap: onAddTap),
          ],
        ),
      ],
    );
  }
}
