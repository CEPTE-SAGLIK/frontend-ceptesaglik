import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_asistants/data/model/user.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/person_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

/// Profil durumu
enum ProfileStatus { initial, loading, loaded, error }

/// Profil menü öğesi
class ProfileMenuItem {
  final String title;
  final String? route;
  final IconData? icon;
  final List<ProfileSubMenuItem>? subItems;

  const ProfileMenuItem({
    required this.title,
    this.route,
    this.icon,
    this.subItems,
  });
}

/// Profil alt menü öğesi
class ProfileSubMenuItem {
  final String title;
  final String? route;

  const ProfileSubMenuItem({required this.title, this.route});
}

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final PersonRepository _personRepository;

  ProfileStatus _status = ProfileStatus.initial;
  String? _errorMessage;
  User? _user;
  Person? _currentPerson;

  // Ayarlar
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  // Navigation callback
  Function(String route)? onNavigate;

  ProfileViewModel({
    UserRepository? userRepository,
    PersonRepository? personRepository,
  }) : _userRepository = userRepository ?? UserRepository(),
       _personRepository = personRepository ?? PersonRepository();

  // Getters
  ProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  Person? get currentPerson => _currentPerson;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;

  /// Kullanıcı tam adı
  String get fullName {
    if (_user != null && _user!.name.trim().isNotEmpty) {
      if (_user!.surname.trim().isNotEmpty) {
        return "${_user!.name} ${_user!.surname}";
      }
      return _user!.name;
    }

    if (_currentPerson != null && _currentPerson!.name.trim().isNotEmpty) {
      if (_currentPerson!.surname.trim().isNotEmpty) {
        return "${_currentPerson!.name} ${_currentPerson!.surname}";
      }
      return _currentPerson!.name;
    }

    return "Kullanıcı";
  }

  /// Kullanıcı email
  String get email => _user?.email ?? "";

  /// Öne çıkan menü öğeleri - Aşılarım
  List<ProfileMenuItem> get highlightedMenuItems => const [
    ProfileMenuItem(
      title: "Aşılarım",
      icon: Icons.vaccines_rounded,
      route: "/my-vaccines",
    ),
  ];

  /// Sağlık ayarları menü öğeleri
  List<ProfileMenuItem> get healthSettingsMenuItems => const [
    ProfileMenuItem(
      title: "Yakınlarım",
      icon: Icons.group_rounded,
      route: "/family-members",
    ),
    ProfileMenuItem(
      title: "Hatırlatmalarım",
      icon: Icons.notifications_rounded,
      route: "/reminders",
    ),
    ProfileMenuItem(
      title: "İlaçlarım",
      icon: Icons.medication_rounded,
      route: "/medicines",
    ),
  ];

  /// Uygulama ayarları menü öğeleri
  List<ProfileMenuItem> get appSettingsMenuItems => const [
    ProfileMenuItem(
      title: "Bildirim Ayarları",
      icon: Icons.notifications_active_rounded,
      route: "/notification-settings",
    ),
    ProfileMenuItem(
      title: "Şifre Değiştir",
      icon: Icons.lock_rounded,
      route: "/change-password",
    ),
  ];

  /// Hakkında menü öğeleri
  List<ProfileMenuItem> get aboutMenuItems => const [
    ProfileMenuItem(
      title: "Gizlilik Politikası",
      icon: Icons.privacy_tip_rounded,
      route: "/privacy-policy",
    ),
    ProfileMenuItem(
      title: "Kullanım Koşulları",
      icon: Icons.description_rounded,
      route: "/terms-of-service",
    ),
    ProfileMenuItem(
      title: "Uygulama Hakkında",
      icon: Icons.info_rounded,
      route: "/about",
    ),
  ];

  /// Uygulama versiyonu
  String get appVersion => "1.0.0";

  /// Profil verilerini yükle
  Future<void> loadProfile() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final userResult = await _userRepository.getCurrentUser();
      final personsResult = await _personRepository.getMyPersons();

      if (userResult.isSuccess) {
        _user = userResult.data;
      }

      if (personsResult.isSuccess &&
          personsResult.data != null &&
          personsResult.data!.isNotEmpty) {
        _currentPerson = personsResult.data!.first;
      }

      _status = ProfileStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Profili yenile
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  /// Profili düzenle
  void editProfile() {
    onNavigate?.call('/edit-profile');
  }

  /// Profil bilgilerini güncelle
  Future<bool> updateProfile({
    required String name,
    required String surname,
    required String email,
  }) async {
    if (_user == null) return false;
    _errorMessage = null;
    try {
      final updatedUser = User(
        id: _user!.id,
        name: name.trim(),
        surname: surname.trim(),
        email: email.trim(),
        createdAt: _user!.createdAt,
      );
      final result = await _userRepository.updateUser(updatedUser);
      if (result.isSuccess && result.data != null) {
        _user = result.data;
        notifyListeners();
        return true;
      }
      _errorMessage = result.error ?? 'Profil güncellenemedi';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Bildirimleri aç/kapat
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
    // TODO: Bildirim ayarını kaydet
  }

  /// Karanlık modu aç/kapat
  void toggleDarkMode(bool value) {
    _darkModeEnabled = value;
    notifyListeners();
    // TODO: Tema ayarını kaydet
  }

  /// Çıkış yap
  Future<void> logout() async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      final result = await _userRepository.logout();

      if (result.isSuccess) {
        // Token'ı temizle
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');

        _user = null;
        _currentPerson = null;
        _status = ProfileStatus.initial;
        onNavigate?.call('/login');
      } else {
        _status = ProfileStatus.error;
        _errorMessage = result.error;
      }
      notifyListeners();
    } catch (e) {
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Menü öğesine tıklama
  void onMenuItemTap(String? route) {
    if (route != null) {
      onNavigate?.call(route);
    }
  }

  /// Verileri sıfırla
  void reset() {
    _status = ProfileStatus.initial;
    _errorMessage = null;
    _user = null;
    _currentPerson = null;
    notifyListeners();
  }
}
