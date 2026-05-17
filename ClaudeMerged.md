# Sağlık Pusulası — Tam Proje Yapısı

> İki kısım: **Flutter Frontend** (saglik-pusulasi) + **ASP.NET Core 9 Backend** (HealthApp)  
> Mimari: MVVM + Repository Pattern (Flutter) · Clean Architecture (Backend)

---

## Genel Bakış

| Taraf    | Repo / Dizin                       | Teknoloji               | Port                    |
|----------|------------------------------------|-------------------------|-------------------------|
| Frontend | `Desktop/saglik-pusulasi/`         | Flutter · Dart          | —                       |
| Backend  | `Desktop/HealthApp/`               | ASP.NET Core 9 · C#     | HTTP 5105 / HTTPS 7105  |

---

## Frontend — Flutter (saglik-pusulasi)

### Katman Özeti

| Katman       | Dizin                    | Açıklama                                |
|--------------|--------------------------|-----------------------------------------|
| Core         | `lib/core/`              | Network, tema, sabitler, navigasyon     |
| Data         | `lib/data/`              | Model sınıfları ve repository'ler       |
| Presentation | `lib/presentation/`      | ViewModel'lar, View'lar, bileşenler     |
| Test         | `test/`                  | Birim testler (model + viewmodel)       |

### Dosya Ağacı

