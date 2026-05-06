import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart'; // Renkler import edildi

/// Onboarding içerikleri için data class
class OnboardingContent {
  final String title;
  final String description;
  final String imagePath;
  final IconData fallbackIcon;
  final Color iconColor;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.fallbackIcon,
    required this.iconColor,
  });
}

class OnboardingViewModel extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  /// Onboarding içerikleri - AppColors ile güncellendi
  final List<OnboardingContent> contents = const [
    OnboardingContent(
      title: "Çocuğunuzun Sağlığı Güvende",
      description:
          "Bebek ve çocuklarınız için özel aşı takvimi oluşturun. Gelişimlerini takip edin ve önemli randevuları kaçırmayın.",
      imagePath: 'assets/images/onboarding1.png', // Resim yolu
      fallbackIcon: Icons.child_care_rounded,
      iconColor: AppColors.statusSuccess, // Yeşil
    ),
    OnboardingContent(
      title: "Sevdikleriniz İçin Kolay Takip",
      description:
          "Yaşlı aile bireylerinizin ilaç saatlerini, doktor randevularını ve sağlık ölçümlerini tek yerden kontrol edin.",
      imagePath: 'assets/images/onboarding2.png',
      fallbackIcon: Icons.elderly_rounded,
      iconColor: AppColors.primaryBlue, // Mavi
    ),
    OnboardingContent(
      title: "Tüm Sağlık Geçmişiniz Bir Arada",
      description:
          "Hem kendi aşılarınızı hem de sevdiklerinizin aşılarını güvenle kaydedin ve takip edin.",
      imagePath: 'assets/images/onboarding3.png',
      fallbackIcon: Icons.medical_services_rounded,
      iconColor: AppColors.brandPurple, // Mor
    ),
    OnboardingContent(
      title: "Hatırlatmalarla Unutmayın",
      description:
          "Yıllık kontroller, taramalar ve tüm sağlık randevularınızı zamanında size hatırlatalım.",
      imagePath: 'assets/images/onboarding4.png',
      fallbackIcon: Icons.notifications_active_rounded,
      iconColor: AppColors.statusWarning, // Turuncu
    ),
  ];

  int get totalPages => contents.length;
  bool get isLastPage => _currentIndex == contents.length - 1;
  OnboardingContent get currentContent => contents[_currentIndex];

  void onPageChanged(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentIndex < contents.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn, // Daha yumuşak animasyon
      );
    }
  }

  void previousPage() {
    if (_currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void skipToEnd() {
    pageController.animateToPage(
      contents.length - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
    );
  }

  void reset() {
    _currentIndex = 0;
    pageController.jumpToPage(0);
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
