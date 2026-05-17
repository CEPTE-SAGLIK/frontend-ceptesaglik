import 'package:flutter/foundation.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';

/// İlaç listesi durumu
enum MedicineListStatus { initial, loading, loaded, error }

class MedicineListViewModel extends ChangeNotifier {
  final MedicineRepository _repository;

  MedicineListStatus _status = MedicineListStatus.initial;
  String? _errorMessage;
  List<Medicine> _medicines = [];
  String _searchQuery = '';
  AudienceGroup? _audienceFilter;

  MedicineListViewModel({required MedicineRepository repository})
      : _repository = repository;

  // Getters
  MedicineListStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  AudienceGroup? get audienceFilter => _audienceFilter;

  List<Medicine> get medicines {
    return _medicines.where((m) {
      if (_audienceFilter != null && m.audienceGroup != _audienceFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return m.name.toLowerCase().contains(q) ||
            (m.notes?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  void setAudienceFilter(AudienceGroup? group) {
    _audienceFilter = group;
    notifyListeners();
  }

  /// Aktif ilaçlar (bitiş tarihi geçmemiş)
  List<Medicine> get activeMedicines {
    final now = DateTime.now();
    return medicines
        .where((m) => m.endDate == null || m.endDate!.isAfter(now))
        .toList();
  }

  /// Pasif ilaçlar (bitiş tarihi geçmiş)
  List<Medicine> get inactiveMedicines {
    final now = DateTime.now();
    return medicines
        .where((m) => m.endDate != null && m.endDate!.isBefore(now))
        .toList();
  }

  /// İlaçları yükle
  Future<void> loadMedicines() async {
    _status = MedicineListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAll();

    if (result.isSuccess) {
      _medicines = result.data!;
      _medicines.sort((a, b) => a.name.compareTo(b.name));
      _status = MedicineListStatus.loaded;
    } else {
      _status = MedicineListStatus.error;
      _errorMessage = result.error;
    }

    notifyListeners();
  }

  /// Yenile
  Future<void> refresh() async {
    await loadMedicines();
  }

  /// Arama yap
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// İlaç ekle
  Future<bool> addMedicine(Medicine medicine) async {
    final result = await _repository.create(medicine);

    if (result.isSuccess) {
      await loadMedicines();
      return true;
    }

    _errorMessage = result.error;
    return false;
  }

  /// İlaç güncelle
  Future<bool> updateMedicine(Medicine medicine) async {
    final result = await _repository.update(medicine);

    if (result.isSuccess) {
      await loadMedicines();
      return true;
    }

    _errorMessage = result.error;
    return false;
  }

  /// İlaç sil
  Future<bool> deleteMedicine(String id) async {
    final result = await _repository.delete(id);

    if (result.isSuccess) {
      await loadMedicines();
      return true;
    }

    _errorMessage = result.error;
    return false;
  }
}
