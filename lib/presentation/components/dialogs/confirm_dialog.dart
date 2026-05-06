import 'package:flutter/material.dart';

/// Onay dialogu gösterir
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Onayla',
  String cancelText = 'İptal',
  bool isDestructive = false,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: Colors.red)
              : null,
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

/// Silme onayı dialogu
Future<bool?> showDeleteConfirmDialog({
  required BuildContext context,
  required String itemName,
}) {
  return showConfirmDialog(
    context: context,
    title: 'Silmek İstediğinize Emin Misiniz?',
    message: '"$itemName" kalıcı olarak silinecek. Bu işlem geri alınamaz.',
    confirmText: 'Sil',
    cancelText: 'İptal',
    isDestructive: true,
  );
}

/// Çıkış onayı dialogu
Future<bool?> showLogoutConfirmDialog(BuildContext context) {
  return showConfirmDialog(
    context: context,
    title: 'Çıkış Yap',
    message: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
    confirmText: 'Çıkış Yap',
    cancelText: 'İptal',
  );
}

/// Değişiklikleri kaydetme dialogu
Future<bool?> showDiscardChangesDialog(BuildContext context) {
  return showConfirmDialog(
    context: context,
    title: 'Değişiklikler Kaydedilmedi',
    message: 'Değişiklikleriniz kaybolacak. Devam etmek istiyor musunuz?',
    confirmText: 'Kaydetmeden Çık',
    cancelText: 'İptal',
    isDestructive: true,
  );
}
