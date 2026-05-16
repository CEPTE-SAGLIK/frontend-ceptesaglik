import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/presentation/components/add_person_sheet.dart';
import 'package:health_asistants/presentation/components/custom_button.dart';
import 'package:health_asistants/presentation/components/custom_input.dart';
import 'package:health_asistants/presentation/components/custom_selector_field.dart';
import 'package:health_asistants/presentation/components/custom_text_input.dart';
import 'package:health_asistants/presentation/components/time_picker_selector.dart';
import 'package:health_asistants/presentation/medicine/viewmodel/add_medicine_viewmodel.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final medicine = ModalRoute.of(context)?.settings.arguments as Medicine?;
    final vm = context.read<AddMedicineViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (medicine != null) {
        _nameController.text = medicine.name;
        _notesController.text = medicine.notes ?? '';
        vm.loadForEdit(medicine);
      } else {
        vm.reset();
        vm.loadPersons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = ModalRoute.of(context)?.settings.arguments is Medicine;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          isEdit ? 'İlaç Düzenle' : 'İlaç Kaydı Ekleme',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AddMedicineViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.sm),
                _buildMedicineNameInput(viewModel),
                SizedBox(height: AppSpacing.lg),
                _buildAudienceSelector(viewModel),
                SizedBox(height: AppSpacing.md),
                _buildPersonSelector(viewModel),
                SizedBox(height: AppSpacing.xxl),
                _buildFrequencyAndTimeRow(viewModel),
                if (viewModel.frequencyType != FrequencyType.none) ...[
                  SizedBox(height: AppSpacing.lg),
                  _buildTimesPerDaySelector(viewModel),
                ],
                SizedBox(height: AppSpacing.xxl),
                _buildNotesInput(viewModel),
                SizedBox(height: AppSpacing.xxxl + AppSpacing.xl),
                _buildSaveButton(context, viewModel, isEdit),
                if (viewModel.status == AddMedicineStatus.error &&
                    viewModel.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      viewModel.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.statusError,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonSelector(AddMedicineViewModel viewModel) {
    final bool isEmpty = viewModel.filteredPersons.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
          child: Text(
            'Kişi',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
            child: Text(
              'Bu yaş grubunda kişi yok. "Ekle" ile yeni kişi ekleyebilirsiniz.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.filteredPersons.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == viewModel.filteredPersons.length) {
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
              final Person person = viewModel.filteredPersons[index];
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

  Future<void> _showAddPersonDialog(
      BuildContext context, AddMedicineViewModel viewModel) async {
    final draft = await showAddPersonSheet(context);
    if (draft != null) await viewModel.addPerson(draft);
  }

  Widget _buildAudienceSelector(AddMedicineViewModel viewModel) {
    const groups = <(AudienceGroup, String, IconData)>[
      (AudienceGroup.adult, 'Yetişkin', Icons.person),
      (AudienceGroup.elderly, 'Yaşlı', Icons.elderly),
      (AudienceGroup.child, 'Çocuk', Icons.child_care),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(
            'Yaş Grubu',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < groups.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.setAudienceGroup(groups[i].$1),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: viewModel.audienceGroup == groups[i].$1
                          ? Border.all(color: AppColors.primaryBlue, width: 2)
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
                      children: [
                        Icon(
                          groups[i].$3,
                          size: 22,
                          color: viewModel.audienceGroup == groups[i].$1
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          groups[i].$2,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: viewModel.audienceGroup == groups[i].$1
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: viewModel.audienceGroup == groups[i].$1
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMedicineNameInput(AddMedicineViewModel viewModel) {
    return CustomTextInput(
      hintText: 'Örn: Parol (500 Mg)',
      controller: _nameController,
      onChanged: viewModel.updateName,
    );
  }

  Widget _buildFrequencyAndTimeRow(AddMedicineViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: CustomSelectorField(
            label: 'Sıklık',
            value: viewModel.frequencyType.label,
            iconData: Icons.keyboard_arrow_down,
            onTap: () => _showFrequencyPicker(context, viewModel),
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: TimePickerSelector(
            label: 'Saat',
            selectedTime: viewModel.selectedTime,
            onTimeChanged: viewModel.updateTime,
          ),
        ),
      ],
    );
  }

  Widget _buildTimesPerDaySelector(AddMedicineViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(
            'Günlük Kullanım',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Row(
          children: [
            for (final count in [1, 2, 3, 4]) ...[
              if (count > 1) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => viewModel.updateTimesPerDay(count),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: viewModel.timesPerDay == count
                          ? Border.all(color: AppColors.primaryBlue, width: 2)
                          : Border.all(color: Colors.transparent),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.outlineVariant,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${count}x',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: viewModel.timesPerDay == count
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: viewModel.timesPerDay == count
                              ? AppColors.primaryBlue
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildNotesInput(AddMedicineViewModel viewModel) {
    return CustomInput(
      labelText: 'Ek Notlar',
      hintText: 'Örn: Uygulayan hekimin adı...',
      controller: _notesController,
      onChanged: viewModel.updateNotes,
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddMedicineViewModel viewModel,
    bool isEdit,
  ) {
    final isLoading = viewModel.status == AddMedicineStatus.saving;
    final label = isLoading
        ? (isEdit ? 'Güncelleniyor...' : 'Kaydediliyor...')
        : (isEdit ? 'Güncelle' : 'İlaç Kaydını Tamamla');

    return CustomButton(
      text: label,
      onPressed: isLoading
          ? () {}
          : () {
              _handleSave(context, viewModel, isEdit);
            },
      backgroundColor: AppColors.primaryBlue,
      borderRadius: 30.0,
    );
  }

  void _handleSave(BuildContext context, AddMedicineViewModel viewModel,
      bool isEdit) async {
    final medicine = await viewModel.saveMedicine();
    if (medicine != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? '${medicine.name} başarıyla güncellendi'
                : '${medicine.name} başarıyla kaydedildi',
          ),
          backgroundColor: AppColors.statusSuccess,
        ),
      );
      Navigator.pop(context, medicine);
    }
  }

  void _showFrequencyPicker(
    BuildContext context,
    AddMedicineViewModel viewModel,
  ) {
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
            children: viewModel.frequencyOptions.map((freq) {
              final isSelected = freq == viewModel.frequencyType;
              return ListTile(
                title: Text(
                  freq.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  viewModel.updateFrequency(freq);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
