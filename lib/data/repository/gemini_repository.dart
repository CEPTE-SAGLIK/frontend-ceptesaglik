import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/gemini_analysis.dart';
import 'package:health_asistants/data/repository/base_repository.dart';

class GeminiRepository extends BaseRepository {
  GeminiRepository({super.apiClient});

  Future<Result<GeminiAnalysisResponse>> analyzeText(String userText) async {
    try {
      final response = await apiClient.post<GeminiAnalysisResponse>(
        ApiEndpoints.aiAnalyze,
        body: {"text": userText},
        fromJson: (json) => GeminiAnalysisResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return Result.success(response.data!);
      }

      return Result.failure(response.errorMessage ?? "Yapay zeka analizinde hata oluştu.");
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }
}
