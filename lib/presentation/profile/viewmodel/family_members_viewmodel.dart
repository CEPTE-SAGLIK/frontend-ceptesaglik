import 'package:flutter/foundation.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/repository/user_repository.dart';

enum FamilyMembersStatus { initial, loading, loaded, error }

/// Profil > Yakınlarım ekranının viewmodel'i.
/// Aile üyelerini (Person) listeler ve yeni kişi ekler.
class FamilyMembersViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  FamilyMembersViewModel({required UserRepository userRepository})
      : _userRepository = userRepository;

  FamilyMembersStatus _status = FamilyMembersStatus.initial;
  String? _errorMessage;
  List<Person> _members = [];
  bool _saving = false;

  FamilyMembersStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Person> get members => _members;
  bool get saving => _saving;

  Future<void> load() async {
    _status = FamilyMembersStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final familyResult = await _userRepository.getFamilyMembers();
    final childrenResult = await _userRepository.getChildren();

    if (familyResult.isSuccess) {
      final members = List<Person>.from(familyResult.data ?? []);
      if (childrenResult.isSuccess && childrenResult.data != null) {
        members.addAll(childrenResult.data!);
      }
      _members = members;
      _status = FamilyMembersStatus.loaded;
    } else {
      _status = FamilyMembersStatus.error;
      _errorMessage = familyResult.error;
    }
    notifyListeners();
  }

  Future<bool> deleteMember(String id) async {
    _errorMessage = null;
    final person = _members.firstWhere((p) => p.id == id,
        orElse: () => _members.first);
    final result = person.isChild
        ? await _userRepository.deleteChild(id)
        : await _userRepository.deleteFamilyMember(id);
    if (result.isSuccess) {
      _members.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    }
    _errorMessage = result.error ?? 'Kişi silinemedi';
    notifyListeners();
    return false;
  }

  /// [draft] AddPersonSheet'ten gelen kişi (id/userId boş, doğum tarihi dolu).
  Future<bool> addMember(Person draft) async {
    _saving = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.addFamilyMember(draft);
    _saving = false;
    if (result.isSuccess) {
      await load();
      return true;
    }
    _errorMessage = result.error ?? 'Kişi eklenemedi';
    notifyListeners();
    return false;
  }
}
