import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';
import 'package:health_asistants/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    final apiClient = ApiClient();
    final authRepository = AuthRepository(apiClient: apiClient);

    await tester.pumpWidget(
      MyApp(apiClient: apiClient, authRepository: authRepository),
    );

    expect(find.byType(MyApp), findsOneWidget);

    // Clear the splash screen timer to prevent "A Timer is still pending" failure
    await tester.pump(const Duration(seconds: 3));
  });
}
