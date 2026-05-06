# Sağlık Pusulası — Proje Dosya Yapısı

> Flutter (Dart) · MVVM + Repository Pattern · Android / iOS / Web / Windows / macOS / Linux

---

## Genel Bakış

| Katman       | Dizin                      | Açıklama                                  |
|--------------|----------------------------|-------------------------------------------|
| Core         | `lib/core/`                | Network, tema, sabitler, navigasyon       |
| Data         | `lib/data/`                | Model sınıfları ve repository'ler         |
| Presentation | `lib/presentation/`        | ViewModel'lar, View'lar, bileşenler       |
| Test         | `test/`                    | Birim testler (model + viewmodel)         |
| Assets       | `assets/`                  | Görseller ve ikonlar                      |
| Docs         | `docs/`                    | Teknik belgeler                           |
| Platform     | `android/` `ios/` `web/` … | Platform özgü kod ve yapılandırma         |

---

## Tam Dosya Ağacı

```
saglik-pusulasi/
│
├── pubspec.yaml                        # Bağımlılıklar ve proje tanımı
├── pubspec.lock
├── analysis_options.yaml
├── devtools_options.yaml
├── README.md
├── ClaudeVSCode.md                     # Bu dosya
│
├── lib/                                ── ANA KOD ──
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── network/
│   │   │   └── api_client.dart
│   │   └── utils/
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
│   │           └── helper/
│   │               └── context.dart
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
│   │       ├── medicine_repository.dart
│   │       ├── person_repository.dart
│   │       ├── reminder_repository.dart
│   │       ├── user_repository.dart
│   │       └── vaccine_repository.dart
│   │
│   └── presentation/
│       ├── components/
│       │   ├── dialogs/
│       │   │   └── confirm_dialog.dart
│       │   ├── add_option_button.dart
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
│       │
│       ├── auth/
│       │   ├── login/
│       │   │   ├── view/login_view.dart
│       │   │   └── viewmodel/login_viewmodel.dart
│       │   └── register/
│       │       ├── view/register_view.dart
│       │       └── viewmodel/register_viewmodel.dart
│       │
│       ├── calendar/
│       │   ├── view/calendar_screen.dart
│       │   └── viewmodel/calendar_viewmodel.dart
│       │
│       ├── home/
│       │   ├── view/
│       │   │   ├── gemini_assistant_sheet.dart
│       │   │   └── home_screen.dart
│       │   └── viewmodel/
│       │       ├── gemini_viewmodel.dart
│       │       └── home_viewmodel.dart
│       │
│       ├── illness/
│       │   ├── view/illnesses_screen.dart
│       │   └── viewmodel/illness_viewmodel.dart
│       │
│       ├── map/
│       │   ├── view/nearby_facilities_screen.dart
│       │   └── viewmodel/nearby_facilities_viewmodel.dart
│       │
│       ├── medicine/
│       │   ├── view/
│       │   │   ├── add_medicine_screen.dart
│       │   │   └── medicine_list_screen.dart
│       │   └── viewmodel/
│       │       ├── add_medicine_viewmodel.dart
│       │       └── medicine_list_viewmodel.dart
│       │
│       ├── navigator/
│       │   ├── view/main_screen.dart
│       │   └── viewmodel/navigator_viewmodel.dart
│       │
│       ├── onboarding/
│       │   ├── view/
│       │   │   ├── onboarding_screen.dart
│       │   │   └── profile_entrance_screen.dart
│       │   └── viewmodel/
│       │       ├── onboarding_viewmodel.dart
│       │       └── profile_entrance_viewmodel.dart
│       │
│       ├── profile/
│       │   ├── view/
│       │   │   ├── about_screen.dart
│       │   │   ├── add_vaccine_screen.dart
│       │   │   ├── change_password_screen.dart
│       │   │   ├── edit_profile_screen.dart
│       │   │   ├── my_children_screen.dart
│       │   │   ├── notification_settings_screen.dart
│       │   │   ├── person_detail_screen.dart
│       │   │   ├── privacy_policy_screen.dart
│       │   │   ├── profile_view.dart
│       │   │   ├── terms_of_service_screen.dart
│       │   │   └── vaccines_screen.dart
│       │   └── viewmodel/
│       │       ├── family_viewmodel.dart
│       │       ├── my_vaccines_viewmodel.dart
│       │       ├── profile_viewmodel.dart
│       │       └── vaccines_viewmodel.dart
│       │
│       ├── record/
│       │   ├── view/medicine_view.dart
│       │   └── viewmodel/medicine_record_viewmodel.dart
│       │
│       ├── reminder/
│       │   ├── view/
│       │   │   ├── add_reminder_screen.dart
│       │   │   └── reminder_list_screen.dart
│       │   └── viewmodel/
│       │       ├── add_reminder_viewmodel.dart
│       │       └── reminder_list_viewmodel.dart
│       │
│       └── splash/
│           └── view/splash_screen.dart
│
├── test/                               ── BİRİM TESTLERİ ──
│   ├── widget_test.dart
│   ├── data/
│   │   ├── model/
│   │   │   ├── allergy_illness_test.dart
│   │   │   ├── child_test.dart
│   │   │   ├── health_facility_test.dart
│   │   │   ├── medicine_test.dart
│   │   │   ├── person_test.dart
│   │   │   ├── reminder_test.dart
│   │   │   ├── user_test.dart
│   │   │   └── vaccine_test.dart
│   │   └── repository/
│   │       ├── auth_repository_test.dart
│   │       ├── base_repository_test.dart
│   │       ├── child_repository_test.dart
│   │       ├── medicine_repository_test.dart
│   │       ├── person_repository_test.dart
│   │       ├── reminder_repository_test.dart
│   │       ├── user_repository_test.dart
│   │       └── vaccine_repository_test.dart
│   ├── onboarding/
│   │   ├── onboarding_viewmodel_test.dart
│   │   └── profile_entrance_viewmodel_test.dart
│   └── presentation/
│       ├── auth/
│       │   ├── login_viewmodel_test.dart
│       │   └── register_viewmodel_test.dart
│       ├── calendar/calendar_viewmodel_test.dart
│       ├── home/home_viewmodel_test.dart
│       ├── map/nearby_facilities_viewmodel_test.dart
│       ├── medicine/
│       │   ├── add_medicine_viewmodel_test.dart
│       │   └── medicine_list_viewmodel_test.dart
│       ├── navigator/navigator_viewmodel_test.dart
│       ├── profile/
│       │   ├── profile_viewmodel_test.dart
│       │   └── vaccines_viewmodel_test.dart
│       ├── record/medicine_record_viewmodel_test.dart
│       └── reminder/
│           ├── add_reminder_viewmodel_test.dart
│           └── reminder_list_viewmodel_test.dart
│
├── assets/
│   ├── icons/
│   └── images/
│       └── logo.png
│
├── docs/
│   └── BACKEND_TECHNICAL_DOCUMENT.md   # Backend API teknik belgesi
│
├── android/                            ── PLATFORM: ANDROID ──
├── ios/                                ── PLATFORM: iOS ──
├── macos/                              ── PLATFORM: macOS ──
├── linux/                              ── PLATFORM: Linux ──
├── windows/                            ── PLATFORM: Windows ──
└── web/                                ── PLATFORM: Web ──
```

