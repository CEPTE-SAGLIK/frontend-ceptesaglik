import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanım Koşulları'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '1. Kabul',
              content:
                  'Sağlık Pusulası uygulamasını kullanarak bu kullanım koşullarını kabul etmiş sayılırsınız. '
                  'Koşulları kabul etmiyorsanız, lütfen uygulamayı kullanmayınız.',
            ),
            _buildSection(
              title: '2. Hizmet Tanımı',
              content:
                  'Sağlık Pusulası, ilaç hatırlatmaları, aşı takibi ve sağlık yönetimi konusunda '
                  'yardımcı olmak amacıyla tasarlanmış bir mobil uygulamadır. '
                  'Uygulama tıbbi tavsiye veya teşhis sağlamamaktadır.',
            ),
            _buildSection(
              title: '3. Kullanıcı Yükümlülükleri',
              content:
                  '• Doğru ve güncel bilgi sağlamak\n'
                  '• Hesap güvenliğini korumak\n'
                  '• Uygulamayı yasalara uygun şekilde kullanmak\n'
                  '• Başkalarının haklarına saygı göstermek',
            ),
            _buildSection(
              title: '4. Tıbbi Sorumluluk Reddi',
              content:
                  'Bu uygulama yalnızca hatırlatma ve takip amaçlıdır. Tıbbi kararlar için mutlaka '
                  'bir sağlık uzmanına danışınız. Uygulama, profesyonel tıbbi tavsiyenin yerini almaz.',
            ),
            _buildSection(
              title: '5. Fikri Mülkiyet',
              content:
                  'Uygulama ve içeriği telif hakkı ile korunmaktadır. İzinsiz kopyalama, '
                  'dağıtma veya değiştirme yasaktır.',
            ),
            _buildSection(
              title: '6. Hesap Sonlandırma',
              content:
                  'Bu koşulların ihlali durumunda hesabınızı askıya alma veya sonlandırma '
                  'hakkımız saklıdır.',
            ),
            _buildSection(
              title: '7. Değişiklikler',
              content:
                  'Bu koşulları önceden bildirmeksizin değiştirme hakkımız saklıdır. '
                  'Önemli değişiklikler uygulama içinden bildirilecektir.',
            ),
            _buildSection(
              title: '8. İletişim',
              content:
                  'Kullanım koşulları hakkında sorularınız için:\n\n'
                  'E-posta: legal@saglikpusulasi.com',
            ),
            SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Son güncelleme: Ocak 2026',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
