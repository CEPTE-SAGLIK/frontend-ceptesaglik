import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/presentation/components/custom_button.dart';
import 'package:health_asistants/presentation/components/custom_text_input.dart';
import 'package:health_asistants/presentation/components/time_picker_selector.dart';
import 'package:health_asistants/presentation/components/frequency_selector.dart';
import 'package:health_asistants/presentation/reminder/viewmodel/add_reminder_viewmodel.dart';

class AddReminderScreen extends StatelessWidget {
  const AddReminderScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
    // main.dart'taki singleton AddReminderViewModel'i kullan
    return const _AddReminderContent();
  }
}

class _AddReminderContent extends StatefulWidget {
  const _AddReminderContent();

  @override
  State<_AddReminderContent> createState() => _AddReminderContentState();
}

class _AddReminderContentState extends State<_AddReminderContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<AddReminderViewModel>();
      vm.reset();
      vm.loadPersons();
    });
  }

  Future<void> _handleSave(
    BuildContext context,
    AddReminderViewModel viewModel,
  ) async {
    final reminder = await viewModel.saveReminder();
    if (reminder != null && context.mounted) {
      Navigator.pop(context, reminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddReminderViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            title: Text(
              "Hatırlatma Ekle",
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.black,
              ),
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // 1. İSİM GİRİŞİ
                CustomTextInput(
                  hintText: "Örn: Grip Aşısı",
                  onChanged: viewModel.setTitle,
                ),

                // 1b. KİŞİ SEÇİMİ (birden fazla kişi varsa)
                if (viewModel.persons.length > 1) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildPersonSelector(viewModel),
                ],

                const SizedBox(height: AppSpacing.xl),

                // 2. TARİH SEÇİCİ
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: viewModel.selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      helpText: 'Hatırlatma tarihini seçin',
                    );
                    if (picked != null) viewModel.setSelectedDate(picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.outlineVariant,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tarih',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              _formatDate(viewModel.selectedDate),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.edit_calendar_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 3. SIKLIK ve SAAT
                Row(
                  children: [
                    Expanded(
                      child: FrequencySelector(
                        selectedFrequency: _getFrequencyFromLabel(
                          viewModel.selectedFrequencyLabel,
                        ),
                        onFrequencyChanged: (newFreq) {
                          if (newFreq == Frequency.other) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Özel sıklık seçeneği yakında eklenecek.',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          viewModel.setRepeatTypeFromFrequency(newFreq.label);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: TimePickerSelector(
                        label: "Saat",
                        selectedTime: viewModel.selectedTime,
                        onTimeChanged: viewModel.setSelectedTime,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // 3. HATIRLATMA TÜRÜ IZGARASI
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4.0,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    "Hatırlatma Türü",
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.reminderTypes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final type = viewModel.reminderTypes[index];
                    final isSelected = viewModel.selectedTypeIndex == index;

                    return GestureDetector(
                      onTap: () => viewModel.setSelectedTypeIndex(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                )
                              : Border.all(color: Colors.transparent),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.outlineVariant,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: type.color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                type.icon,
                                color: type.color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              type.label,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                // 4. BUTON
                CustomButton(
                  text: viewModel.status == AddReminderStatus.saving
                      ? "Kaydediliyor..."
                      : "Hatırlatmayı Ekle",
                  onPressed: () {
                    if (viewModel.status != AddReminderStatus.saving) {
                      _handleSave(context, viewModel);
                    }
                  },
                  backgroundColor: AppColors.primaryBlue,
                  borderRadius: 30,
                ),

                // Hata mesajı
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    viewModel.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonSelector(AddReminderViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
          child: Text(
            "Kişi",
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.persons.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == viewModel.persons.length) {
                return GestureDetector(
                  onTap: () => _showAddPersonDialog(context, viewModel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primaryBlue),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
                        const SizedBox(width: 4),
                        Text('Ekle',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.primaryBlue)),
                      ],
                    ),
                  ),
                );
              }
              final Person person = viewModel.persons[index];
              final bool isSelected =
                  viewModel.selectedPerson?.id == person.id;
              final bool isSelf = person.id == viewModel.selfPerson?.id;
              final String label = isSelf ? 'Ben' : person.name;
              return ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 13)),
                selected: isSelected,
                onSelected: (_) => viewModel.selectPerson(person),
                selectedColor: AppColors.primaryBlue,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                ),
                side: isSelected
                    ? BorderSide.none
                    : const BorderSide(color: Colors.grey),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddPersonDialog(
      BuildContext context, AddReminderViewModel viewModel) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kişi Ekle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ad Soyad'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              Navigator.pop(ctx);
              if (name.isNotEmpty) await viewModel.addPerson(name);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Frequency? _getFrequencyFromLabel(String? label) {
    if (label == null) return null;
    try {
      return Frequency.values.firstWhere((f) => f.label == label);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

