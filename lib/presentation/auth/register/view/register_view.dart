import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/images.dart';
import 'package:health_asistants/core/utils/navigation/app_routes.dart';
import 'package:health_asistants/presentation/auth/register/viewmodel/register_viewmodel.dart';
import 'package:health_asistants/presentation/components/custom_button.dart';
import 'package:health_asistants/presentation/components/custom_input.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(AppImages.logo, height: 120),
                  const SizedBox(height: 16),

                  // Başlık
                  const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // İsim Soyisim
                  CustomInput(
                    labelText: "İsim & Soyisim",
                    hintText: "Adınızı ve soyadınızı girin",
                    controller: viewModel.nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // E-posta
                  CustomInput(
                    labelText: "E-Posta",
                    hintText: "E-postanızı girin",
                    controller: viewModel.emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Şifre
                  CustomInput(
                    labelText: "Şifre",
                    hintText: "Şifre oluşturun (min. 6 karakter)",
                    controller: viewModel.passwordController,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: viewModel.obscurePassword,
                    onVisibilityToggle: viewModel.togglePasswordVisibility,
                  ),
                  const SizedBox(height: 20),

                  // Şifre Tekrar
                  CustomInput(
                    labelText: "Şifre Tekrar",
                    hintText: "Şifreyi tekrar girin",
                    controller: viewModel.confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: viewModel.obscureConfirmPassword,
                    onVisibilityToggle:
                        viewModel.toggleConfirmPasswordVisibility,
                  ),

                  // Şifre eşleşme hatası
                  if (viewModel.passwordMatchError != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        viewModel.passwordMatchError!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  // Kullanım Koşulları Checkbox
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: viewModel.acceptedTerms,
                          activeColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (_) => viewModel.toggleAcceptedTerms(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: viewModel.toggleAcceptedTerms,
                          child: Text(
                            "Kullanım Koşullarını ve KVKK Aydınlatma Metnini okudum, kabul ediyorum.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Hata mesajı
                  if (viewModel.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Kayıt Ol Butonu
                  CustomButton(
                    text: viewModel.status == RegisterStatus.loading
                        ? "Kayıt yapılıyor..."
                        : "Kayıt Ol",
                    backgroundColor: const Color(0xFF1EC73D),
                    disabled: viewModel.status == RegisterStatus.loading,
                    onPressed: () async {
                      final success = await viewModel.register();
                      if (success && context.mounted) {
                        AppRoutes.clearAndPush(
                          context,
                          AppRoutes.profileEntrance,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Giriş Yap Yönlendirmesi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Zaten bir hesabın var mı? ",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Giriş Yap",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