```
saglik-pusulasi/
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── README.md
├── ClaudeMerged.md                         # Bu dosya
│
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── network/
│   │   │   └── api_client.dart
│   │   └── utils/
│   │       ├── audience_helper.dart       # Yaş grubu hesabı (çocuk/yetişkin/yaşlı)
│   │       ├── constants/
│   │       │   ├── colors.dart
│   │       │   ├── images.dart
│   │       │   ├── shadows.dart
│   │       │   └── spacing.dart
│   │       ├── navigation/
│   │       │   └── app_routes.dart
│   │       └── theme/
│   │           ├── app_theme.dart
│   │           ├── text_styles.dart
│   │           └── helper/context.dart
│   │
│   ├── data/
│   │   ├── model/
│   │   │   ├── allergy.dart
│   │   │   ├── auth_response.dart
│   │   │   ├── child.dart
│   │   │   ├── gemini_analysis.dart
│   │   │   ├── health_facility.dart
│   │   │   ├── illness.dart
│   │   │   ├── medicine.dart
│   │   │   ├── person.dart
│   │   │   ├── reminder.dart
│   │   │   ├── user.dart
│   │   │   ├── vaccine.dart
│   │   │   └── vaccine_schedule.dart
│   │   └── repository/
│   │       ├── auth_repository.dart
│   │       ├── base_repository.dart
│   │       ├── child_repository.dart
│   │       ├── gemini_repository.dart
│   │       ├── illness_repository.dart
│   │       ├── medicine_repository.dart
│   │       ├── person_repository.dart
│   │       ├── reminder_repository.dart
│   │       ├── user_repository.dart
│   │       └── vaccine_repository.dart
│   │
│   └── presentation/
│       ├── components/                     # 32 yeniden kullanılabilir widget
│       │   ├── dialogs/confirm_dialog.dart
│       │   ├── add_option_button.dart
│       │   ├── add_person_sheet.dart
│       │   ├── audience_filter_bar.dart
│       │   ├── calendar_card.dart
│       │   ├── category_chip.dart
│       │   ├── chip_selection_group.dart
│       │   ├── choice_card.dart
│       │   ├── custom_action_card.dart
│       │   ├── custom_button.dart
│       │   ├── custom_date_picker.dart
│       │   ├── custom_fab_menu.dart
│       │   ├── custom_input.dart
│       │   ├── custom_input_dialog.dart
│       │   ├── custom_selector_field.dart
│       │   ├── custom_text_input.dart
│       │   ├── emergency_button.dart
│       │   ├── empty_state_widget.dart
│       │   ├── featured_article_card.dart
│       │   ├── frequency_selector.dart
│       │   ├── medication_card.dart
│       │   ├── number_input_stepper.dart
│       │   ├── profile_card.dart
│       │   ├── quick_access_button.dart
│       │   ├── recent_article_card.dart
│       │   ├── reminder_box.dart
│       │   ├── reminder_item_card.dart
│       │   ├── reminder_status_card.dart
│       │   ├── reminder_type_card.dart
│       │   ├── section_header.dart
│       │   ├── selection_illness.dart
│       │   └── time_picker_selector.dart
│       │
│       ├── allergy/
│       │   ├── view/allergies_screen.dart
│       │   └── viewmodel/allergy_viewmodel.dart
│       ├── auth/
│       │   ├── login/view/login_view.dart
│       │   ├── login/viewmodel/login_viewmodel.dart
│       │   ├── register/view/register_view.dart
│       │   └── register/viewmodel/register_viewmodel.dart
│       ├── calendar/
│       │   ├── view/calendar_screen.dart
│       │   └── viewmodel/calendar_viewmodel.dart
│       ├── home/
│       │   ├── view/gemini_assistant_sheet.dart
│       │   ├── view/home_screen.dart
│       │   ├── viewmodel/gemini_viewmodel.dart
│       │   └── viewmodel/home_viewmodel.dart
│       ├── illness/
│       │   ├── view/illnesses_screen.dart
│       │   └── viewmodel/illness_viewmodel.dart
│       ├── map/
│       │   ├── view/nearby_facilities_screen.dart
│       │   └── viewmodel/nearby_facilities_viewmodel.dart
│       ├── medicine/
│       │   ├── view/add_medicine_screen.dart
│       │   ├── view/medicine_list_screen.dart
│       │   ├── viewmodel/add_medicine_viewmodel.dart
│       │   └── viewmodel/medicine_list_viewmodel.dart
│       ├── navigator/
│       │   ├── view/main_screen.dart
│       │   └── viewmodel/navigator_viewmodel.dart
│       ├── onboarding/
│       │   ├── view/onboarding_screen.dart
│       │   ├── view/profile_entrance_screen.dart
│       │   ├── viewmodel/onboarding_viewmodel.dart
│       │   └── viewmodel/profile_entrance_viewmodel.dart
│       ├── profile/
│       │   ├── view/about_screen.dart
│       │   ├── view/add_vaccine_screen.dart
│       │   ├── view/change_password_screen.dart
│       │   ├── view/edit_profile_screen.dart
│       │   ├── view/family_members_screen.dart
│       │   ├── view/my_children_screen.dart
│       │   ├── view/notification_settings_screen.dart
│       │   ├── view/person_detail_screen.dart
│       │   ├── view/privacy_policy_screen.dart
│       │   ├── view/profile_view.dart
│       │   ├── view/terms_of_service_screen.dart
│       │   ├── view/vaccines_screen.dart
│       │   ├── viewmodel/family_members_viewmodel.dart
│       │   ├── viewmodel/family_viewmodel.dart
│       │   ├── viewmodel/my_vaccines_viewmodel.dart
│       │   ├── viewmodel/profile_viewmodel.dart
│       │   └── viewmodel/vaccines_viewmodel.dart
│       ├── record/
│       │   ├── view/medicine_view.dart
│       │   └── viewmodel/medicine_record_viewmodel.dart
│       ├── reminder/
│       │   ├── view/add_reminder_screen.dart
│       │   ├── view/reminder_list_screen.dart
│       │   ├── viewmodel/add_reminder_viewmodel.dart
│       │   └── viewmodel/reminder_list_viewmodel.dart
│       └── splash/
│           └── view/splash_screen.dart
│
├── test/
│   ├── widget_test.dart
│   ├── data/model/          # 8 model testi
│   ├── data/repository/     # 8 repository testi
│   ├── onboarding/          # 2 viewmodel testi
│   └── presentation/        # 13 viewmodel testi
│
├── assets/
│   ├── icons/
│   └── images/logo.png
│
├── docs/
│   └── BACKEND_TECHNICAL_DOCUMENT.md
│
└── [platform/] android/ · ios/ · macos/ · linux/ · windows/ · web/
```

### Ekran–ViewModel–Backend Endpoint Haritası

