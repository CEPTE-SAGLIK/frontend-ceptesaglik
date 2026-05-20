import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';
import 'package:health_asistants/core/utils/theme/text_styles.dart';
import 'package:health_asistants/presentation/components/error_state_widget.dart';
import 'package:health_asistants/presentation/profile/viewmodel/profile_viewmodel.dart';
import 'package:health_asistants/core/utils/navigation/app_routes.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ProfileViewModel>();

      viewModel.onNavigate = (route) {
        if (route == '/login') {
          Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      };

      if (viewModel.status == ProfileStatus.initial) {
        viewModel.loadProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.status == ProfileStatus.error) {
            return _buildErrorState(viewModel);
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(viewModel),
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMenuSection(
                          title: 'Öne Çıkanlar',
                          items: viewModel.highlightedMenuItems,
                          viewModel: viewModel,
                        ),
                        SizedBox(height: AppSpacing.xl),

                        // --- YENİ: SAĞLIK KAYITLARIM BÖLÜMÜ ---
                        Text(
                          'Sağlık Kayıtlarım',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _MenuTile(
                                title: 'Hastalıklarım',
                                icon: Icons.medical_information_rounded,
                                onTap: () => AppRoutes.push(
                                  context,
                                  AppRoutes.illnesses,
                                ),
                                viewModel: viewModel,
                                showDivider: true,
                              ),
                              _MenuTile(
                                title: 'Alerjilerim',
                                icon: Icons.coronavirus_rounded,
                                onTap: () => AppRoutes.push(
                                  context,
                                  AppRoutes.allergies,
                                ),
                                viewModel: viewModel,
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),

                        // --------------------------------------
                        SizedBox(height: AppSpacing.xl),
                        _buildMenuSection(
                          title: 'Sağlık Yönetimi',
                          items: viewModel.healthSettingsMenuItems,
                          viewModel: viewModel,
                        ),
                        SizedBox(height: AppSpacing.xl),
                        _buildMenuSection(
                          title: 'Uygulama Ayarları',
                          items: viewModel.appSettingsMenuItems,
                          viewModel: viewModel,
                        ),
                        SizedBox(height: AppSpacing.xl),
                        _buildNotificationToggle(viewModel),
                        SizedBox(height: AppSpacing.xl),
                        _buildMenuSection(
                          title: 'Hakkında',
                          items: viewModel.aboutMenuItems,
                          viewModel: viewModel,
                        ),
                        SizedBox(height: AppSpacing.md),
                        _buildVersionInfo(viewModel),
                        SizedBox(height: AppSpacing.xl),
                        _buildLogoutButton(viewModel),
                        SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ... (Diğer _build metodların aynı kalıyor, sadece _getMenuIcon'u aşağıda güncelledim)

  Widget _buildErrorState(ProfileViewModel viewModel) {
    return ErrorStateWidget.fromMessage(
      viewModel.errorMessage ?? 'Bir hata oluştu',
      onRetry: viewModel.loadProfile,
    );
  }

  Widget _buildHeader(ProfileViewModel viewModel) {
    final initials = _getInitials(viewModel.fullName);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                viewModel.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (viewModel.email.isNotEmpty) ...[
                SizedBox(height: AppSpacing.xs),
                Text(
                  viewModel.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: viewModel.editProfile,
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: const Text('Profili Düzenle'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _buildMenuSection({
    required String title,
    required List<ProfileMenuItem> items,
    required ProfileViewModel viewModel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return _MenuTile(
                title: item.title,
                icon: _getMenuIcon(item.route),
                onTap: item.subItems == null
                    ? () => viewModel.onMenuItemTap(item.route)
                    : null,
                subItems: item.subItems,
                viewModel: viewModel,
                showDivider: !isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  IconData _getMenuIcon(String? route) {
    switch (route) {
      case AppRoutes.illnesses: // Yeni ikon
        return Icons.medical_information_rounded;
      case AppRoutes.allergies: // Yeni ikon
        return Icons.coronavirus_rounded;
      case '/children-vaccines':
      case '/my-vaccines':
        return Icons.vaccines_rounded;
      case '/elderly-care':
        return Icons.elderly_rounded;
      case '/change-password':
        return Icons.lock_rounded;
      case '/reminders':
        return Icons.notifications_rounded;
      case '/medicines':
        return Icons.medication_rounded;
      case '/my-children':
        return Icons.child_care_rounded;
      case '/family-members':
        return Icons.group_rounded;
      case '/health-overview':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.arrow_forward_ios_rounded;
    }
  }

  Widget _buildNotificationToggle(ProfileViewModel viewModel) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: Colors.orange.shade600,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bildirimler',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Hatırlatmalar için bildirim al',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: viewModel.notificationsEnabled,
            onChanged: viewModel.toggleNotifications,
            activeThumbColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(ProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            color: Theme.of(context).primaryColor,
            size: 48,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Sağlık Pusulası',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Versiyon ${viewModel.appVersion}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '© 2026 Tüm hakları saklıdır.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(viewModel),
        icon: Icon(Icons.logout_rounded, color: Colors.red.shade400),
        label: Text('Çıkış Yap', style: TextStyle(color: Colors.red.shade400)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade200),
          padding: EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.logout();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final List<ProfileSubMenuItem>? subItems;
  final ProfileViewModel viewModel;
  final bool showDivider;

  const _MenuTile({
    required this.title,
    required this.icon,
    this.onTap,
    this.subItems,
    required this.viewModel,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    if (subItems != null) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 22),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: subItems!.map((subItem) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: OutlinedButton(
                      onPressed: () => viewModel.onMenuItemTap(subItem.route),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(subItem.title, style: AppTextStyles.caption),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (showDivider) Divider(height: 1, color: Colors.grey.shade100),
        ],
      );
    }

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primaryBlue, size: 22),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 54, color: Colors.grey.shade100),
      ],
    );
  }
}

