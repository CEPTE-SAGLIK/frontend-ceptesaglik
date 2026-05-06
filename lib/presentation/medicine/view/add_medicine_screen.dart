import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddMedicineViewModel>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'İlaç Kaydı Ekleme',
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
                SizedBox(height: AppSpacing.xxl),
                _buildFrequencyAndTimeRow(viewModel),
                SizedBox(height: AppSpacing.xxl),
                _buildNotesInput(viewModel),
                SizedBox(height: AppSpacing.xxxl + AppSpacing.xl),
                _buildSaveButton(context, viewModel),
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

  Widget _buildMedicineNameInput(AddMedicineViewModel viewModel) {
    return CustomTextInput(
      hintText: 'Örn: Parol (500 Mg)',
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

  Widget _buildNotesInput(AddMedicineViewModel viewModel) {
    return CustomInput(
      labelText: 'Ek Notlar',
      hintText: 'Örn: Uygulayan hekimin adı...',
      onChanged: viewModel.updateNotes,
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddMedicineViewModel viewModel,
  ) {
    final isLoading = viewModel.status == AddMedicineStatus.saving;

    return CustomButton(
      text: isLoading ? 'Kaydediliyor...' : 'İlaç Kaydını Tamamla',
      onPressed: isLoading
          ? () {}
          : () {
              _handleSave(context, viewModel);
            },
      backgroundColor: AppColors.primaryBlue,
      borderRadius: 30.0,
    );
  }

  void _handleSave(BuildContext context, AddMedicineViewModel viewModel) async {
    final medicine = await viewModel.saveMedicine();
    if (medicine != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.name} başarıyla kaydedildi'),
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