| Feature       | Flutter View                        | Flutter ViewModel              | Backend Endpoint               |
|---------------|-------------------------------------|--------------------------------|--------------------------------|
| Splash        | `splash_screen.dart`                | —                              | —                              |
| Onboarding    | `onboarding_screen.dart`            | `onboarding_viewmodel.dart`    | —                              |
| Login         | `login_view.dart`                   | `login_viewmodel.dart`         | `POST /api/Auth/login`         |
| Register      | `register_view.dart`                | `register_viewmodel.dart`      | `POST /api/Auth/register`      |
| Ana Ekran     | `home_screen.dart`                  | `home_viewmodel.dart`          | —                              |
| Gemini AI     | `gemini_assistant_sheet.dart`       | `gemini_viewmodel.dart`        | `POST /api/AI/analyze`         |
| Takvim        | `calendar_screen.dart`              | `calendar_viewmodel.dart`      | `GET /api/Reminders/{userId}`  |
| Harita        | `nearby_facilities_screen.dart`     | `nearby_facilities_viewmodel`  | `GET /api/HealthFacilities` ⚠️ |
| İlaç Listesi  | `medicine_list_screen.dart`         | `medicine_list_viewmodel.dart` | `GET /api/Medicines/user/{id}` |
| İlaç Ekle     | `add_medicine_screen.dart`          | `add_medicine_viewmodel.dart`  | `POST /api/Medicines`          |
| İlaç Kaydı    | `medicine_view.dart`                | `medicine_record_viewmodel`    | `GET /api/Medicines`           |
| Hatırlatıcı   | `reminder_list_screen.dart`         | `reminder_list_viewmodel`      | `GET /api/Reminders/{userId}`  |
| Hatırlatıcı + | `add_reminder_screen.dart`          | `add_reminder_viewmodel`       | `POST /api/Reminders`          |
| Alerji        | `allergies_screen.dart`             | `allergy_viewmodel.dart`       | `GET/POST /api/Allergies`      |
| Hastalık      | `illnesses_screen.dart`             | `illness_viewmodel.dart`       | `GET/POST /api/Illnesses`      |
| Aşılar        | `vaccines_screen.dart`              | `my_vaccines_viewmodel.dart`   | `GET /api/Vaccines/person/{id}`|
| Profil        | `profile_view.dart`                 | `profile_viewmodel.dart`       | `GET/PUT /api/User/profile`    |
| Çocuklar      | `my_children_screen.dart`           | `family_viewmodel.dart`        | `GET/POST /api/Children`       |
| Aile Üyeleri  | `family_members_screen.dart`        | `family_members_viewmodel`     | `GET/POST/DELETE /api/Persons` |

> ⚠️ `HealthFacilitiesController` backend'de boş placeholder — frontend harita ekranı (`nearby_facilities_screen.dart`) mevcut ancak backend'den sağlık tesisi verisi gelmiyor.

---

## Backend — ASP.NET Core 9 (HealthApp)

### Katman Özeti

| Proje                    | Rol                                      |
|--------------------------|------------------------------------------|
| `HealthApp.Domain`       | Entity modeller ve Enum'lar              |
| `HealthApp.DataAccess`   | DbContext, Repository'ler, Migrations    |
| `HealthApp.Business`     | DTO'lar, Service'ler, AutoMapper, JWT    |
| `HealthApp.API`          | Controller'lar, Program.cs, Config       |

### Dosya Ağacı

