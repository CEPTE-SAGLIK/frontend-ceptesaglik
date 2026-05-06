import 'package:flutter/foundation.dart';
import 'package:health_asistants/data/model/child.dart';
import 'package:health_asistants/data/model/vaccine.dart';
import 'package:health_asistants/data/repository/child_repository.dart';

/// Ekran durumu
enum VaccineScreenStatus { initial, loading, loaded, error }

/// Çocuk Aşı Takip ViewModel'i
///
/// Kullanıcı birden fazla çocuk ekleyebilir.
/// Her çocuk için yaşa göre otomatik aşı takvimi oluşturulur.
/// Aşılar tamamlandı / bekliyor olarak işaretlenebilir.
/// Manuel aşı ekleme/silme desteklenir.
class VaccinesViewModel extends ChangeNotifier {
  final ChildRepository _childRepository;

  VaccineScreenStatus _status = VaccineScreenStatus.initial;
  String? _errorMessage;

  List<Child> _children = [];
  Child? _selectedChild;

  VaccinesViewModel({ChildRepository? childRepository})
    : _childRepository = childRepository ?? ChildRepository();

  // ─────────────────────────────────────
  // Getters
  // ─────────────────────────────────────

  VaccineScreenStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == VaccineScreenStatus.loading;

  /// Tüm çocuklar
  List<Child> get children => _children;

  /// Çocuk var mı?
  bool get hasChildren => _children.isNotEmpty;

  /// Seçili çocuk
  Child? get selectedChild => _selectedChild;

  /// Seçili çocuğun aşı takvimi
  List<BabyVaccineSchedule> get schedule =>
      _selectedChild?.vaccineSchedule ?? [];

  /// Seçili çocuğun genel ilerleme yüzdesi
  double get scheduleProgress {
    if (_selectedChild == null) return 0;
    final allSchedule = _selectedChild!.vaccineSchedule;
    if (allSchedule.isEmpty) return 0;

    int total = 0;
    int completed = 0;
    for (final s in allSchedule) {
      total += s.vaccines.length;
      completed += s.completedCount;
    }
    if (total == 0) return 0;
    return completed / total;
  }

  /// Seçili çocuğun yaklaşan aşıları (30 gün içinde)
  List<Vaccine> get upcomingVaccines {
    if (_selectedChild == null) return [];
    final result = <Vaccine>[];
    for (final s in _selectedChild!.vaccineSchedule) {
      for (final v in s.vaccines) {
        if (v.isUpcoming) result.add(v);
      }
    }
    return result;
  }

  /// Seçili çocuğun gecikmiş aşıları
  List<Vaccine> get overdueVaccines {
    if (_selectedChild == null) return [];
    final result = <Vaccine>[];
    for (final s in _selectedChild!.vaccineSchedule) {
      for (final v in s.vaccines) {
        if (v.isOverdue) result.add(v);
      }
    }
    return result;
  }

  /// Tüm çocuklardaki toplam yaklaşan aşı sayısı (bildirim badge)
  int get totalUpcomingCount {
    int count = 0;
    for (final child in _children) {
      for (final s in child.vaccineSchedule) {
        count += s.vaccines.where((v) => v.isUpcoming).length;
      }
    }
    return count;
  }

  /// Tüm çocuklardaki toplam gecikmiş aşı sayısı
  int get totalOverdueCount {
    int count = 0;
    for (final child in _children) {
      for (final s in child.vaccineSchedule) {
        count += s.vaccines.where((v) => v.isOverdue).length;
      }
    }
    return count;
  }

  // ─────────────────────────────────────
  // Veri Yükleme
  // ─────────────────────────────────────

