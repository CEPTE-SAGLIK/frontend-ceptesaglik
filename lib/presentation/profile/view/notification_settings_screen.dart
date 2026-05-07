import 'package:flutter/material.dart';
import 'package:health_asistants/core/utils/constants/colors.dart';
import 'package:health_asistants/core/utils/constants/spacing.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allNotifications = true;
  bool _medicineReminders = true;
  bool _vaccineReminders = true;
  bool _appointmentReminders = true;
  bool _healthTips = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim Ayarları'), centerTitle: true),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          // Ana Switch
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_rounded, color: AppColors.primaryBlue),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tüm Bildirimler',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tüm bildirimleri aç/kapat',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _allNotifications,
                  onChanged: (value) {
                    setState(() {
                      _allNotifications = value;
                      if (!value) {
                        _medicineReminders = false;
                        _vaccineReminders = false;
                        _appointmentReminders = false;
                        _healthTips = false;
                      }
                    });
                  },
                  activeColor: AppColors.primaryBlue,
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          Text(
            'Hatırlatma Türleri',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(height: AppSpacing.md),

          _buildNotificationTile(
            icon: Icons.medication_rounded,
            title: 'İlaç Hatırlatmaları',
            subtitle: 'İlaç alma zamanlarında bildirim al',
            value: _medicineReminders,
            onChanged: _allNotifications
                ? (v) => setState(() => _medicineReminders = v)
                : null,
          ),

          _buildNotificationTile(
            icon: Icons.vaccines_rounded,
            title: 'Aşı Hatırlatmaları',
            subtitle: 'Aşı zamanlarında bildirim al',
            value: _vaccineReminders,
            onChanged: _allNotifications
                ? (v) => setState(() => _vaccineReminders = v)
                : null,
          ),

          _buildNotificationTile(
            icon: Icons.calendar_month_rounded,
            title: 'Randevu Hatırlatmaları',
            subtitle: 'Randevu öncesi bildirim al',
            value: _appointmentReminders,
            onChanged: _allNotifications
                ? (v) => setState(() => _appointmentReminders = v)
                : null,
          ),

          _buildNotificationTile(
            icon: Icons.lightbulb_rounded,
            title: 'Sağlık İpuçları',
            subtitle: 'Günlük sağlık önerileri al',
            value: _healthTips,
            onChanged: _allNotifications
                ? (v) => setState(() => _healthTips = v)
                : null,
          ),

          SizedBox(height: AppSpacing.xl),

          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.orange.shade700),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Bildirimlerin düzgün çalışması için cihaz ayarlarından uygulama bildirimlerinin açık olduğundan emin olun.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: onChanged != null ? AppColors.primaryBlue : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: onChanged != null ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