```
HealthApp/
│
├── HealthApp.sln
├── CLAUDE.md
├── README.md
│
├── docs/
│   ├── API_DOCUMENTATION.md
│   ├── LEARNING_NOTES.md
│   └── TEAM_TASK_PLAN.md
│
├── HealthApp.Domain/                       ── DOMAIN LAYER ──
│   ├── Entities/
│   │   ├── BaseEntity.cs               # Id (Guid), CreatedAt, UpdatedAt
│   │   ├── User.cs                     # Auth: Email, Password (BCrypt), RefreshToken
│   │   ├── Person.cs                   # Profil: BirthDate, Gender, Height, Weight,
│   │   │                               #   IsAccountOwner, ChronicDiseases, Allergies
│   │   ├── Child.cs                    # Çocuk: BirthDate, Gender, Height, Weight
│   │   ├── Vaccine.cs                  # Aşı kaydı: Status, NextDoseDate
│   │   ├── VaccineSchedule.cs          # Tavsiye edilen aşı takvimi
│   │   ├── Medicine.cs                 # İlaç: Frequency, TimesPerDay, StartDate,
│   │   │                               #   AudienceGroup, AudienceBirthDate, PersonId
│   │   ├── Reminder.cs                 # Hatırlatıcı: Type, RepeatType, AudienceGroup,
│   │   │                               #   AudienceBirthDate, PersonId, IsCompleted
│   │   │                               #   (ReminderType/RepeatType/AudienceGroup enum'ları burada)
│   │   ├── Allergy.cs                  # PersonId, Name
│   │   ├── Illness.cs                  # PersonId, Name, DiagnosisDate, Status
│   │   ├── Notification.cs             # PersonId, Title, IsRead
│   │   ├── HealthFacility.cs           # ⚠️ Boş placeholder
│   │   └── MedicineReminderTime.cs
│   └── Enums/
│       ├── Gender.cs                   # Male, Female
│       ├── VaccineStatus.cs            # Pending, Completed, Overdue, Skipped
│       ├── RepeatType.cs               # ⚠️ Boş placeholder (gerçek enum Reminder.cs içinde)
│       └── FrequencyType.cs            # ⚠️ Boş placeholder
│
├── HealthApp.DataAccess/                   ── DATA ACCESS LAYER ──
│   ├── Context/
│   │   └── AppDbContext.cs             # 10 DbSet: Users, Persons, Children, Vaccines,
│   │                                   #   VaccineSchedules, Medicines, Reminders,
│   │                                   #   Allergies, Illnesses, Notifications
│   ├── Repositories/
│   │   ├── IGenericRepository.cs
│   │   ├── GenericRepository.cs        # GetById, GetAll, Add, Update, Delete
│   │   ├── UserRepository.cs
│   │   ├── PersonRepository.cs
│   │   ├── ChildRepository.cs + IChildRepository.cs
│   │   ├── VaccineRepository.cs
│   │   ├── VaccineScheduleRepository.cs
│   │   ├── MedicineRepository.cs + IMedicineRepository.cs
│   │   ├── ReminderRepository.cs + IReminderRepository.cs
│   │   ├── AllergyRepository.cs
│   │   ├── IllnessRepository.cs
│   │   └── NotificationRepository.cs
│   ├── IUnitOfWork.cs
│   ├── UnitOfWork.cs
│   └── Migrations/                     # 13 migration (2026-03-04 → 2026-05-16)
│       ├── 20260304233534_InitialCreate
│       ├── 20260305032547_AddPersonAndChildModels
│       ├── 20260305201211_RenameTimeToCreatedAt
│       ├── 20260305203820_AddRefreshTokenToUser
│       ├── 20260324170029_UpdatePersonEntityForProfile
│       ├── 20260324185731_AddPersonHealthProfileFields
│       ├── 20260420160941_AddedAllergiesAndIllnesses
│       ├── 20260423201613_AddUpdatedAtColumn
│       ├── 20260515171151_AddReminderAudienceGroup
│       ├── 20260515190311_AddMedicineAudienceGroup
│       ├── 20260515191216_AddAudienceBirthDate
│       ├── 20260516093345_AddPersonIsAccountOwner
│       └── 20260516101720_AddPersonIdToMedicineAndReminder
│
├── HealthApp.Business/                     ── BUSINESS LAYER ──
│   ├── DTOs/
│   │   ├── Common/
│   │   │   ├── ApiResponse.cs          # Generic response wrapper
│   │   │   └── Result.cs              # Operation result: Success/Failure
│   │   ├── Gemini/
│   │   │   ├── GeminiAnalysisResponseDTO.cs
│   │   │   └── GeminiAnalyzeRequestDTO.cs
│   │   ├── AuthResponseDTO.cs
│   │   ├── LoginRequestDTO.cs
│   │   ├── RegisterRequestDTO.cs
│   │   ├── RefreshTokenRequestDTO.cs
│   │   ├── UserDTO.cs + UserCreateDTO.cs + UpdateUserDto.cs
│   │   ├── PersonDTO.cs + PersonCreateDTO.cs + PersonUpdateDTO.cs
│   │   ├── ChildDto.cs + CreateChildDto.cs
│   │   ├── VaccineDto.cs + CreateVaccineDto.cs + VaccineScheduleDto.cs
│   │   ├── MedicineDto.cs + CreateMedicineDto.cs
│   │   ├── ReminderDto.cs + CreateReminderDto.cs
│   │   ├── AllergyDto.cs + AllergyCreateDto.cs
│   │   ├── IllnessDto.cs + IllnessCreateDto.cs
│   │   ├── NotificationDto.cs + NotificationCreateDto.cs
│   │   └── HealthFacilityDto.cs
│   ├── Mappings/
│   │   └── MappingProfile.cs           # AutoMapper konfigürasyonu
│   └── Services/
│       ├── AuthService.cs              # Register, Login, RefreshToken + BCrypt
│       ├── JwtService.cs               # Token üretimi ve doğrulama
│       ├── UserService.cs
│       ├── PersonService.cs
│       ├── ChildService.cs             # + Aşı takvimi otomatik üretimi
│       ├── VaccineService.cs
│       ├── VaccineScheduleGenerator.cs # Standart aşı takvimi oluşturur
│       ├── MedicineService.cs
│       ├── ReminderService.cs
│       ├── AllergyService.cs
│       ├── IllnessService.cs
│       ├── NotificationService.cs
│       └── GeminiHealthService.cs      # Gemini API entegrasyonu
│
└── HealthApp.API/                          ── API LAYER ──
    ├── Controllers/
    │   ├── AuthController.cs           # POST register · login · refresh
    │   ├── UserController.cs           # GET|PUT profile · GET|POST users
    │   ├── PersonsController.cs        # GET|POST|PUT persons + /profile
    │   ├── ChildrenController.cs       # CRUD + vaccines + physical-info
    │   ├── VaccinesController.cs       # CRUD + status + child/person filter
    │   ├── MedicinesController.cs      # CRUD + user filter
    │   ├── RemindersController.cs      # CRUD + user filter
    │   ├── AllergiesController.cs      # GET|POST|DELETE + person filter
    │   ├── IllnessesController.cs      # GET|POST|DELETE + person filter
    │   ├── NotificationsController.cs  # GET|POST
    │   ├── AIController.cs             # POST /analyze (Gemini)
    │   ├── HealthFacilitiesController.cs  # ⚠️ Boş — implemente edilmemiş
    │   └── WeatherForecastController.cs   # Scaffolding kalıntısı
    ├── Properties/
    │   └── launchSettings.json         # HTTP: 5105 · HTTPS: 7105
    ├── appsettings.json                # ConnectionString · Jwt · GeminiApi
    ├── appsettings.Development.json
    ├── Program.cs                      # DI · CORS · JWT · EF · AutoMapper
    └── HealthApp.API.http              # REST test dosyası
```

