import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uygulama Hakkında'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.xl),

            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.health_and_safety_rounded,
                size: 56,
                color: AppColors.primaryBlue,
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // App Name
            const Text(
              'Sağlık Pusulası',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: AppSpacing.xs),

            Text(
              'Versiyon 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            SizedBox(height: AppSpacing.xxl),

            // Description
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hakkımızda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Sağlık Pusulası, siz ve ailenizin sağlığını takip etmenizi kolaylaştıran '
                    'kapsamlı bir sağlık yönetimi uygulamasıdır.\n\n'
                    'İlaç hatırlatmalarından aşı takibine, randevu planlamasından yaşlı bakım '
                    'moduna kadar birçok özellik ile sağlık rutinlerinizi düzenlemenize yardımcı olur.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Features
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Özellikler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildFeatureItem(
                    Icons.medication_rounded,
                    'İlaç Takibi ve Hatırlatmalar',
                  ),
                  _buildFeatureItem(Icons.vaccines_rounded, 'Aşı Takvimi'),
                  _buildFeatureItem(
                    Icons.calendar_month_rounded,
                    'Randevu Planlama',
                  ),
                  _buildFeatureItem(
                    Icons.family_restroom_rounded,
                    'Aile Üyesi Yönetimi',
                  ),
                  _buildFeatureItem(Icons.elderly_rounded, 'Yaşlı Bakım Modu'),
                  _buildFeatureItem(
                    Icons.notifications_active_rounded,
                    'Akıllı Bildirimler',
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Contact
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İletişim',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildContactItem(
                    Icons.email_rounded,
                    'info@saglikpusulasi.com',
                  ),
                  _buildContactItem(
                    Icons.language_rounded,
                    'www.saglikpusulasi.com',
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xl),

            Text(
              '© 2026 Sağlık Pusulası. Tüm hakları saklıdır.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          SizedBox(width: AppSpacing.md),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          SizedBox(width: AppSpacing.md),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }
}
