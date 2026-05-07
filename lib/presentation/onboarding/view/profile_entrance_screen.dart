import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Klavye kontrolü için
import 'package:health_asistants/presentation/onboarding/viewmodel/profile_entrance_viewmodel.dart';
import 'package:provider/provider.dart';
// Renkler ve Sabitler
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/navigation/app_routes.dart';
// Bileşenler
import 'package:health_asistants/presentation/components/custom_date_picker.dart';
import 'package:health_asistants/presentation/components/custom_input_dialog.dart';
import 'package:health_asistants/presentation/components/section_header.dart';
import 'package:health_asistants/presentation/components/chip_selection_group.dart';
import 'package:health_asistants/presentation/components/custom_button.dart';
// ViewModel
// Model
import 'package:health_asistants/data/model/person.dart';

class ProfileEntranceScreen extends StatelessWidget {
  const ProfileEntranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<ProfileEntranceViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildHeader(),
                  const SizedBox(height: 30),

                  // GÜNCELLENEN KISIM
                  _buildPersonalInfoCard(context, viewModel),

                  const SizedBox(height: 20),
                  _buildHealthProfileCard(context, viewModel),
                  const SizedBox(height: 30),

                  // GÜNCELLENEN BUTON (ORTALANDI)
                  _buildCompleteButton(context, viewModel),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sizi Tanıyalım",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Profil Oluşturma",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Size özel sağlık önerileri sunabilmemiz için birkaç bilgiye ihtiyacımız var.",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // --- GÜNCELLENEN KİŞİSEL BİLGİLER KARTI ---
  Widget _buildPersonalInfoCard(
    BuildContext context,
    ProfileEntranceViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primaryBlue),
              SizedBox(width: 10),
              Text(
                "Kişisel Bilgiler",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 30, color: AppColors.outline),

          // 1. DOĞUM TARİHİ
          const SectionHeader(title: "Doğum Tarihiniz"),
          const SizedBox(height: 8),

          GestureDetector(
            onTap: () => _selectDate(context, viewModel),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    viewModel.birthDate == null
                        ? "Tarih Seçin"
                        : viewModel.birthDateText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: viewModel.birthDate == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primaryBlue,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. CİNSİYET (ORTA BOY KUTU)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: const Text(
                  "Cinsiyetiniz",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              Container(
                width: 150,
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Gender>(
                    value: viewModel.gender,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: Gender.female,
                        child: Center(child: Text("Kadın")),
                      ),
                      DropdownMenuItem(
                        value: Gender.male,
                        child: Center(child: Text("Erkek")),
                      ),
                    ],
                    onChanged: (Gender? newValue) {
                      if (newValue != null) {
                        viewModel.setGender(newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(height: 1, color: AppColors.outline),
          const SizedBox(height: 20),

          // 3. BOY VE KİLO (KESİN ÇÖZÜM: INPUT FIELD)
          // Bu yöntem asla taşma yapmaz çünkü 'Expanded' ve 'TextFormField' kullandık.
          Row(
            children: [
              // BOY
              Expanded(
                child: _buildCompactInput(
                  label: "Boy",
                  suffix: "cm",
                  controller: viewModel.heightController,
                  onChanged: (val) {
                    if (val.isNotEmpty) viewModel.setHeight(int.parse(val));
                  },
                ),
              ),
              const SizedBox(width: 15), // Arada yeterli boşluk
              // KİLO
              Expanded(
                child: _buildCompactInput(
                  label: "Kilo",
                  suffix: "kg",
                  controller: viewModel.weightController,
                  onChanged: (val) {
                    if (val.isNotEmpty) viewModel.setWeight(int.parse(val));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- YENİ GİRİŞ KUTUSU BİLEŞENİ ---
  Widget _buildCompactInput({
    required String label,
    required String suffix,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 45, // Cinsiyet kutusuyla aynı yükseklik
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            onChanged: onChanged,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              suffixText: suffix,
              suffixStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ... (Sağlık kartı aynı) ...
  Widget _buildHealthProfileCard(
    BuildContext context,
    ProfileEntranceViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: 10),
              Text(
                "Sağlık Profiliniz",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Bu bilgiler size özel risk analizleri için kullanılacaktır.",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          ChipSelectionGroup(
            title: "Kronik Hastalıklarınız (varsa)",
            allItems: viewModel.availableDiseases,
            selectedItems: viewModel.selectedDiseases,
            onToggle: viewModel.toggleDisease,
            onAddTap: () => _addNewDisease(context, viewModel),
          ),

          const SizedBox(height: 20),

          ChipSelectionGroup(
            title: "Alerjileriniz (varsa)",
            allItems: viewModel.availableAllergies,
            selectedItems: viewModel.selectedAllergies,
            onToggle: viewModel.toggleAllergy,
            onAddTap: () => _addNewAllergy(context, viewModel),
          ),
        ],
      ),
    );
  }

  // --- GÜNCELLENEN VE ORTALANAN BUTON ---
  Widget _buildCompleteButton(
    BuildContext context,
    ProfileEntranceViewModel viewModel,
  ) {
    return Center(
      // Center widget'ı ile ortaladık
      child: CustomButton(
        text: viewModel.isLoading ? "Kaydediliyor..." : "Profili Oluştur",
        width: 200, // Genişliği sabitledim, çok büyük olmasın
        backgroundColor: AppColors.primaryBlue,
        borderRadius: 30,
        onPressed: viewModel.isLoading
            ? () {}
            : () => _handleComplete(context, viewModel),
        icon: viewModel.isLoading ? null : Icons.check_circle_outline,
      ),
    );
  }

  // --- FONKSİYONLAR ---

  Future<void> _selectDate(
    BuildContext context,
    ProfileEntranceViewModel viewModel,
  ) async {
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: viewModel.birthDate,
    );
    if (picked != null) {
      viewModel.setBirthDate(picked);
    }
  }

  void _addNewDisease(
    BuildContext context,
    ProfileEntranceViewModel viewModel,
  ) {
    CustomInputDialog.show(
      context: context,
      title: "Hastalık Ekle",
      onAdded: viewModel.addNewDisease,
    );
  }

  void _addNewAllergy(
    BuildContext context,
    ProfileEntranceViewModel viewModel,
  ) {
    CustomInputDialog.show(
      context: context,
      title: "Alerji Ekle",
      onAdded: viewModel.addNewAllergy,
    );
  }

  Future<void> _handleComplete(
    BuildContext context,
    ProfileEntranceViewModel viewModel,
  ) async {
    final success = await viewModel.saveProfile();

    if (success && context.mounted) {
      AppRoutes.clearAndPush(context, AppRoutes.main);
    } else if (viewModel.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }
}