### API Endpoint Özeti

```
Auth
  POST /api/Auth/register
  POST /api/Auth/login
  POST /api/Auth/refresh

User
  GET  /api/User/profile
  PUT  /api/User/profile

Persons
  POST /api/Persons
  POST /api/Persons/profile
  GET  /api/Persons
  GET  /api/Persons/{id}
  PUT  /api/Persons/{id}
  DELETE /api/Persons/{id}

Children
  POST /api/Children
  GET  /api/Children
  DELETE /api/Children/{id}
  GET  /api/Children/standard-schedule
  GET  /api/Children/{id}/vaccines
  POST /api/Children/{id}/vaccines
  POST /api/Children/{childId}/schedules/{scheduleId}/vaccines
  DELETE /api/Children/{id}/schedules/{scheduleId}
  PUT  /api/Children/{id}/physical-info

Vaccines
  POST /api/Vaccines
  GET  /api/Vaccines/child/{childId}
  GET  /api/Vaccines/person/{personId}
  POST /api/Vaccines/{id}/status
  DELETE /api/Vaccines/{id}

Medicines
  POST /api/Medicines
  GET  /api/Medicines
  GET  /api/Medicines/user/{userId}
  PUT  /api/Medicines/{id}
  DELETE /api/Medicines/{id}

Reminders
  GET  /api/Reminders/{userId}
  POST /api/Reminders
  PUT  /api/Reminders/{id}
  DELETE /api/Reminders/{id}

Allergies
  GET  /api/Allergies
  GET  /api/Allergies/person/{personId}
  POST /api/Allergies
  DELETE /api/Allergies/{id}

Illnesses
  GET  /api/Illnesses
  GET  /api/Illnesses/person/{personId}
  POST /api/Illnesses
  DELETE /api/Illnesses/{id}

Notifications
  POST /api/Notifications
  GET  /api/Notifications

AI
  POST /api/AI/analyze

HealthFacilities  ⚠️ Boş — implemente edilmemiş
```

