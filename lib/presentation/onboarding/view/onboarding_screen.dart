import 'package:flutter/material.dart';
import 'package:health_asistants/presentation/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/navigation/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Column(
              children: [
                // 1. ÜST KISIM - ATLA BUTONU
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!viewModel.isLastPage)
                        TextButton(
                          onPressed: viewModel.skipToEnd,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Atla'),
                        )
                      else
                        const SizedBox(height: 48),
                    ],
                  ),
                ),

                // 2. ORTA KISIM - SLIDER
                Expanded(
                  child: PageView.builder(
                    controller: viewModel.pageController,
                    onPageChanged: viewModel.onPageChanged,
                    itemCount: viewModel.totalPages,
                    itemBuilder: (context, index) {
                      return _buildPageContent(viewModel.contents[index]);
                    },
                  ),
                ),

                // 3. ALT KISIM - NOKTALAR VE "İLERİ" YAZISI
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Noktalar
                      Row(
                        children: List.generate(
                          viewModel.totalPages,
                          (index) => _buildDot(index, viewModel.currentIndex),
                        ),
                      ),

                      // "İleri" / "Başla" Yazısı
                      GestureDetector(
                        onTap: () {
                          if (viewModel.isLastPage) {
                            // Onboarding görüldü olarak işaretle
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setBool('onboarding_seen', true);
                            });
                            AppRoutes.clearAndPush(context, AppRoutes.login);
                          } else {
                            viewModel.nextPage();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              viewModel.isLastPage ? "Başla" : "İleri",
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- GÜNCELLENEN KISIM BURASI ---
  Widget _buildPageContent(OnboardingContent content) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10), // Üstten hafif boşluk
            // RESİM ALANI
            Container(
              height: 250, // Resim boyutu
              width: double.infinity,
              decoration: BoxDecoration(
                color: content.iconColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  content.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      content.fallbackIcon,
                      size: 100,
                      color: content.iconColor,
                    );
                  },
                ),
              ),
            ),

            // --- DEĞİŞİKLİK 1: Resim ile Başlık arasını AÇTIK ---
            const SizedBox(height: 60),

            // BAŞLIK
            Text(
              content.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),

            // --- DEĞİŞİKLİK 2: Başlık ile Açıklama arasını AÇTIK ---
            const SizedBox(height: 24),

            // AÇIKLAMA
            Text(
              content.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height:
                    1.6, // Satır aralığını da hafif artırdım, daha rahat okunsun
              ),
            ),

            const SizedBox(height: 40), // Alttan güvenlik payı
          ],
        ),
      ),
    );
  }

  // Nokta Göstergesi (Değişmedi)
  Widget _buildDot(int index, int currentIndex) {
    final bool isActive = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : AppColors.outline,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
