import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/presentation/components/custom_button.dart';
import 'package:health_asistants/presentation/components/custom_input.dart';
import 'package:health_asistants/presentation/components/custom_selector_field.dart';
import 'package:health_asistants/presentation/components/custom_date_picker.dart';
import 'package:health_asistants/presentation/components/section_header.dart';
import 'package:health_asistants/presentation/components/category_chip.dart';
import 'package:health_asistants/presentation/record/viewmodel/medicine_record_viewmodel.dart';

class MedicineView extends StatelessWidget {
  const MedicineView({super.key});

  @override
  Widget build(BuildContext context) {
    // main.dart'taki singleton MedicineRecordViewModel'i kullan
    return const _MedicineViewContent();
  }
}

class _MedicineViewContent extends StatelessWidget {
  const _MedicineViewContent();

  Future<void> _selectStartDate(
    BuildContext context,
    MedicineRecordViewModel viewModel,
  ) async {
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: viewModel.startDate,
    );
    if (picked != null) {
      viewModel.setStartDate(picked);
    }
  }

  Future<void> _selectEndDate(
    BuildContext context,
    MedicineRecordViewModel viewModel,
  ) async {
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate:
          viewModel.endDate ?? DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      viewModel.setEndDate(picked);
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    MedicineRecordViewModel viewModel,
  ) async {
    final medicine = await viewModel.saveMedicine();
    if (medicine != null && context.mounted) {
      Navigator.pop(context, medicine);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineRecordViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              "İlaç Kaydı Ekleme",
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İlaç Adı
                const SectionHeader(title: "İlaç Adı"),
                CustomInput(
                  labelText: "Örn: Parol (500mg)",
                  onChanged: viewModel.setName,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Kullanım Talimatı
                const SectionHeader(title: "Kullanım Talimatı (Opsiyonel)"),
                CustomInput(
                  labelText: "Örn: Yemeklerden sonra",
                  onChanged: viewModel.setUsageInstructions,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Kullanım Sıklığı
                const SectionHeader(title: "Kullanım Sıklığı"),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: viewModel.frequencyOptions.map((freq) {
                    final isSelected = viewModel.frequencyType == freq;
                    return CategoryChip(
                      label: freq.label,
                      isSelected: isSelected,
                      onTap: () => viewModel.setFrequencyType(freq),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Günde Kaç Kez
                const SectionHeader(title: "Günde Kaç Kez"),
                Row(
                  children: [1, 2, 3, 4].map((times) {
                    final isSelected = viewModel.timesPerDay == times;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: CategoryChip(
                        label: "$times",
                        isSelected: isSelected,
                        onTap: () => viewModel.setTimesPerDay(times),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Başlangıç Tarihi
                const SectionHeader(title: "Başlangıç Tarihi"),
                CustomSelectorField(
                  label: "Tarih Seçin",
                  value: viewModel.startDateText,
                  iconData: Icons.calendar_month_outlined,
                  onTap: () => _selectStartDate(context, viewModel),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Bitiş Tarihi (Opsiyonel)
                const SectionHeader(title: "Bitiş Tarihi (Opsiyonel)"),
                CustomSelectorField(
                  label: "Tarih Seçin",
                  value: viewModel.endDateText,
                  iconData: Icons.calendar_month_outlined,
                  onTap: () => _selectEndDate(context, viewModel),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Notlar
                const SectionHeader(title: "Notlar (Opsiyonel)"),
                CustomInput(
                  labelText: "Ek notlarınız...",
                  onChanged: viewModel.setNotes,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Kaydet Butonu
                CustomButton(
                  text: viewModel.status == MedicineRecordStatus.saving
                      ? "Kaydediliyor..."
                      : "İlacı Kaydet",
                  onPressed: viewModel.status == MedicineRecordStatus.saving
                      ? () {}
                      : () => _handleSave(context, viewModel),
                  backgroundColor: AppColors.primary,
                  borderRadius: 30,
                ),

                // Hata mesajı
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Text(
                      viewModel.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }
}