---

## Tutarlılık Durumu (Frontend ↔ Backend)

| Alan               | Flutter Model              | Backend Entity       | Durum |
|--------------------|----------------------------|----------------------|-------|
| Kullanıcı          | `user.dart`                | `User.cs`            | ✅    |
| Kişi (Yetişkin)    | `person.dart`              | `Person.cs`          | ✅    |
| Çocuk              | `child.dart`               | `Child.cs`           | ✅    |
| İlaç               | `medicine.dart`            | `Medicine.cs`        | ✅    |
| Hatırlatıcı        | `reminder.dart`            | `Reminder.cs`        | ✅    |
| Aşı                | `vaccine.dart`             | `Vaccine.cs`         | ✅    |
| Aşı Takvimi        | `vaccine_schedule.dart`    | `VaccineSchedule.cs` | ✅    |
| Alerji             | `allergy.dart`             | `Allergy.cs`         | ✅    |
| Hastalık           | `illness.dart`             | `Illness.cs`         | ✅    |
| Gemini Analiz      | `gemini_analysis.dart`     | `GeminiHealthService`| ✅    |
| Sağlık Tesisi      | `health_facility.dart`     | `HealthFacility.cs`  | ⚠️ Her iki tarafta da boş/placeholder |

---

## Tamamlanan Değişiklikler (2026-05-06 → 2026-05-16)

### 1. Takvim sıklık sorunu (d8927d0)
`calendar_viewmodel.dart` — `_occursOnDay()` metodu ile `daily/weekly/monthly` hatırlatıcılar takvimde doğru günlerde gösteriliyor.

### 2. İlaçlarım + butonu (0bcf48c)
`medicine_list_screen.dart` — İlaç ekleme bottom sheet'i implement edildi (ad, sıklık, saat, not).

### 3. Takvimden ilaç eklenince İlaçlarım'a yansıması (0bcf48c)
`calendar_viewmodel.dart` — Tip `medicine` olduğunda `MedicineRepository.create()` de çağrılıyor. `main.dart`'ta `ProxyProvider3` olarak güncellendi.

### 4. İlaçlarda sıklık düzenlemesi (4676e3b)
`add_reminder_viewmodel.dart` + `add_reminder_screen.dart` — FrequencyType parse logic güncellendi; `monthly` enum değeri eklendi. Backend'den gelen PascalCase, label string veya integer (1/2/3) değerlerinin tümü destekleniyor.

### 5. Aşı manuel ekleme (6cd6d4c)
- `child_repository.dart` → `addVaccineToSchedule()` ve `deleteSchedule()` eklendi
- `vaccines_screen.dart` + `vaccines_viewmodel.dart` → Manuel aşı ekleme UI ve mantığı

### 6. Kişi bazlı ilaçlar, aşılar ve hatırlatıcılar (586e4fe)
Tüm ana sekmelerde aktif kişi seçici eklendi. Ekleme ekranları seçili kişinin ID'sini backend'e gönderiyor.

Etkilenen dosyalar:
- `calendar_screen.dart` → kişi seçimi dropdown
- `calendar_viewmodel.dart` → kişi filtresi
- `add_medicine_screen.dart` / `add_medicine_viewmodel.dart` → kişi ID bağlama
- `add_reminder_screen.dart` / `add_reminder_viewmodel.dart` → kişi ID bağlama
- `vaccines_screen.dart` / `my_vaccines_viewmodel.dart` → kişi bazlı aşı listesi
- `vaccine_repository.dart` → kişi bazlı filtreleme

