import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/presentation/map/view/nearby_facilities_screen.dart';

import 'package:health_asistants/presentation/calendar/view/calendar_screen.dart';
import 'package:health_asistants/presentation/home/view/home_screen.dart';
import 'package:health_asistants/presentation/profile/view/profile_view.dart';
import 'package:health_asistants/presentation/navigator/viewmodel/navigator_viewmodel.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigatorViewModel>(
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: !viewModel.canGoBack,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              viewModel.goBack();
            }
          },
          child: Scaffold(
            body: _buildBody(viewModel),
            bottomNavigationBar: _buildBottomNavigationBar(viewModel),
          ),
        );
      },
    );
  }

  Widget _buildBody(NavigatorViewModel viewModel) {
    switch (viewModel.currentTab) {
      case NavigationTab.home:
        return const HomeScreen();
      case NavigationTab.calendar:
        return const CalendarScreen();
      case NavigationTab.aiAssistant:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_fix_high,
                size: AppSpacing.iconXxl,
                color: AppColors.brandPink,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('AI Asistanı', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Yakında...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      case NavigationTab.map:
        return const NearbyFacilitiesScreen();
      case NavigationTab.profile:
        return const ProfileView();
    }
  }

  Widget _buildBottomNavigationBar(NavigatorViewModel viewModel) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.white),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        elevation: 0,
        currentIndex: viewModel.currentIndex,
        onTap: viewModel.navigateTo,
        selectedItemColor: AppColors.brandPurple,
        unselectedItemColor: AppColors.navUnselected,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w500,
        ),
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Takvim',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.auto_fix_high_outlined),
            activeIcon: Icon(Icons.auto_fix_high, color: AppColors.brandPink),
            label: 'AI Asistanı',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Yakındakiler',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