---

## Ekran / Feature Haritası

| Feature        | View                              | ViewModel                          |
|----------------|-----------------------------------|------------------------------------|
| Splash         | `splash_screen.dart`              | —                                  |
| Onboarding     | `onboarding_screen.dart`          | `onboarding_viewmodel.dart`        |
| Profil Girişi  | `profile_entrance_screen.dart`    | `profile_entrance_viewmodel.dart`  |
| Login          | `login_view.dart`                 | `login_viewmodel.dart`             |
| Register       | `register_view.dart`              | `register_viewmodel.dart`          |
| Ana Ekran      | `home_screen.dart`                | `home_viewmodel.dart`              |
| Gemini AI      | `gemini_assistant_sheet.dart`     | `gemini_viewmodel.dart`            |
| Takvim         | `calendar_screen.dart`            | `calendar_viewmodel.dart`          |
| Harita         | `nearby_facilities_screen.dart`   | `nearby_facilities_viewmodel.dart` |
| İlaç Listesi   | `medicine_list_screen.dart`       | `medicine_list_viewmodel.dart`     |
| İlaç Ekle      | `add_medicine_screen.dart`        | `add_medicine_viewmodel.dart`      |
| İlaç Kaydı     | `medicine_view.dart`              | `medicine_record_viewmodel.dart`   |
| Hatırlatıcı    | `reminder_list_screen.dart`       | `reminder_list_viewmodel.dart`     |
| Hatırlatıcı +  | `add_reminder_screen.dart`        | `add_reminder_viewmodel.dart`      |
| Alerji         | `allergies_screen.dart`           | `allergy_viewmodel.dart`           |
| Hastalık       | `illnesses_screen.dart`           | `illness_viewmodel.dart`           |
| Aşılar         | `vaccines_screen.dart`            | `vaccines_viewmodel.dart`          |
| Profil         | `profile_view.dart`               | `profile_viewmodel.dart`           |
| Aile           | `my_children_screen.dart`         | `family_viewmodel.dart`            |

---

## Backend Notu

Bu repo Flutter frontend'ini içerir. Backend **Visual Studio** (ASP.NET) projesi ayrı tutulmaktadır.  
Teknik API belgesi: [`docs/BACKEND_TECHNICAL_DOCUMENT.md`](docs/BACKEND_TECHNICAL_DOCUMENT.md)

---

*Son güncelleme: 2026-05-06*