### 7. Hastalık sekmesi durum güncellemesi (3977ac9)
`illness_repository.dart` — `updateStatus()` eklendi (`PATCH /api/Illnesses/{id}/status`). `illnesses_screen.dart` + `illness_viewmodel.dart` güncellendi.

### 8. Kişi bazlı hastalıklarım sekmesi (72ec6ce)
`illnesses_screen.dart` + `illness_viewmodel.dart` — tam kişi seçici entegrasyonu. `illness_repository.dart` → `getPersons()` + `getIllnessesByPerson()` eklendi.

### 9. Çocuklara özel bildirim ve kişi bazlı alerjiler (26c9a96)
**Model değişikliği:** `person.dart` → `isChild: bool` alanı eklendi (varsayılan: `false`).

**FrequencyType parse güçlendirmesi:** `medicine.dart` → PascalCase (`"Weekly"`), label (`"Haftada Bir"`) ve integer string (`"2"`) değerlerinin tümü destekleniyor.

**Çocukların kişi listesine dahil edilmesi:** `user_repository.dart` → `_childJsonToPerson()` helper ile `/api/Children` çocukları `Person` listesine dönüştürülüp tüm kişi seçicilerde görünüyor.

**Yeni repository metotları:**
- `vaccine_repository.dart` → `addChildManualVaccine()` → `POST /api/children/{childId}/vaccines`

**Güncellenen UI bileşenleri:**
- `allergies_screen.dart` + `allergy_viewmodel.dart` → kişi seçici (çocuklar dahil)
- `medicine_list_screen.dart` / `add_medicine_viewmodel.dart` → çocuk ID desteği
- `vaccines_screen.dart` / `vaccines_viewmodel.dart` → çocuklara özel bildirim UI
- `reminder_list_screen.dart` / `add_reminder_viewmodel.dart` → çocuk bazlı hatırlatıcı

### 10. Kişi rozeti, tarih seçici ve küçük düzeltmeler (unstaged — 2026-05-13)

**Android uygulama adı:**
`android/AndroidManifest.xml` → `android:label` "health_asistants" → "Sağlık Pusulası" olarak güncellendi.

**Kişi rozeti gösterimi (takvim + ana sayfa):**
`calendar_screen.dart` — event tile'larında başlık `"KişiAdı — başlık"` formatında ise kişi adı renkli badge olarak gösteriliyor.
`home_screen.dart` — `_ReminderTile` ve `_AppointmentTile` widget'larında aynı `" — "` ayrıştırma mantığı uygulandı.

**Ana sayfada doğru kullanıcı adı:**
`home_viewmodel.dart` → `personName` getter'ında öncelik sırası düzeltildi: `_currentUser` (giriş yapan kullanıcı) artık `_currentPerson` (kişi profili) önünde kontrol ediliyor.

**Takvim viewmodel bug fix:**
`calendar_viewmodel.dart` → Çocuğa manuel aşı eklenirken `title` yerine `finalTitle` (`"KişiAdı — aşıAdı"` formatındaki nihai başlık) backend'e gönderiliyor.

**Frequency enum — "Tekrarı Yok" seçeneği:**
`frequency_selector.dart` → `Frequency.noRepeat("Tekrarı Yok")` enum değeri eklendi.
`add_reminder_viewmodel.dart` → `"Tekrarı Yok"` etiketi `RepeatType.none` olarak map edildi.

**Hatırlatıcı ekleme — tarih seçici:**
`add_reminder_screen.dart` → Saat seçicinin üstüne tıklanabilir tarih seçici kartı eklendi; `_formatDate()` helper eklendi.
`add_reminder_viewmodel.dart` → `_selectedDate` state, `setSelectedDate()` metodu; `saveReminder()` artık `DateTime.now()` yerine seçilen tarihi kullanıyor. `reset()` de güncellendi.

**Aşı ekleme dialogu iyileştirmeleri:**
`vaccines_screen.dart`:
- Doz alanı varsayılan değeri "1. Doz" olarak ayarlandı
- Dialog'a tarih seçici (`ListTile` + `showDatePicker`) eklendi; `selectedDate` state ile yönetiliyor
- Manuel aşılarda "Planlanan: ..." satırı gizlendi (`isManual` kontrolü)
- Manuel aşı listesinde planlanan tarih yerine gerçek aşı tarihi gösteriliyor
- Eklenen aşının `date` ve `completedDate` alanları seçilen tarihle dolduruluyor