  /// Tüm çocukları yükle, ilk çocuğu seç
  Future<void> loadChildren() async {
    _status = VaccineScreenStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _childRepository.getAll();

    if (result.isSuccess) {
      _children = result.data!;
      if (_selectedChild != null) {
        // Seçili çocuğu güncelle
        final updated = _children.where((c) => c.id == _selectedChild!.id);
        _selectedChild = updated.isNotEmpty
            ? updated.first
            : _children.firstOrNull;
      } else {
        _selectedChild = _children.firstOrNull;
      }
      _status = VaccineScreenStatus.loaded;
    } else {
      _status = VaccineScreenStatus.error;
      _errorMessage = result.error;
    }

    notifyListeners();
  }

  /// Yenile
  Future<void> refresh() async {
    await loadChildren();
  }

  // ─────────────────────────────────────
  // Çocuk Seçimi
  // ─────────────────────────────────────

  /// Çocuk seç (tab değişimi)
  void selectChild(String childId) {
    _selectedChild = _children.firstWhere(
      (c) => c.id == childId,
      orElse: () => _children.first,
    );
    notifyListeners();
  }

  // ─────────────────────────────────────
  // Çocuk CRUD
  // ─────────────────────────────────────

  /// Yeni çocuk ekle — aşı takvimi otomatik oluşturulur
  Future<bool> addChild({
    required String name,
    required DateTime birthDate,
    required ChildGender gender,
  }) async {
    _status = VaccineScreenStatus.loading;
    notifyListeners();

    final result = await _childRepository.create(
      name: name,
      birthDate: birthDate,
      gender: gender,
    );

    if (result.isSuccess) {
      await loadChildren();
      _selectedChild = _children.lastOrNull;
      notifyListeners();
      return true;
    }

    _status = VaccineScreenStatus.error;
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Çocuk bilgisini güncelle
  Future<bool> updateChild(Child child) async {
    final result = await _childRepository.update(child);
    if (result.isSuccess) {
      await loadChildren();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Çocuk sil
  Future<bool> deleteChild(String childId) async {
    final result = await _childRepository.delete(childId);
    if (result.isSuccess) {
      if (_selectedChild?.id == childId) {
        _selectedChild = null;
      }
      await loadChildren();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  // ─────────────────────────────────────
  // Aşı İşlemleri
  // ─────────────────────────────────────

  /// Aşının durumunu değiştir (tamamla / geri al)
  Future<bool> toggleVaccineStatus(String scheduleId, String vaccineId) async {
    if (_selectedChild == null) return false;

    // Mevcut durumu bul
    final schedule = _selectedChild!.vaccineSchedule.firstWhere(
      (s) => s.id == scheduleId,
      orElse: () => throw Exception('Dönem bulunamadı'),
    );
    final vaccine = schedule.vaccines.firstWhere(
      (v) => v.id == vaccineId,
      orElse: () => throw Exception('Aşı bulunamadı'),
    );

    final newStatus = vaccine.isCompleted
        ? VaccineStatus.pending
        : VaccineStatus.completed;

    final result = await _childRepository.updateVaccineStatus(
      _selectedChild!.id,
      scheduleId,
      vaccineId,
      newStatus,
    );

    if (result.isSuccess) {
      await loadChildren();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Manuel aşı ekle (bir döneme)
  Future<bool> addManualVaccine(String scheduleId, Vaccine vaccine) async {
    if (_selectedChild == null) return false;

    final result = await _childRepository.addManualVaccine(
      _selectedChild!.id,
      scheduleId,
      vaccine,
    );

    if (result.isSuccess) {
      await loadChildren();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Aşı sil
  Future<bool> deleteVaccine(String scheduleId, String vaccineId) async {
    if (_selectedChild == null) return false;

    final result = await _childRepository.deleteVaccine(
      _selectedChild!.id,
      scheduleId,
      vaccineId,
    );

    if (result.isSuccess) {
      await loadChildren();
      return true;
    }
    _errorMessage = result.error;
    notifyListeners();
    return false;
  }

  /// Hata temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sıfırla
  void reset() {
    _status = VaccineScreenStatus.initial;
    _errorMessage = null;
    _children = [];
    _selectedChild = null;
    notifyListeners();
  }
}
