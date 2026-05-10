import 'package:flutter/foundation.dart';
import 'package:health_asistants/data/repository/gemini_repository.dart';

class GeminiViewModel extends ChangeNotifier {
  final GeminiRepository _geminiRepository;

  GeminiViewModel({required GeminiRepository geminiRepository})
      : _geminiRepository = geminiRepository;

  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  bool get isLoading => _isLoading;

  /// Asistan yanıtı veya hata metni (ekranda gösterilir).
  String? get message => _message;

  /// [message] bir hata mesajı mı (ör. kırmızı gösterim için).
  bool get isError => _isError;

  Future<void> analyzeText(String text) async {
    if (text.trim().isEmpty) return;

    _isLoading = true;
    _message = null;
    _isError = false;
    notifyListeners();

    try {
      final reply = await _geminiRepository.analyzeText(text);
      _message = reply;
      _isError = false;
    } catch (e, st) {
      debugPrint('GeminiViewModel.analyzeText: $e\n$st');
      _message = _toUserFacingMessage(e);
      _isError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String _toUserFacingMessage(Object e) {
    final s = e.toString();
    const prefix = 'Exception: ';
    if (s.startsWith(prefix)) {
      return s.substring(prefix.length);
    }
    return s;
  }

  void reset() {
    _isLoading = false;
    _message = null;
    _isError = false;
    notifyListeners();
  }
}
