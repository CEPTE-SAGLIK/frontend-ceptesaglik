import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/data/repository/base_repository.dart';
import 'package:health_asistants/data/repository/person_repository.dart';

class UserRepository extends BaseRepository {
  final PersonRepository _personRepository;
  final _uuid = const Uuid();

  User? _currentUser;
  Person? _currentPerson;
  final List<Person> _familyMembers = [];

  UserRepository({super.apiClient, PersonRepository? personRepository})
      : _personRepository =
            personRepository ?? PersonRepository(apiClient: apiClient);

  Future<Result<User>> getCurrentUser() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.users,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final payload = _extractPayload(response.data!);
        if (payload != null) {
          _currentUser = User.fromJson(payload);
          return Result.success(_currentUser!);
        }
      }

      final localUser = await _getLocalUser();
      if (localUser != null) {
        _currentUser = localUser;
        return Result.success(localUser);
      }

      return Result.failure(response.errorMessage ?? 'Kullanıcı alınamadı');
    } catch (e) {
      final localUser = await _getLocalUser();
      if (localUser != null) {
        _currentUser = localUser;
        return Result.success(localUser);
      }
      return Result.failure(formatError(e));
    }
  }

  Future<Result<User>> updateUser(User user) async {
    try {
      final body = {
        'name': user.name,
        'surname': user.surname,
        'email': user.email,
      };
      final response = await apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.users,
        body: body,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final payload = _extractPayload(response.data!);
        if (payload != null) {
          _currentUser = User.fromJson(payload);
          return Result.success(_currentUser!);
        }
      }
      return Result.failure(response.errorMessage ?? 'Kullanıcı güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<Person>> getCurrentPerson() async {
    try {
      final apiResult = await _personRepository.getMyPersons();
      if (!apiResult.isSuccess ||
          apiResult.data == null ||
          apiResult.data!.isEmpty) {
        return Result.failure(apiResult.error ?? 'Profil bulunamadı');
      }
      _setPersonCache(apiResult.data!);
      return Result.success(_currentPerson!);
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<List<Person>>> getFamilyMembers() async {
    try {
      final apiResult = await _personRepository.getMyPersons();
      if (!apiResult.isSuccess || apiResult.data == null) {
        return Result.failure(apiResult.error ?? 'Aile üyeleri alınamadı');
      }
      _setPersonCache(apiResult.data!);
      return Result.success(List.from(_familyMembers));
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<Person>> updatePerson(Person person) async {
    try {
      final apiResult = await _personRepository.updatePerson(
        person.id,
        name: person.name,
        surname: person.surname,
        birthDate: person.birthDate,
        gender: person.gender,
        height: person.height,
        weight: person.weight,
      );
      if (apiResult.isSuccess && apiResult.data != null) {
        final updated = _withRelationship(apiResult.data!, person.relationship);
        _updateCache(updated);
        return Result.success(updated);
      }
      return Result.failure(apiResult.error ?? 'Profil güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<Person>> addFamilyMember(Person person) async {
    try {
      if (_isUnderAge(person.birthDate, 18)) {
        return _createChildAsPerson(person);
      }
      final apiResult = await _personRepository.createPerson(
        name: person.name,
        surname: person.surname,
        birthDate: person.birthDate,
        gender: person.gender,
        height: person.height,
        weight: person.weight,
      );
      if (apiResult.isSuccess && apiResult.data != null) {
        final created = _withRelationship(apiResult.data!, person.relationship);
        _familyMembers.add(created);
        return Result.success(created);
      }
      return Result.failure(apiResult.error ?? 'Aile üyesi eklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  bool _isUnderAge(DateTime birthDate, int threshold) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age < threshold;
  }

  Future<Result<Person>> _createChildAsPerson(Person person) async {
    try {
      final userResult = await getCurrentUser();
      if (!userResult.isSuccess) {
        return Result.failure('Kullanıcı bilgisi alınamadı');
      }
      final body = {
        'Name': person.name,
        'BirthDate': person.birthDate.toIso8601String().split('.')[0],
        'Gender': person.gender == Gender.female ? 1 : 0,
        'UserId': userResult.data!.id,
      };
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.children,
        body: body,
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final raw = response.data!;
        final data = raw['data'] ?? raw['Data'];
        if (data is Map<String, dynamic>) {
          final created = _childJsonToPerson(data);
          if (created != null) return Result.success(created);
        }
      }
      return Result.failure(response.errorMessage ?? 'Çocuk eklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  // --- Çocuk yönetimi (Children endpoint) ---

  Future<Result<List<Person>>> getChildren() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.children,
        fromJson: (json) => json,
      );
      if (response.isSuccess && response.data != null) {
        final raw = response.data!['data'] ??
            response.data!['Data'] ??
            response.data;
        if (raw is List) {
          final children = raw
              .map((e) => _childJsonToPerson(e as Map<String, dynamic>))
              .whereType<Person>()
              .toList();
          return Result.success(children);
        }
      }
      return Result.success([]);
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Person? _childJsonToPerson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as String?;
      final name = json['name'] as String?;
      final birthDateStr = json['birthDate'] as String?;
      if (id == null || name == null || birthDateStr == null) return null;
      return Person(
        id: id,
        userId: '',
        name: name,
        surname: '',
        birthDate: DateTime.parse(birthDateStr),
        gender: (json['gender'] as String?)?.toLowerCase() == 'female'
            ? Gender.female
            : Gender.male,
        isChild: true,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Result<bool>> addChild(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.children,
        body: data,
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Çocuk eklenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> deleteChild(String id) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.child(id),
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Çocuk silinemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> updateChild(
      String id, String name, DateTime birthDate, Gender gender) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.child(id),
        body: {
          'name': name,
          'birthDate': birthDate.toIso8601String().split('.')[0],
          'gender': gender == Gender.male ? 'male' : 'female',
        },
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Çocuk güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> updatePhysicalInfo(
      String id, double height, double weight, Gender gender) async {
    try {
      final response = await apiClient.put<Map<String, dynamic>>(
        '/api/Children/$id/physical-info',
        body: {
          'height': height,
          'weight': weight,
          'gender': gender == Gender.male ? 'male' : 'female',
        },
        fromJson: (json) => json,
      );
      return response.isSuccess
          ? Result.success(true)
          : Result.failure(response.errorMessage ?? 'Bilgi güncellenemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> deleteFamilyMember(String id) async {
    try {
      final response = await apiClient.delete<Map<String, dynamic>>(
        ApiEndpoints.person(id),
        fromJson: (json) => json,
      );
      if (response.isSuccess) {
        _familyMembers.removeWhere((p) => p.id == id);
        return Result.success(true);
      }
      return Result.failure(response.errorMessage ?? 'Kişi silinemedi');
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  Future<Result<bool>> logout() async {
    try {
      _currentUser = null;
      _currentPerson = null;
      _familyMembers.clear();
      return Result.success(true);
    } catch (e) {
      return Result.failure(formatError(e));
    }
  }

  // --- Yardımcı metodlar ---

  Map<String, dynamic>? _extractPayload(Map<String, dynamic> json) {
    dynamic p = json;
    if (p is Map && p['data'] is Map) p = p['data'];
    if (p is Map && p['user'] is Map) p = p['user'];
    return p is Map<String, dynamic> ? p : null;
  }

  Future<User?> _getLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('user_id');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      if (id != null && name != null && email != null) {
        return User(
          id: id,
          name: name,
          surname: prefs.getString('user_surname') ?? '',
          email: email,
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {}
    return null;
  }

  List<Vaccine> parseVaccines(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<Vaccine>((v) {
      final s = (v['vaccines'] != null && v['vaccines'] is List && (v['vaccines'] as List).isNotEmpty)
          ? v['vaccines'][0]
          : v;
      final rawDate = s['date'] ?? s['Date'] ?? s['dateAdministered'] ??
          s['DateAdministered'] ?? DateTime.now().toIso8601String();
      final rawStatus = (s['status'] ?? s['Status'] ?? 'pending').toString().toLowerCase();
      return Vaccine(
        id: s['id']?.toString() ?? s['Id']?.toString() ?? _uuid.v4(),
        name: s['name'] ?? s['Name'] ?? s['vaccineName'] ?? 'Bilinmeyen Aşı',
        date: DateTime.parse(rawDate),
        dose: s['dose'] ?? s['Dose'] ?? '1',
        status: (rawStatus == 'completed' || rawStatus == 'tamamlandı')
            ? VaccineStatus.completed
            : VaccineStatus.pending,
      );
    }).toList();
  }

  Gender parseGender(dynamic value) {
    if (value == null) return Gender.male;
    final v = value.toString().toLowerCase();
    return (v == 'female' || v == '1' || v == 'kadın')
        ? Gender.female
        : Gender.male;
  }

  void _setPersonCache(List<Person> persons) {
    if (persons.isEmpty) {
      _currentPerson = null;
      _familyMembers.clear();
      return;
    }
    // Hesap sahibinin profili IsAccountOwner bayrağıyla belirlenir;
    // bayrak yoksa (eski veri) ilk kayıt yedek olarak kullanılır.
    final owners = persons.where((p) => p.isAccountOwner).toList();
    _currentPerson = owners.isNotEmpty ? owners.first : persons.first;
    _familyMembers
      ..clear()
      ..addAll(persons.where((p) => p.id != _currentPerson!.id));
  }

  void _updateCache(Person person) {
    if (_currentPerson?.id == person.id) {
      _currentPerson = person;
      return;
    }
    final i = _familyMembers.indexWhere((p) => p.id == person.id);
    if (i != -1) _familyMembers[i] = person;
  }

  Person _withRelationship(Person source, String? relationship) {
    return Person(
      id: source.id,
      userId: source.userId,
      name: source.name,
      surname: source.surname,
      relationship: relationship ?? source.relationship,
      birthDate: source.birthDate,
      gender: source.gender,
      height: source.height,
      weight: source.weight,
      createdAt: source.createdAt,
      illnesses: source.illnesses,
      allergies: source.allergies,
      medicines: source.medicines,
      vaccines: source.vaccines,
      isAccountOwner: source.isAccountOwner,
    );
  }
}
