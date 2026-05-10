import 'package:flutter/foundation.dart';
import 'package:health_asistants/data/repository/gemini_repository.dart';

class GeminiChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime createdAt;

  const GeminiChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    required this.createdAt,
  });
}

class GeminiViewModel extends ChangeNotifier {
  final GeminiRepository _geminiRepository;

  GeminiViewModel({required GeminiRepository geminiRepository})
      : _geminiRepository = geminiRepository;

  bool _isLoading = false;
  final List<GeminiChatMessage> _messages = [];

  bool get isLoading => _isLoading;
  List<GeminiChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_isLoading) return;

    final normalized = text.trim();
    _messages.add(
      GeminiChatMessage(
        text: normalized,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );

    _isLoading = true;
    notifyListeners();

    try {
      final reply = await _geminiRepository.analyzeText(normalized);
      _messages.add(
        GeminiChatMessage(
          text: reply,
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e, st) {
      debugPrint('GeminiViewModel.sendMessage: $e\n$st');
      _messages.add(
        GeminiChatMessage(
          text: _toUserFacingMessage(e),
          isUser: false,
          isError: true,
          createdAt: DateTime.now(),
        ),
      );
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
    _messages.clear();
    notifyListeners();
  }
}