### 11. Uygulama ikonu ve adı (2026-05-13 — 7898851)
`flutter_launcher_icons` paketi `pubspec.yaml`'a eklendi; `assets/images/logo.png` kaynağından Android (`mipmap-*`) ve iOS (`AppIcon.appiconset`) uygulama ikonları yeniden üretildi. Uygulama adı "Sağlık Pusulası" olarak güncellendi.

### 12. Yaş grubu ayrımı: çocuk / yetişkin / yaşlı (2026-05-16 — 3097c37 · a8891e3)

Kişiler yaşlarına göre **çocuk (< 18)**, **yetişkin (18–64)** ve **yaşlı (≥ 65)** olarak 3 gruba ayrıldı. Yaş grubu, kişinin doğum tarihinden **dinamik** hesaplanıyor — snapshot tutulmuyor.

**Backend (a8891e3) — 5 yeni migration:**
- Yeni `AudienceGroup` enum'u (`Adult`, `Elderly`, `Child`) — `Reminder.cs` içinde tanımlı.
- `Reminder` ve `Medicine` entity'lerine `AudienceGroup`, `AudienceBirthDate` ve `PersonId` (hedef aile üyesi; `null` = hesap sahibinin kendisi) alanları eklendi.
- `Person` entity'sine `IsAccountOwner` (bool, default `false`) eklendi — onboarding'de oluşturulan profil `true`, uygulamadan eklenen aile üyeleri `false`.
- DTO güncellemeleri: `CreateMedicineDto`, `CreateReminderDto`, `CreateVaccineDto`, `ReminderDto`, `PersonDTO`.
- `PersonsController` → `DELETE /api/Persons/{id}` eklendi.
- Etkilenen service'ler: `PersonService`, `ChildService`, `MedicineService`, `VaccineService`, `ReminderService`.

**Frontend (3097c37):**
- `core/utils/audience_helper.dart` → `audienceForPerson()`: doğum tarihinden yaş grubunu hesaplar (eşikler: çocuk < 18, yaşlı ≥ 65).
- `reminder.dart` → `AudienceGroup` enum'u; `Reminder` modeline `audienceGroup` + `audienceBirthDate` alanları. `medicine.dart` ve `person.dart` (`isAccountOwner`) güncellendi.
- Yeni bileşen `components/audience_filter_bar.dart` (`AudienceFilterBar`) — alerji/hastalık ekranlarında ortak yaş grubu filtresi.
- Yeni bileşen `components/add_person_sheet.dart` — aile üyesi ekleme bottom sheet'i.
- Yeni ekran `profile/family_members_screen.dart` + `family_members_viewmodel.dart` — aile üyelerini listeleme/ekleme/silme.
- `vaccines_screen.dart` → aşı takibi Çocuk / Yetişkin / Yaşlı olmak üzere 3 sekmeye ayrıldı; `MyVaccinesViewModel` aile üyelerini yaş grubuna göre dağıtıyor. Çocuk sekmesinde `Child` tablosu (otomatik aşı takvimi) korundu.
- Ekleme ekranlarındaki kişi seçici artık her zaman görünür; seçili grup boşsa "bu yaş grubunda kişi yok" ipucu gösteriliyor.

---

## Bilinen Açık Konular

| Konu | Durum |
|------|-------|
| `HealthFacilitiesController` + `HealthFacility.cs` (backend) | ⚠️ Boş placeholder — harita ekranı backend'siz çalışmıyor |
| `FrequencyType.cs` ve `RepeatType.cs` (`Enums/`) | ⚠️ Boş placeholder — gerçek `RepeatType` enum'u `Reminder.cs` içinde |
| `WeatherForecastController.cs` | ⚠️ Scaffolding kalıntısı — kaldırılabilir |
| Takvimden eklenen eski ilaçlar (MedicineId bağlantısı olmayan) takvimde çift görünmesi | ⚠️ Backend `GetAll` sanal reminder mantığı |

---

*Son güncelleme: 2026-05-17*
