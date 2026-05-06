import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Giriş',
              content:
                  'Sağlık Pusulası uygulaması olarak kişisel verilerinizin güvenliği bizim için çok önemlidir. '
                  'Bu gizlilik politikası, hangi bilgileri topladığımızı, nasıl kullandığımızı ve '
                  'koruduğumuzu açıklamaktadır.',
            ),
            _buildSection(
              title: 'Toplanan Bilgiler',
              content:
                  '• Ad, soyad ve iletişim bilgileri\n'
                  '• Sağlık verileri (ilaç hatırlatmaları, aşı takibi vb.)\n'
                  '• Cihaz bilgileri ve uygulama kullanım verileri\n'
                  '• Konum bilgileri (izin verildiğinde)',
            ),
            _buildSection(
              title: 'Bilgilerin Kullanımı',
              content:
                  'Topladığımız bilgileri şu amaçlarla kullanırız:\n\n'
                  '• Kişiselleştirilmiş sağlık hatırlatmaları sunmak\n'
                  '• Uygulama deneyimini iyileştirmek\n'
                  '• Müşteri desteği sağlamak\n'
                  '• Güvenlik ve dolandırıcılık önleme',
            ),
            _buildSection(
              title: 'Veri Güvenliği',
              content:
                  'Verileriniz endüstri standardı şifreleme yöntemleri ile korunmaktadır. '
                  'Yetkisiz erişimi önlemek için teknik ve organizasyonel önlemler alınmaktadır.',
            ),
            _buildSection(
              title: 'Veri Paylaşımı',
              content:
                  'Kişisel verilerinizi üçüncü taraflarla paylaşmıyoruz. Ancak yasal zorunluluklar '
                  'veya kullanıcı güvenliği gerektirdiğinde gerekli bilgiler yetkili makamlarla paylaşılabilir.',
            ),
            _buildSection(
              title: 'Haklarınız',
              content:
                  'KVKK kapsamında aşağıdaki haklara sahipsiniz:\n\n'
                  '• Verilerinize erişim hakkı\n'
                  '• Verilerin düzeltilmesini talep etme hakkı\n'
                  '• Verilerin silinmesini talep etme hakkı\n'
                  '• Veri işlemeye itiraz etme hakkı',
            ),
            _buildSection(
              title: 'İletişim',
              content:
                  'Gizlilik politikamız hakkında sorularınız için bizimle iletişime geçebilirsiniz:\n\n'
                  'E-posta: privacy@saglikpusulasi.com',
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
