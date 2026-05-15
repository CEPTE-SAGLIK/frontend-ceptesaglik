import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/images.dart';
import 'package:health_asistants/core/utils/navigation/app_routes.dart';
import 'package:health_asistants/presentation/auth/login/viewmodel/login_viewmodel.dart';
import 'package:health_asistants/core/utils/snackbar_helper.dart';
import 'package:health_asistants/presentation/components/custom_button.dart';
import 'package:health_asistants/presentation/components/custom_input.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(AppImages.logo, height: 100),
                  const SizedBox(height: 16),

                  // Hoş geldin mesajı
                  const Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hesabınıza giriş yapın',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),

                  // Email input
                  CustomInput(
                    labelText: "E-posta",
                    hintText: "E-postanızı girin",
                    controller: viewModel.emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  // Şifre input
                  CustomInput(
                    labelText: "Şifre",
                    hintText: "Şifrenizi girin",
                    controller: viewModel.passwordController,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: viewModel.obscurePassword,
                    onVisibilityToggle: viewModel.togglePasswordVisibility,
                  ),
                  const SizedBox(height: 12),

                  // Şifremi unuttum
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          _showForgotPasswordDialog(context, viewModel),
                      child: Text(
                        'Şifremi Unuttum',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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

                  // Giriş butonu
                  CustomButton(
                    text: viewModel.status == LoginStatus.loading
                        ? "Giriş yapılıyor..."
                        : "Giriş Yap",
                    disabled: viewModel.status == LoginStatus.loading,
                    onPressed: () async {
                      final success = await viewModel.login();
                      if (success && context.mounted) {
                        AppRoutes.clearAndPush(context, AppRoutes.main);
                      }
                    },
                  ),
                  const SizedBox(height: 30),

                  // Kayıt ol yönlendirmesi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Hesabınız yok mu? ",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        child: Text(
                          "Kayıt Ol",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showForgotPasswordDialog(
    BuildContext context,
    LoginViewModel viewModel,
  ) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Şifremi Unuttum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'E-posta adresinizi girin, şifre sıfırlama bağlantısı göndereceğiz.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'E-posta adresiniz',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await viewModel.forgotPassword(
                emailController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  SnackbarHelper.showSuccess(
                    context,
                    'Şifre sıfırlama bağlantısı gönderildi',
                  );
                } else {
                  SnackbarHelper.showError(
                    context,
                    viewModel.errorMessage ?? 'Bir hata oluştu',
                  );
                }
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }
}
