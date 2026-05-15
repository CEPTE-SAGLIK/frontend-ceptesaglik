import 'package:health_asistants/core/error/app_error.dart';
import 'package:health_asistants/core/network/api_client.dart';

abstract class BaseRepository {
  final ApiClient apiClient;

  BaseRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  String formatError(dynamic error) {
    if (error is String) return error;
    return error.toString();
  }
}

class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  factory Result.failure(String error) {
    return Result._(error: error, isSuccess: false);
  }

  AppError? get appError =>
      error != null ? AppError.fromString(error!) : null;

  T get dataOrThrow {
    final d = data;
    if (isSuccess && d != null) return d as T;
    throw Exception(error ?? 'Bilinmeyen hata');
  }

  Result<R> map<R>(R Function(T) mapper) {
    final d = data;
    if (isSuccess && d != null) {
      return Result.success(mapper(d as T));
    }
    return Result.failure(error ?? 'Bilinmeyen hata');
  }
}
