import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/gemini_analysis.dart';
import 'package:health_asistants/data/repository/base_repository.dart';

/// Gemini sohbeti için API erişimi (`POST /api/Chat` — ChatController).
class GeminiRepository extends BaseRepository {
  GeminiRepository({super.apiClient});

  /// [text] gönderilir; başarılıysa sunucudan gelen metin cevabı döner.
  /// Hata durumunda açıklayıcı bir mesajla [Exception] fırlatır.
  Future<String> analyzeText(String text) async {
    try {
      final response = await apiClient.post<dynamic>(
        ApiEndpoints.chat,
        body: {'message': text},
      );

      if (!response.isSuccess) {
        throw Exception(
          response.errorMessage ??
              'Yapay zeka analizi şu anda yapılamıyor. Lütfen tekrar deneyin.',
        );
      }

      return _responseBodyToString(response.data);
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception(
        'Analiz sırasında beklenmeyen bir sorun oluştu: ${formatError(e)}',
      );
    }
  }

  /// API gövdesini (wrap edilmiş `data` dahil) tek bir gösterim metnine çevirir.
  String _responseBodyToString(dynamic raw) {
    if (raw == null) {
      throw Exception('Sunucudan boş yanıt alındı.');
    }
    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) {
        throw Exception('Sunucu boş bir metin döndürdü.');
      }
      return s;
    }
    if (raw is Map<String, dynamic>) {
      final unwrapped = _unwrapDataMap(raw);
      final fromChoices = _stringFromChoices(unwrapped);
      if (fromChoices != null) return fromChoices;

      final direct = _stringFromMap(unwrapped);
      if (direct != null) return direct;

      if (_looksLikeStructuredAnalysis(unwrapped)) {
        return _structuredAnalysisToReadableString(unwrapped);
      }

      throw Exception(
        'Sunucu yanıtı beklenen formatta değil. Destek ekibiyle iletişime geçebilirsiniz.',
      );
    }

    throw Exception('Sunucu yanıtı işlenemedi.');
  }

  Map<String, dynamic> _unwrapDataMap(Map<String, dynamic> json) {
    final data = json['data'] ?? json['Data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return json;
  }

  /// OpenAI / bazı Gemini proxy yanıtları: `choices[0].message.content`
  String? _stringFromChoices(Map<String, dynamic> map) {
    final choices = map['choices'] ?? map['Choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map) return null;
    final message = first['message'] ?? first['Message'];
    if (message is Map) {
      final content = message['content'] ?? message['Content'];
      if (content is String && content.trim().isNotEmpty) return content.trim();
    }
    final text = first['text'] ?? first['Text'];
    if (text is String && text.trim().isNotEmpty) return text.trim();
    return null;
  }

  String? _stringFromMap(Map<String, dynamic> map) {
    const keys = [
      'analysis',
      'assistantMessage',
      'assistant',
      'completion',
      'text',
      'message',
      'result',
      'content',
      'reply',
      'answer',
      'response',
    ];
    for (final key in keys) {
      final v = map[key] ?? map[_capitalize(key)];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  bool _looksLikeStructuredAnalysis(Map<String, dynamic> map) {
    return map.containsKey('medicines') || map.containsKey('reminders');
  }

  String _structuredAnalysisToReadableString(Map<String, dynamic> map) {
    final parsed = GeminiAnalysisResponse.fromJson(map);
    final buffer = StringBuffer();

    if (parsed.medicines.isNotEmpty) {
      buffer.writeln('Önerilen / tespit edilen ilaçlar:');
      for (final m in parsed.medicines) {
        buffer.writeln('• ${m.name} (${m.frequencyType}, günde ${m.timesPerDay} kez)');
      }
      buffer.writeln();
    }
    if (parsed.reminders.isNotEmpty) {
      buffer.writeln('Hatırlatıcılar:');
      for (final r in parsed.reminders) {
        buffer.writeln('• ${r.title} — ${r.type} (${r.dateTime.toLocal()})');
      }
    }

    final out = buffer.toString().trim();
    if (out.isEmpty) {
      return 'Analiz tamamlandı; listelenecek ilaç veya hatırlatıcı bulunamadı.';
    }
    return out;
  }
}
