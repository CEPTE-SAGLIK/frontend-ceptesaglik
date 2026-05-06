import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/person_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/presentation/profile/viewmodel/profile_viewmodel.dart';

class _ErrorResponse {
  final String message;
  _ErrorResponse(this.message);
}

class FakeUserApiClient extends ApiClient {
  final List<dynamic> queuedGetResponses = [];

  FakeUserApiClient() : super();

  @override
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    if (queuedGetResponses.isEmpty) {
      return ApiResponse.error('No queued GET response');
    }

    final next = queuedGetResponses.removeAt(0);
    if (next is _ErrorResponse) {
      return ApiResponse.error(next.message);
    }

    final parsed = fromJson != null ? fromJson(next) : next as T;
    return ApiResponse.success(parsed);
  }
}

class _FakePersonRepository extends PersonRepository {
  @override
  Future<Result<List<Person>>> getMyPersons() async {
    return Result.success([
      Person(
        id: 'person_1',
        userId: 'user_123',
        name: 'Beyza Nur',
        surname: 'Selvi',
        relationship: 'self',
        birthDate: DateTime(1995, 5, 20),
        gender: Gender.female,
        height: 165,
        weight: 58,
      ),
    ]);
  }
}

void main() {
  group('ProfileViewModel', () {
    late ProfileViewModel viewModel;
    late UserRepository userRepository;
    late PersonRepository personRepository;
    late FakeUserApiClient fakeUserApiClient;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeUserApiClient = FakeUserApiClient();
      fakeUserApiClient.queuedGetResponses.add({
        'id': 'user_123',
        'name': 'Beyza Nur',
        'surname': 'Selvi',
        'email': 'beyza.selvi@gmail.com',
        'createdAt': '2024-01-15T00:00:00.000Z',
      });
      fakeUserApiClient.queuedGetResponses.add({
        'id': 'user_123',
        'name': 'Beyza Nur',
        'surname': 'Selvi',
        'email': 'beyza.selvi@gmail.com',
        'createdAt': '2024-01-15T00:00:00.000Z',
      });
      fakeUserApiClient.queuedGetResponses.add({
        'id': 'user_123',
        'name': 'Beyza Nur',
        'surname': 'Selvi',
        'email': 'beyza.selvi@gmail.com',
        'createdAt': '2024-01-15T00:00:00.000Z',
      });

      userRepository = UserRepository(apiClient: fakeUserApiClient);
      personRepository = _FakePersonRepository();
      viewModel = ProfileViewModel(
        userRepository: userRepository,
        personRepository: personRepository,
      );
    });

    test('should start with initial status', () {
      expect(viewModel.status, ProfileStatus.initial);
      expect(viewModel.user, isNull);
      expect(viewModel.currentPerson, isNull);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.notificationsEnabled, true);
      expect(viewModel.darkModeEnabled, false);
    });

    group('loadProfile', () {
      test('should load user and person', () async {
        await viewModel.loadProfile();

        expect(viewModel.status, ProfileStatus.loaded);
        expect(viewModel.user, isNotNull);
        expect(viewModel.currentPerson, isNotNull);
      });

      test('should set correct user data', () async {
        await viewModel.loadProfile();

        expect(viewModel.user!.name, 'Beyza Nur');
        expect(viewModel.user!.surname, 'Selvi');
      });
    });

    group('computed properties', () {
      test('fullName should return user name', () async {
        await viewModel.loadProfile();

        expect(viewModel.fullName, 'Beyza Nur Selvi');
      });

      test('fullName should return "Kullanıcı" when no user', () {
        expect(viewModel.fullName, 'Kullanıcı');
      });

      test('email should return user email', () async {
        await viewModel.loadProfile();

        expect(viewModel.email, 'beyza.selvi@gmail.com');
      });

      test('email should return empty when no user', () {
        expect(viewModel.email, '');
      });

      test('appVersion should return version string', () {
        expect(viewModel.appVersion, '1.0.0');
      });
    });

    group('menu items', () {
      test('highlightedMenuItems should not be empty', () {
        expect(viewModel.highlightedMenuItems, isNotEmpty);
      });

      test('healthSettingsMenuItems should not be empty', () {
        expect(viewModel.healthSettingsMenuItems, isNotEmpty);
      });

      test('appSettingsMenuItems should not be empty', () {
        expect(viewModel.appSettingsMenuItems, isNotEmpty);
      });

      test('aboutMenuItems should not be empty', () {
        expect(viewModel.aboutMenuItems, isNotEmpty);
      });

      test('all menu items should have titles', () {
        for (final item in viewModel.highlightedMenuItems) {
          expect(item.title, isNotEmpty);
        }
        for (final item in viewModel.healthSettingsMenuItems) {
          expect(item.title, isNotEmpty);
        }
        for (final item in viewModel.appSettingsMenuItems) {
          expect(item.title, isNotEmpty);
        }
        for (final item in viewModel.aboutMenuItems) {
          expect(item.title, isNotEmpty);
        }
      });
    });

    group('toggleNotifications', () {
      test('should toggle notifications', () {
        viewModel.toggleNotifications(false);
        expect(viewModel.notificationsEnabled, false);

        viewModel.toggleNotifications(true);
        expect(viewModel.notificationsEnabled, true);
      });
    });

    group('toggleDarkMode', () {
      test('should toggle dark mode', () {
        viewModel.toggleDarkMode(true);
        expect(viewModel.darkModeEnabled, true);

        viewModel.toggleDarkMode(false);
        expect(viewModel.darkModeEnabled, false);
      });
    });

    group('onMenuItemTap', () {
      test('should call onNavigate with route', () {
        String? navigatedRoute;
        viewModel.onNavigate = (route) => navigatedRoute = route;

        viewModel.onMenuItemTap('/test-route');

        expect(navigatedRoute, '/test-route');
      });

      test('should not call onNavigate when route is null', () {
        String? navigatedRoute;
        viewModel.onNavigate = (route) => navigatedRoute = route;

        viewModel.onMenuItemTap(null);

        expect(navigatedRoute, isNull);
      });
    });

    group('editProfile', () {
      test('should navigate to edit-profile', () {
        String? navigatedRoute;
        viewModel.onNavigate = (route) => navigatedRoute = route;

        viewModel.editProfile();

        expect(navigatedRoute, '/edit-profile');
      });
    });

    group('logout', () {
      test('should clear user data and navigate to login', () async {
        await viewModel.loadProfile();

        String? navigatedRoute;
        viewModel.onNavigate = (route) => navigatedRoute = route;

        await viewModel.logout();

        expect(viewModel.user, isNull);
        expect(viewModel.currentPerson, isNull);
        expect(navigatedRoute, '/login');
      });
    });

    group('reset', () {
      test('should reset all state', () async {
        await viewModel.loadProfile();
        viewModel.reset();

        expect(viewModel.status, ProfileStatus.initial);
        expect(viewModel.user, isNull);
        expect(viewModel.currentPerson, isNull);
        expect(viewModel.errorMessage, isNull);
      });
    });

    group('refreshProfile', () {
      test('should reload profile data', () async {
        await viewModel.loadProfile();
        await viewModel.refreshProfile();

        expect(viewModel.status, ProfileStatus.loaded);
        expect(viewModel.user, isNotNull);
      });
    });
  });
}
