import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_asistants/data/model/medicine.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/data/model/reminder.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';
import 'package:health_asistants/core/utils/audience_helper.dart'; // Yaş grubu hesaplama için korundu
import 'package:health_asistants/core/services/notification_service.dart'; // Bildirim servisi için korundu
import 'package:health_asistants/core/utils/constants/colors.dart';

/// Hatırlatma ekleme durumu
enum AddReminderStatus { initial, saving, saved, error }

/// Hatırlatma türü UI modeli
class ReminderTypeItem {
  final String label;
  final IconData icon;
  final Color color;
  final ReminderType type;

  const ReminderTypeItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class AddReminderViewModel extends ChangeNotifier {
  final ReminderRepository _reminderRepository;
  final UserRepository? _userRepository;
  final MedicineRepository? _medicineRepository;
  final VaccineRepository? _vaccineRepository;
  final _uuid = const Uuid();

  AddReminderViewModel({
    ReminderRepository? reminderRepository,
    UserRepository? userRepository,
    MedicineRepository? medicineRepository,
    VaccineRepository? vaccineRepository,
  }) : _reminderRepository = reminderRepository ?? ReminderRepository(),
       _userRepository = userRepository,
       _medicineRepository = medicineRepository,
       _vaccineRepository = vaccineRepository;

  AddReminderStatus _status = AddReminderStatus.initial;
  String? _errorMessage;

  // Form alanları
  String _title = '';
  String? _description;
  TimeOfDay? _selectedTime;
  DateTime _selectedDate = DateTime.now();
  RepeatType _repeatType = RepeatType.none;
  AudienceGroup _audienceGroup = AudienceGroup.adult;
  String? _selectedFrequencyLabel;
  int _selectedTypeIndex = 0;
  String? _personId;

  // Kişi seçimi
  List<Person> _persons = [];
  Person? _selectedPerson;
  Person? _selfPerson;

  // Hatırlatma türleri
  final List<ReminderTypeItem> reminderTypes = const [
    ReminderTypeItem(
      label: "İlaç",
      icon: Icons.medication,
      color: AppColors.catMedicine,
      type: ReminderType.medicine,
    ),
    ReminderTypeItem(
      label: "Aşı",
      icon: Icons.vaccines,
      color: AppColors.catHealth,
      type: ReminderType.vaccine,
    ),
    ReminderTypeItem(
      label: "Randevu",
      icon: Icons.medical_services,
      color: AppColors.catTeeth,
      type: ReminderType.appointment,
    ),
    ReminderTypeItem(
      label: "Egzersiz",
      icon: Icons.fitness_center,
      color: AppColors.catExercise,
      type: ReminderType.custom,
    ),
    ReminderTypeItem(
      label: "Toplantı",
      icon: Icons.calendar_month,
      color: AppColors.catMeeting,
      type: ReminderType.custom,
    ),
    ReminderTypeItem(
      label: "Genel",
      icon: Icons.notifications,
      color: AppColors.catGeneral,
      type: ReminderType.custom,
    ),
  ];

  // Getters
  AddReminderStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get title => _title;
  String? get description => _description;
  TimeOfDay? get selectedTime => _selectedTime;
  DateTime get selectedDate => _selectedDate;
  RepeatType get repeatType => _repeatType;
  AudienceGroup get audienceGroup => _audienceGroup;
  String? get selectedFrequencyLabel => _selectedFrequencyLabel;
  int get selectedTypeIndex => _selectedTypeIndex;
  ReminderTypeItem get selectedReminderType =>
      reminderTypes[_selectedTypeIndex];
  String? get personId => _personId;
  List<Person> get persons => _persons;
  Person? get selectedPerson => _selectedPerson;
  Person? get selfPerson => _selfPerson;

  /// Seçili yaş grubuna uyan kişiler (kişi seçici bunları gösterir)
  List<Person> get filteredPersons =>
      _persons.where((p) => audienceForPerson(p) == _audienceGroup).toList();

  /// Form geçerli mi
  bool get isFormValid => _title.isNotEmpty && _selectedTime != null;

  /// Sıklık label'ı
  String get repeatTypeLabel {
    switch (_repeatType) {
      case RepeatType.none:
        return 'Bir Kez';
      case RepeatType.daily:
        return 'Her Gün';
      case RepeatType.weekly:
        return 'Haftalık';
      case RepeatType.monthly:
        return 'Aylık';
    }
  }

  // Setters / Actions

  void setTitle(String value) {
    if (_title != value) {
      _title = value;
      notifyListeners();
    }
  }

  void setDescription(String? value) {
    if (_description != value) {
      _description = value;
      notifyListeners();
    }
  }

  void setSelectedTime(TimeOfDay? time) {
    if (_selectedTime != time) {
      _selectedTime = time;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setRepeatType(RepeatType type) {
    if (_repeatType != type) {
      _repeatType = type;
      notifyListeners();
    }
  }

  /// Yaş grubunu değiştirir; seçili kişi yeni gruba uymuyorsa uygun kişiye geçer.
  void setAudienceGroup(AudienceGroup group) {
    if (_audienceGroup == group) return;
    _audienceGroup = group;
    if (_selectedPerson != null &&
        audienceForPerson(_selectedPerson!) != group) {
      final matches = filteredPersons;
      _selectedPerson = matches.isNotEmpty ? matches.first : null;
    }
    notifyListeners();
  }

  void setRepeatTypeFromFrequency(String? frequency) {
    if (frequency == null) return;

    _selectedFrequencyLabel = frequency;

    RepeatType newType;
    switch (frequency) {
      case 'Tekrarı Yok':
        newType = RepeatType.none;
        break;
      case 'Günde 1 kere':
      case 'Günde 2 kere':
        newType = RepeatType.daily;
        break;
      case 'Haftada 1 kere':
      case 'Haftada 2 kere':
        newType = RepeatType.weekly;
        break;
      case 'Ayda 1 kere':
        newType = RepeatType.monthly;
        break;
      default:
        newType = RepeatType.none;
    }
    setRepeatType(newType);
  }

  void setSelectedTypeIndex(int index) {
    if (_selectedTypeIndex != index &&
        index >= 0 &&
        index < reminderTypes.length) {
      _selectedTypeIndex = index;
      notifyListeners();
    }
  }

  void setPersonId(String? id) {
    if (_personId != id) {
      _personId = id;
      notifyListeners();
    }
  }

  void selectPerson(Person person) {
    if (_selectedPerson?.id != person.id) {
      _selectedPerson = person;
      notifyListeners();
    }
  }

  Future<void> loadPersons() async {
    if (_userRepository == null) return;
    _persons = [];
    _selfPerson = null;
    _selectedPerson = null;
    try {
      final selfResult = await _userRepository.getCurrentPerson();
      final familyResult = await _userRepository.getFamilyMembers();
      if (selfResult.isSuccess && selfResult.data != null) {
        _selfPerson = selfResult.data!;
        _persons.add(selfResult.data!);
      }
      if (familyResult.isSuccess && familyResult.data != null) {
        _persons.addAll(familyResult.data!);
      }
      final childrenResult = await _userRepository.getChildren();
      if (childrenResult.isSuccess && childrenResult.data != null) {
        _persons.addAll(childrenResult.data!);
      }
      _selectedPerson = _selfPerson;
      // Varsayılan yaş grubu: giriş yapan kullanıcının kendi yaşı
      if (_selfPerson != null) {
        _audienceGroup = audienceForPerson(_selfPerson!);
      }
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  /// [draft] AddPersonSheet'ten gelen kişi (id/userId boş, doğum tarihi dolu).
  /// Ekran koduyla derleme hatası oluşmaması için senin esnek yapın korundu.
  Future<Person?> addPerson(Person draft) async {
    if (_userRepository == null) return null;
    final result = await _userRepository.addFamilyMember(draft);
    if (result.isSuccess && result.data != null) {
      await loadPersons();
      final found = _persons.firstWhere(
        (p) => p.id == result.data!.id,
        orElse: () => result.data!,
      );
      // Yeni kişinin yaş grubuna geç ki seçilebilir/görünür olsun
      _audienceGroup = audienceForPerson(found);
      _selectedPerson = found;
      notifyListeners();
      return found;
    }
    return null;
  }

  /// Hatırlatmayı kaydet
  Future<Reminder?> saveReminder() async {
    if (_title.isEmpty) {
      _errorMessage = 'Lütfen bir başlık girin';
      notifyListeners();
      return null;
    }
    if (_selectedTime == null) {
      _errorMessage = 'Lütfen bir saat seçin';
      notifyListeners();
      return null;
    }

    _status = AddReminderStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      // Zaten yüklü kişiyi kullan, yoksa backend'den al
      if (_personId == null || _personId!.isEmpty) {
        _personId = _selfPerson?.id ?? _selectedPerson?.id;
      }
      if ((_personId == null || _personId!.isEmpty) && _userRepository != null) {
        final userResult = await _userRepository.getCurrentUser();
        if (userResult.isSuccess && userResult.data != null) {
          _personId = userResult.data!.id;
        }
      }

      if (_personId == null || _personId!.isEmpty) {
        _status = AddReminderStatus.error;
        _errorMessage = 'Kullanıcı bilgisi alınamadı';
        notifyListeners();
        return null;
      }

      final now = DateTime.now();
      final reminderDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Seçili kişi self değilse başlığa isim ön-eki ekle
      final isSelf =
          _selectedPerson == null || _selectedPerson!.id == _selfPerson?.id;
      final String finalTitle;
      if (!isSelf) {
        final personName =
            '${_selectedPerson!.name} ${_selectedPerson!.surname}'.trim();
        finalTitle = personName.isNotEmpty ? '$personName — $_title' : _title;
      } else {
        finalTitle = _title;
      }

      // Yaş grubu kayda doğum tarihi olarak yazılır; grup her okumada yeniden hesaplanır
      final DateTime? targetBirthDate =
          (_selectedPerson ?? _selfPerson)?.birthDate;

      // İlaç türü: Medicine kaydı oluştur; backend otomatik Reminder ekler
      if (selectedReminderType.type == ReminderType.medicine &&
          _medicineRepository != null) {
        final targetPersonId =
            (!isSelf && _selectedPerson != null) ? _selectedPerson!.id : null;
        final medicine = Medicine(
          id: _uuid.v4(),
          name: finalTitle,
          frequencyType: _toFrequencyType(),
          timesPerDay: _timesPerDay(),
          reminderTimes: [reminderDateTime],
          startDate: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
          notes: _description,
          personId: targetPersonId,
          audienceGroup: _audienceGroup,
          audienceBirthDate: targetBirthDate,
        );
        final medResult = await _medicineRepository.create(medicine);
        if (!medResult.isSuccess) {
          _status = AddReminderStatus.error;
          _errorMessage = medResult.error ?? 'İlaç kaydedilemedi';
          notifyListeners();
          return null;
        }
        _status = AddReminderStatus.saved;
        notifyListeners();
        return Reminder(
          id: medResult.data?.id ?? _uuid.v4(),
          personId: _personId!,
          title: finalTitle,
          description: _description,
          type: selectedReminderType.type,
          dateTime: reminderDateTime,
          repeatType: _repeatType,
          audienceGroup: _audienceGroup,
          audienceBirthDate: targetBirthDate,
          isActive: true,
          createdAt: now,
        );
      }

      final reminder = Reminder(
        id: _uuid.v4(),
        personId: _personId!,
        title: finalTitle,
        description: _description,
        type: selectedReminderType.type,
        dateTime: reminderDateTime,
        repeatType: _repeatType,
        audienceGroup: _audienceGroup,
        audienceBirthDate: targetBirthDate,
        isActive: true,
        createdAt: now,
        targetPersonId: isSelf ? null : _selectedPerson?.id,
      );

      // Aşı türü seçildiyse Vaccine tablosuna da kaydet
      if (selectedReminderType.type == ReminderType.vaccine &&
          _vaccineRepository != null &&
          _userRepository != null) {
        final targetPerson = (!isSelf && _selectedPerson != null)
            ? _selectedPerson
            : null;
        final targetId = targetPerson?.id ??
            (await _userRepository.getCurrentPerson()).data?.id;
        if (targetId != null) {
          if (targetPerson?.isChild == true) {
            // Çocuk: backend virtual reminder üretir; ayrıca reminder oluşturma
            final vaccineResult = await _vaccineRepository.addChildManualVaccine(
              childId: targetId,
              name: finalTitle,
              date: reminderDateTime,
            );
            if (vaccineResult.isSuccess) {
              _status = AddReminderStatus.saved;
              notifyListeners();
              return Reminder(
                id: _uuid.v4(),
                personId: _personId!,
                title: finalTitle,
                description: _description,
                type: selectedReminderType.type,
                dateTime: reminderDateTime,
                repeatType: _repeatType,
                audienceGroup: _audienceGroup,
                audienceBirthDate: targetBirthDate,
                isActive: true,
                createdAt: now,
              );
            }
            _status = AddReminderStatus.error;
            _errorMessage = vaccineResult.error ?? 'Aşı kaydedilemedi';
            notifyListeners();
            return null;
          } else {
            await _vaccineRepository.addVaccine(
              targetId: targetId,
              isChild: false,
              name: _title,
              date: reminderDateTime,
              description: _description,
            );
          }
        }
      }

      // Repository'ye kaydet
      print("Saving reminder: ${reminder.toJson()}");
      final result = await _reminderRepository.create(reminder);
      print("Save result isSuccess: ${result.isSuccess}, data: ${result.data?.toJson()}");
      if (!result.isSuccess) {
        _status = AddReminderStatus.error;
        _errorMessage = result.error ?? 'Hatırlatma kaydedilemedi';
        notifyListeners();
        return null;
      }

      if (result.data != null) {
        print("Scheduling notifications for reminder...");
        await NotificationService().scheduleReminderNotifications(result.data!);
        print("Done scheduling");
      }

      _status = AddReminderStatus.saved;
      notifyListeners();

      return result.data;
    } catch (e) {
      _status = AddReminderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  FrequencyType _toFrequencyType() {
    switch (_repeatType) {
      case RepeatType.none:
        return FrequencyType.none;
      case RepeatType.daily:
        return FrequencyType.daily;
      case RepeatType.weekly:
        return FrequencyType.weekly;
      case RepeatType.monthly:
        return FrequencyType.monthly;
    }
  }

  int _timesPerDay() {
    switch (_selectedFrequencyLabel) {
      case 'Günde 2 kere':
      case 'Haftada 2 kere':
        return 2;
      default:
        return 1;
    }
  }

  /// Formu sıfırla (kişi listesi korunur, seçim self'e döner)
  void reset() {
    _status = AddReminderStatus.initial;
    _errorMessage = null;
    _title = '';
    _description = null;
    _selectedTime = null;
    _selectedDate = DateTime.now();
    _repeatType = RepeatType.none;
    _selectedFrequencyLabel = null;
    _selectedTypeIndex = 0;
    _personId = null;
    _selectedPerson = _selfPerson;
    _audienceGroup = _selfPerson != null
        ? audienceForPerson(_selfPerson!)
        : AudienceGroup.adult;
    notifyListeners();
  }
}