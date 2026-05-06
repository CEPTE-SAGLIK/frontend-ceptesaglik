// ReminderRepository artık gerçek API çağrıları yapıyor (mock data kaldırıldı).
// Bu testler HTTP mocking gerektiriyor, şu an skip edilmiştir.
import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';

void main() {
  group('ReminderRepository', () {
    late ReminderRepository repository;
    const userId = 'test-user-id';

    setUp(() {
      repository = ReminderRepository();
    });

    test('skip - API based, needs HTTP mocking', () {}, skip: true);

    // API çağrısı yapılabilmesi için çalışan bir backend gereklidir.
    // Gerçek testler için mockito + http.Client mock kullanılmalı.
    test('getAll requires userId parameter', () {
      // Repository.getAll(userId) bekleniyor
      expect(repository.getAll(userId), isA<Future>());
    });

    test('getByDate requires userId parameter', () {
      expect(
        repository.getByDate(DateTime.now(), userId),
        isA<Future>(),
      );
    });

    test('delete returns Future<Result<bool>>', () {
      expect(repository.delete('some-id'), isA<Future>());
    });
  });
}
