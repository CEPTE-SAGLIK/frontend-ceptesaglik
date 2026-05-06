# Sağlık Pusulası — Backend Teknik Dokümanı

> **ASP.NET Core Web API — 3 Katmanlı Mimari ile Uygulama Planı**
>
> Bu doküman, Flutter (Sağlık Pusulası) mobil uygulamasının analiz edilmesi sonucu üretilmiş olup, backend'in .NET 8 / ASP.NET Core Web API ile geliştirilmesi için kapsamlı bir teknik referans niteliğindedir.

---

## İçindekiler

1. [Genel Mimari Tasarım](#1-genel-mimari-tasarım)
2. [Proje Yapısı (Solution & Projects)](#2-proje-yapısı)
3. [Entity (Model) Sınıfları](#3-entity-model-sınıfları)
4. [DTO Yapıları](#4-dto-yapıları)
5. [Database Tasarımı (Entity İlişkileri)](#5-database-tasarımı)
6. [Repository Katmanı](#6-repository-katmanı)
7. [Service Katmanı](#7-service-katmanı)
8. [Controller & API Endpoint Tasarımı](#8-controller--api-endpoint-tasarımı)
9. [Authentication & Authorization (JWT)](#9-authentication--authorization)
10. [Validation & Error Handling](#10-validation--error-handling)
11. [Dependency Injection Yapısı](#11-dependency-injection-yapısı)
12. [NuGet Paket Önerileri](#12-nuget-paket-önerileri)
13. [MVVM Uyumlu Veri Akışı](#13-mvvm-uyumlu-veri-akışı)
14. [Ekran-Endpoint Eşleme Matrisi](#14-ekran-endpoint-eşleme-matrisi)
15. [Ek Notlar & İleriye Dönük Öneriler](#15-ek-notlar)

---

## 1. Genel Mimari Tasarım

### 3 Katmanlı Mimari (3-Layer Architecture)

Bu projede, anlaşılması ve uygulanması kolay olan **klasik 3 katmanlı mimari** kullanılmaktadır. Her katmanın tek bir sorumluluğu vardır ve veri akışı yukarıdan aşağıya doğru ilerler:

```
┌──────────────────────────────────────────────────────────────┐
│                     API Katmanı (Sunum)                      │
│          Controllers, Middleware, Program.cs, Swagger         │
│                                                              │
│   Kullanıcı isteklerini alır, Business'a yönlendirir,       │
│   sonuçları HTTP response olarak döner.                      │
├──────────────────────────────────────────────────────────────┤
│                   Business Katmanı (İş Mantığı)              │
│         Services, DTOs, Validators, Mappings                 │
│                                                              │
│   İş kurallarını uygular, DTO dönüşümlerini yapar,          │
│   doğrulama (validation) işlemlerini yürütür.                │
├──────────────────────────────────────────────────────────────┤
│                  DataAccess Katmanı (Veri Erişim)            │
│     DbContext, Entities, Repositories, Migrations, Enums     │
│                                                              │
│   Veritabanı ile iletişimi sağlar, Entity tanımlarını        │
│   ve EF Core sorgulamalarını barındırır.                     │
└──────────────────────────────────────────────────────────────┘
```

**Katman Sorumlulukları:**

| Katman | Proje Adı | Sorumluluk |
|--------|-----------|-----------|
| **API** | `SaglikPusulasi.API` | Controller'lar, Middleware, Swagger, JWT konfigürasyonu, Program.cs. Kullanıcıdan gelen HTTP isteklerini karşılar, Business katmanını çağırır. |
| **Business** | `SaglikPusulasi.Business` | Service sınıfları, DTO'lar, FluentValidation kuralları, AutoMapper profilleri. Tüm iş mantığı burada çalışır. |
| **DataAccess** | `SaglikPusulasi.DataAccess` | Entity sınıfları, Enum'lar, `AppDbContext`, Repository sınıfları, EF Core Migrations, Entity konfigürasyonları. Doğrudan veritabanı ile konuşur. |

### Bağımlılık Yönü

```
API  ──────►  Business  ──────►  DataAccess
```

- **API** → Business'ı bilir (Service sınıflarını çağırır)
- **Business** → DataAccess'i bilir (Repository sınıflarını çağırır)
- **DataAccess** → Hiçbir katmanı bilmez (sadece EF Core ve veritabanı)

### Mimari Prensipler

- **Separation of Concerns:** Her katman kendi sorumluluğunu taşır, birbirinin işine karışmaz
- **Repository Pattern:** Veritabanı işlemleri Repository sınıfları üzerinden yapılır (doğrudan `DbContext` kullanılmaz)
- **Result Pattern:** Service metotları `Result<T>` döner (Flutter tarafındaki `Result<T>` ile uyumlu)
- **DTO Pattern:** Entity'ler hiçbir zaman doğrudan API'den dışarı çıkmaz, DTO'lara dönüştürülür

---

## 2. Proje Yapısı

```
SaglikPusulasi.sln
│
├── src/
│   ├── SaglikPusulasi.DataAccess/                 # Veri Erişim Katmanı
│   │   ├── Entities/
│   │   │   ├── BaseEntity.cs
│   │   │   ├── User.cs
│   │   │   ├── Person.cs
│   │   │   ├── Child.cs
│   │   │   ├── Medicine.cs
│   │   │   ├── MedicineReminderTime.cs
│   │   │   ├── Vaccine.cs
│   │   │   ├── VaccineSchedule.cs
│   │   │   ├── Reminder.cs
│   │   │   ├── Illness.cs
│   │   │   ├── Allergy.cs
│   │   │   ├── HealthFacility.cs
│   │   │   ├── BlogArticle.cs
│   │   │   ├── NotificationSetting.cs
│   │   │   └── RefreshToken.cs
│   │   ├── Enums/
│   │   │   ├── Gender.cs
│   │   │   ├── FrequencyType.cs
│   │   │   ├── VaccineStatus.cs
│   │   │   ├── ReminderType.cs
│   │   │   ├── RepeatType.cs
│   │   │   ├── IllnessStatus.cs
│   │   │   ├── FacilityType.cs
│   │   │   └── Relationship.cs
│   │   ├── Context/
│   │   │   └── AppDbContext.cs
│   │   ├── Configurations/
│   │   │   ├── UserConfiguration.cs
│   │   │   ├── PersonConfiguration.cs
│   │   │   ├── ChildConfiguration.cs
│   │   │   ├── MedicineConfiguration.cs
│   │   │   ├── VaccineConfiguration.cs
│   │   │   ├── VaccineScheduleConfiguration.cs
│   │   │   ├── ReminderConfiguration.cs
│   │   │   ├── IllnessConfiguration.cs
│   │   │   ├── AllergyConfiguration.cs
│   │   │   └── RefreshTokenConfiguration.cs
│   │   ├── Repositories/
│   │   │   ├── GenericRepository.cs
│   │   │   ├── UserRepository.cs
│   │   │   ├── PersonRepository.cs
│   │   │   ├── ChildRepository.cs
│   │   │   ├── MedicineRepository.cs
│   │   │   ├── VaccineRepository.cs
│   │   │   └── ReminderRepository.cs
│   │   └── Migrations/
│   │
│   ├── SaglikPusulasi.Business/                   # İş Mantığı Katmanı
│   │   ├── DTOs/
│   │   │   ├── Auth/
│   │   │   │   ├── LoginRequestDto.cs
│   │   │   │   ├── RegisterRequestDto.cs
│   │   │   │   ├── AuthResponseDto.cs
│   │   │   │   ├── ForgotPasswordRequestDto.cs
│   │   │   │   ├── ChangePasswordRequestDto.cs
│   │   │   │   └── RefreshTokenRequestDto.cs
│   │   │   ├── User/
│   │   │   │   ├── UserDto.cs
│   │   │   │   └── UpdateUserDto.cs
│   │   │   ├── Person/
│   │   │   │   ├── PersonDto.cs
│   │   │   │   ├── CreatePersonDto.cs
│   │   │   │   └── UpdatePersonDto.cs
│   │   │   ├── Child/
│   │   │   │   ├── ChildDto.cs
│   │   │   │   ├── CreateChildDto.cs
│   │   │   │   └── UpdateChildDto.cs
│   │   │   ├── Medicine/
│   │   │   │   ├── MedicineDto.cs
│   │   │   │   ├── CreateMedicineDto.cs
│   │   │   │   └── UpdateMedicineDto.cs
│   │   │   ├── Vaccine/
│   │   │   │   ├── VaccineDto.cs
│   │   │   │   ├── VaccineScheduleDto.cs
│   │   │   │   ├── CreateVaccineDto.cs
│   │   │   │   └── UpdateVaccineStatusDto.cs
│   │   │   ├── Reminder/
│   │   │   │   ├── ReminderDto.cs
│   │   │   │   ├── CreateReminderDto.cs
│   │   │   │   └── UpdateReminderDto.cs
│   │   │   ├── Illness/
│   │   │   │   ├── IllnessDto.cs
│   │   │   │   └── CreateIllnessDto.cs
│   │   │   ├── Allergy/
│   │   │   │   ├── AllergyDto.cs
│   │   │   │   └── CreateAllergyDto.cs
│   │   │   ├── Blog/
│   │   │   │   └── BlogArticleDto.cs
│   │   │   ├── HealthFacility/
│   │   │   │   └── HealthFacilityDto.cs
│   │   │   └── Common/
│   │   │       ├── ApiResponse.cs
│   │   │       ├── PaginatedResult.cs
│   │   │       └── Result.cs
│   │   ├── Services/
│   │   │   ├── AuthService.cs
│   │   │   ├── UserService.cs
│   │   │   ├── PersonService.cs
│   │   │   ├── ChildService.cs
│   │   │   ├── MedicineService.cs
│   │   │   ├── VaccineService.cs
│   │   │   ├── VaccineScheduleGenerator.cs
│   │   │   ├── ReminderService.cs
│   │   │   ├── BlogService.cs
│   │   │   ├── HealthFacilityService.cs
│   │   │   ├── NotificationService.cs
│   │   │   └── TokenService.cs
│   │   ├── Validators/
│   │   │   ├── LoginRequestValidator.cs
│   │   │   ├── RegisterRequestValidator.cs
│   │   │   ├── CreatePersonValidator.cs
│   │   │   ├── CreateChildValidator.cs
│   │   │   ├── CreateMedicineValidator.cs
│   │   │   └── CreateReminderValidator.cs
│   │   └── Mappings/
│   │       └── MappingProfile.cs
│   │
│   └── SaglikPusulasi.API/                        # API Katmanı
│       ├── Controllers/
│       │   ├── AuthController.cs
│       │   ├── UsersController.cs
│       │   ├── PersonsController.cs
│       │   ├── ChildrenController.cs
│       │   ├── MedicinesController.cs
│       │   ├── VaccinesController.cs
│       │   ├── RemindersController.cs
│       │   ├── BlogController.cs
│       │   ├── HealthFacilitiesController.cs
│       │   └── NotificationsController.cs
│       ├── Middleware/
│       │   └── ExceptionHandlingMiddleware.cs
│       ├── Program.cs
│       ├── appsettings.json
│       └── appsettings.Development.json
│
└── tests/
    └── SaglikPusulasi.Tests/
```

---

## 3. Entity (Model) Sınıfları

### 3.1 Base Entity

```csharp
// DataAccess/Entities/BaseEntity.cs
public abstract class BaseEntity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
```

> **Not:** Tüm entity'ler `BaseEntity`'den türer. `Id`, `CreatedAt` ve `UpdatedAt` alanları otomatik olarak her tabloya eklenir.

### 3.2 User Entity

```csharp
// DataAccess/Entities/User.cs
public class User : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Surname { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public bool EmailConfirmed { get; set; }
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }

    // Navigation Properties
    public Person? PersonProfile { get; set; }
    public ICollection<Child> Children { get; set; } = new List<Child>();
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public NotificationSetting? NotificationSetting { get; set; }
}
```

### 3.3 Person Entity

```csharp
// DataAccess/Entities/Person.cs
public class Person : BaseEntity
{
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Surname { get; set; } = string.Empty;
    public Relationship Relationship { get; set; }
    public DateTime BirthDate { get; set; }
    public Gender Gender { get; set; }
    public double? Height { get; set; }  // cm
    public double? Weight { get; set; }  // kg

    // Navigation Properties
    public User User { get; set; } = null!;
    public ICollection<Illness> Illnesses { get; set; } = new List<Illness>();
    public ICollection<Allergy> Allergies { get; set; } = new List<Allergy>();
    public ICollection<Medicine> Medicines { get; set; } = new List<Medicine>();
    public ICollection<Vaccine> Vaccines { get; set; } = new List<Vaccine>();
    public ICollection<Reminder> Reminders { get; set; } = new List<Reminder>();
}
```

### 3.4 Child Entity

```csharp
// DataAccess/Entities/Child.cs
public class Child : BaseEntity
{
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime BirthDate { get; set; }
    public Gender Gender { get; set; }

    // Navigation Properties
    public User User { get; set; } = null!;
    public ICollection<VaccineSchedule> VaccineSchedules { get; set; } = new List<VaccineSchedule>();
}
```

### 3.5 Medicine Entity

```csharp
// DataAccess/Entities/Medicine.cs
public class Medicine : BaseEntity
{
    public Guid PersonId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? UsageInstructions { get; set; }
    public FrequencyType FrequencyType { get; set; }
    public int TimesPerDay { get; set; } = 1;
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public string? Notes { get; set; }

    // Navigation Properties
    public Person Person { get; set; } = null!;
    public ICollection<MedicineReminderTime> ReminderTimes { get; set; } = new List<MedicineReminderTime>();
}
```

```csharp
// DataAccess/Entities/MedicineReminderTime.cs
// İlaç hatırlatma saatleri (ayrı tablo — çoklu saat desteği)
public class MedicineReminderTime : BaseEntity
{
    public Guid MedicineId { get; set; }
    public TimeSpan Time { get; set; }   // Saat:Dakika

    public Medicine Medicine { get; set; } = null!;
}
```

### 3.6 Vaccine Entity

```csharp
// DataAccess/Entities/Vaccine.cs
public class Vaccine : BaseEntity
{
    public Guid VaccineScheduleId { get; set; }
    public Guid? ChildId { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public string Dose { get; set; } = string.Empty;
    public VaccineStatus Status { get; set; } = VaccineStatus.Pending;
    public string? Description { get; set; }
    public DateTime? NextDoseDate { get; set; }
    public DateTime? CompletedDate { get; set; }

    // Navigation Properties
    public VaccineSchedule VaccineSchedule { get; set; } = null!;
    public Child? Child { get; set; }
}
```

### 3.7 VaccineSchedule Entity

```csharp
// DataAccess/Entities/VaccineSchedule.cs
public class VaccineSchedule : BaseEntity
{
    public Guid ChildId { get; set; }
    public string Period { get; set; } = string.Empty;      // "Doğumda", "1. Ay Sonu", ...
    public int MonthIndex { get; set; }                       // 0, 1, 2, 4, 6, 12, 18, 24, 48, 72
    public DateTime ScheduledDate { get; set; }

    // Navigation Properties
    public Child Child { get; set; } = null!;
    public ICollection<Vaccine> Vaccines { get; set; } = new List<Vaccine>();
}
```

### 3.8 Reminder Entity

```csharp
// DataAccess/Entities/Reminder.cs
public class Reminder : BaseEntity
{
    public Guid PersonId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public ReminderType Type { get; set; }
    public DateTime DateTime { get; set; }
    public RepeatType RepeatType { get; set; } = RepeatType.None;
    public bool IsActive { get; set; } = true;
    public Guid? RelatedItemId { get; set; }

    // Navigation Properties
    public Person Person { get; set; } = null!;
}
```

### 3.9 Illness Entity

```csharp
// DataAccess/Entities/Illness.cs
public class Illness : BaseEntity
{
    public Guid PersonId { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime DiagnosisDate { get; set; }
    public IllnessStatus Status { get; set; }
    public string? DoctorNotes { get; set; }

    // Navigation Properties
    public Person Person { get; set; } = null!;
}
```

### 3.10 Allergy Entity

```csharp
// DataAccess/Entities/Allergy.cs
public class Allergy : BaseEntity
{
    public Guid PersonId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    // Navigation Properties
    public Person Person { get; set; } = null!;
}
```

### 3.11 RefreshToken Entity

```csharp
// DataAccess/Entities/RefreshToken.cs
public class RefreshToken : BaseEntity
{
    public Guid UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public DateTime? RevokedAt { get; set; }
    public string? ReplacedByToken { get; set; }
    public bool IsExpired => DateTime.UtcNow >= ExpiresAt;
    public bool IsRevoked => RevokedAt != null;
    public bool IsActive => !IsRevoked && !IsExpired;

    // Navigation Properties
    public User User { get; set; } = null!;
}
```

### 3.12 BlogArticle Entity

```csharp
// DataAccess/Entities/BlogArticle.cs
public class BlogArticle : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string Summary { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;  // Beslenme, Egzersiz, Ruh Sağlığı, Hastalıklar, Spor
    public string? ImageUrl { get; set; }
    public string Author { get; set; } = string.Empty;
    public string ReadTime { get; set; } = string.Empty;  // "5 dk"
    public bool IsFeatured { get; set; }
    public bool IsPublished { get; set; } = true;
    public int ViewCount { get; set; }
}
```

### 3.13 HealthFacility Entity

```csharp
// DataAccess/Entities/HealthFacility.cs
public class HealthFacility : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Subtitle { get; set; } = string.Empty;
    public FacilityType Type { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string? Address { get; set; }
    public string? Phone { get; set; }
    public bool IsDuty { get; set; }  // Nöbetçi mi?
}
```

### 3.14 NotificationSetting Entity

```csharp
// DataAccess/Entities/NotificationSetting.cs
public class NotificationSetting : BaseEntity
{
    public Guid UserId { get; set; }
    public bool AllNotifications { get; set; } = true;
    public bool MedicineReminders { get; set; } = true;
    public bool VaccineReminders { get; set; } = true;
    public bool AppointmentReminders { get; set; } = true;
    public bool HealthTips { get; set; } = true;

    // Navigation Properties
    public User User { get; set; } = null!;
}
```

### 3.15 Enum Tanımları

```csharp
// DataAccess/Enums/ klasörü altında her biri ayrı dosyada

public enum Gender { Male, Female }
public enum FrequencyType { Daily, EveryOtherDay, Weekly, Custom }
public enum VaccineStatus { Pending, Completed, Overdue, Skipped }
public enum ReminderType { Medicine, Vaccine, Appointment, Custom }
public enum RepeatType { None, Daily, Weekly, Monthly }
public enum IllnessStatus { Active, Recovered, Monitoring }
public enum FacilityType { Hospital, Clinic, Pharmacy }
public enum Relationship { Self, Child, Parent, Spouse, Sibling, Other }
```

---

## 4. DTO Yapıları

> Tüm DTO'lar `SaglikPusulasi.Business/DTOs/` klasörü altında bulunur.

### 4.1 Auth DTO'ları

```csharp
// Business/DTOs/Auth/

public record LoginRequestDto(string Email, string Password);

public record RegisterRequestDto(
    string Name,
    string Surname,
    string Email,
    string Password,
    string ConfirmPassword
);

public record AuthResponseDto(
    string Token,
    string RefreshToken,
    DateTime ExpiresAt,
    UserDto User
);

public record ForgotPasswordRequestDto(string Email);

public record ChangePasswordRequestDto(
    string CurrentPassword,
    string NewPassword,
    string ConfirmNewPassword
);

public record RefreshTokenRequestDto(string RefreshToken);
```

### 4.2 User DTO'ları

```csharp
// Business/DTOs/User/

// API'den dönen kullanıcı bilgisi
public record UserDto(
    Guid Id,
    string Name,
    string Surname,
    string Email,
    DateTime CreatedAt
);

// Kullanıcı güncelleme
public record UpdateUserDto(
    string Name,
    string Surname,
    string Email
);
```

### 4.3 Person DTO'ları

```csharp
// Business/DTOs/Person/

public record PersonDto(
    Guid Id,
    Guid UserId,
    string Name,
    string Surname,
    string Relationship,
    DateTime BirthDate,
    string Gender,
    double? Height,
    double? Weight,
    List<IllnessDto> Illnesses,
    List<AllergyDto> Allergies,
    List<MedicineDto> Medicines,
    List<VaccineDto> Vaccines
);

// Profil oluşturma (ProfileEntrance ekranı)
public record CreatePersonDto(
    DateTime BirthDate,
    string Gender,
    double? Height,
    double? Weight,
    List<CreateIllnessDto> Illnesses,
    List<CreateAllergyDto> Allergies
);

public record UpdatePersonDto(
    string? Name,
    string? Surname,
    string? Relationship,
    DateTime? BirthDate,
    string? Gender,
    double? Height,
    double? Weight
);
```

### 4.4 Child DTO'ları

```csharp
// Business/DTOs/Child/

public record ChildDto(
    Guid Id,
    string Name,
    DateTime BirthDate,
    string Gender,
    int AgeInMonths,
    string AgeText,
    List<VaccineScheduleDto> VaccineSchedule
);

public record CreateChildDto(
    string Name,
    DateTime BirthDate,
    string Gender       // "male" / "female"
);

public record UpdateChildDto(
    string? Name,
    DateTime? BirthDate,
    string? Gender
);
```

### 4.5 Medicine DTO'ları

```csharp
// Business/DTOs/Medicine/

public record MedicineDto(
    Guid Id,
    string Name,
    string? UsageInstructions,
    string FrequencyType,
    int TimesPerDay,
    List<string> ReminderTimes,   // "08:00", "20:00"
    DateTime StartDate,
    DateTime? EndDate,
    string? Notes,
    Guid? PersonId
);

public record CreateMedicineDto(
    string Name,
    string? UsageInstructions,
    string FrequencyType,
    int TimesPerDay,
    List<string>? ReminderTimes,
    DateTime StartDate,
    DateTime? EndDate,
    string? Notes,
    Guid? PersonId
);

public record UpdateMedicineDto(
    string? Name,
    string? UsageInstructions,
    string? FrequencyType,
    int? TimesPerDay,
    List<string>? ReminderTimes,
    DateTime? StartDate,
    DateTime? EndDate,
    string? Notes
);
```

### 4.6 Vaccine & Schedule DTO'ları

```csharp
// Business/DTOs/Vaccine/

public record VaccineDto(
    Guid Id,
    string Name,
    DateTime Date,
    string Dose,
    string Status,
    string? Description,
    DateTime? NextDoseDate,
    DateTime? CompletedDate,
    Guid? ChildId
);

public record VaccineScheduleDto(
    Guid Id,
    string Period,
    int MonthIndex,
    DateTime ScheduledDate,
    List<VaccineDto> Vaccines,
    bool IsAllCompleted,
    int CompletedCount,
    int PendingCount
);

// Manuel aşı ekleme
public record CreateVaccineDto(
    string Name,
    string Dose,
    string? Status,
    string? Description
);

// Aşı durumu güncelleme
public record UpdateVaccineStatusDto(string Status);  // "completed", "pending", "skipped"
```

### 4.7 Reminder DTO'ları

```csharp
// Business/DTOs/Reminder/

public record ReminderDto(
    Guid Id,
    Guid PersonId,
    string Title,
    string? Description,
    string Type,
    DateTime DateTime,
    string RepeatType,
    bool IsActive,
    Guid? RelatedItemId,
    DateTime CreatedAt
);

public record CreateReminderDto(
    string Title,
    string? Description,
    string Type,             // "medicine", "vaccine", "appointment", "custom"
    DateTime DateTime,
    string RepeatType,       // "none", "daily", "weekly", "monthly"
    Guid? PersonId,
    Guid? RelatedItemId
);

public record UpdateReminderDto(
    string? Title,
    string? Description,
    string? Type,
    DateTime? DateTime,
    string? RepeatType,
    bool? IsActive,
    Guid? RelatedItemId
);
```

### 4.8 Illness & Allergy DTO'ları

```csharp
// Business/DTOs/Illness/ ve Business/DTOs/Allergy/

public record IllnessDto(
    Guid Id,
    string Name,
    DateTime DiagnosisDate,
    string Status,
    string? DoctorNotes
);

public record CreateIllnessDto(
    string Name,
    DateTime? DiagnosisDate,
    string? Status,
    string? DoctorNotes
);

public record AllergyDto(
    Guid Id,
    string Name,
    string? Description,
    DateTime CreatedDate
);

public record CreateAllergyDto(
    string Name,
    string? Description
);
```

### 4.9 Ortak DTO'lar

```csharp
// Business/DTOs/Common/

// ApiResponse<T> — Standart API yanıt sarmalayıcısı
public class ApiResponse<T>
{
    public bool Success { get; set; }
    public T? Data { get; set; }
    public string? Message { get; set; }
    public List<string>? Errors { get; set; }

    public static ApiResponse<T> Ok(T data, string? message = null) =>
        new() { Success = true, Data = data, Message = message };

    public static ApiResponse<T> Fail(string message, List<string>? errors = null) =>
        new() { Success = false, Message = message, Errors = errors };
}

// PaginatedResult<T> — Sayfalanmış sonuçlar
public class PaginatedResult<T>
{
    public List<T> Items { get; set; } = new();
    public int TotalCount { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
    public bool HasPreviousPage => PageNumber > 1;
    public bool HasNextPage => PageNumber < TotalPages;
}

// Result<T> — Service'lerin dönüş tipi
public class Result<T>
{
    public bool IsSuccess { get; set; }
    public T? Data { get; set; }
    public string? ErrorMessage { get; set; }
    public List<string>? Errors { get; set; }

    public static Result<T> Success(T data) =>
        new() { IsSuccess = true, Data = data };

    public static Result<T> Failure(string error) =>
        new() { IsSuccess = false, ErrorMessage = error };

    public static Result<T> Failure(string error, List<string> errors) =>
        new() { IsSuccess = false, ErrorMessage = error, Errors = errors };
}

// Diğer DTO'lar
public record HealthFacilityDto(
    Guid Id,
    string Name,
    string Subtitle,
    string Type,
    double Latitude,
    double Longitude,
    string? Address,
    string? Phone,
    bool IsDuty,
    string? DistanceText,
    double? DistanceValue
);

public record BlogArticleDto(
    Guid Id,
    string Title,
    string Summary,
    string Content,
    string Category,
    string? ImageUrl,
    string Author,
    string ReadTime,
    bool IsFeatured,
    DateTime CreatedAt
);

public record NotificationSettingDto(
    bool AllNotifications,
    bool MedicineReminders,
    bool VaccineReminders,
    bool AppointmentReminders,
    bool HealthTips
);
```

---

## 5. Database Tasarımı

### 5.1 ER Diyagramı (İlişki Haritası)

```
┌──────────┐       1:1        ┌──────────┐
│   User   │──────────────────│  Person   │ (self profile)
│          │                  │           │
│          │  1:N             │           │──── 1:N ──── Illness
│          │                  │           │──── 1:N ──── Allergy
│          │                  │           │──── 1:N ──── Medicine ──── 1:N ──── MedicineReminderTime
│          │                  │           │──── 1:N ──── Vaccine (Person vaccines)
│          │                  │           │──── 1:N ──── Reminder
│          │                  └───────────┘
│          │
│          │  1:N             ┌──────────┐
│          │──────────────────│  Child    │
│          │                  │           │──── 1:N ──── VaccineSchedule ──── 1:N ──── Vaccine
│          │                  └───────────┘
│          │
│          │  1:N             ┌──────────────┐
│          │──────────────────│ RefreshToken  │
│          │                  └──────────────┘
│          │
│          │  1:1             ┌─────────────────────┐
│          │──────────────────│ NotificationSetting  │
└──────────┘                  └─────────────────────┘

(Bağımsız Tablolar)
┌───────────────┐    ┌──────────────┐
│ BlogArticle   │    │HealthFacility│
└───────────────┘    └──────────────┘
```

### 5.2 Tablo Detayları

| Tablo | PK | Önemli FK'lar | Açıklama |
|-------|-----|---------------|----------|
| **Users** | Id (GUID) | — | Kimlik doğrulama + temel bilgiler |
| **Persons** | Id (GUID) | UserId → Users | Kullanıcı profili + aile üyeleri |
| **Children** | Id (GUID) | UserId → Users | Bebek/çocuk aşı takibi |
| **VaccineSchedules** | Id (GUID) | ChildId → Children | Aşı takvimi dönemleri |
| **Vaccines** | Id (GUID) | VaccineScheduleId → VaccineSchedules, ChildId → Children | Bireysel aşı kayıtları |
| **Medicines** | Id (GUID) | PersonId → Persons | İlaç kayıtları |
| **MedicineReminderTimes** | Id (GUID) | MedicineId → Medicines | İlaç hatırlatma saatleri |
| **Reminders** | Id (GUID) | PersonId → Persons | Genel hatırlatmalar |
| **Illnesses** | Id (GUID) | PersonId → Persons | Hastalık kayıtları |
| **Allergies** | Id (GUID) | PersonId → Persons | Alerji kayıtları |
| **RefreshTokens** | Id (GUID) | UserId → Users | JWT refresh token yönetimi |
| **NotificationSettings** | Id (GUID) | UserId → Users | Bildirim tercihleri |
| **BlogArticles** | Id (GUID) | — | Sağlık blog yazıları |
| **HealthFacilities** | Id (GUID) | — | Hastane/eczane/sağlık ocağı |

### 5.3 AppDbContext

```csharp
// DataAccess/Context/AppDbContext.cs
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Person> Persons => Set<Person>();
    public DbSet<Child> Children => Set<Child>();
    public DbSet<Medicine> Medicines => Set<Medicine>();
    public DbSet<MedicineReminderTime> MedicineReminderTimes => Set<MedicineReminderTime>();
    public DbSet<Vaccine> Vaccines => Set<Vaccine>();
    public DbSet<VaccineSchedule> VaccineSchedules => Set<VaccineSchedule>();
    public DbSet<Reminder> Reminders => Set<Reminder>();
    public DbSet<Illness> Illnesses => Set<Illness>();
    public DbSet<Allergy> Allergies => Set<Allergy>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<NotificationSetting> NotificationSettings => Set<NotificationSetting>();
    public DbSet<BlogArticle> BlogArticles => Set<BlogArticle>();
    public DbSet<HealthFacility> HealthFacilities => Set<HealthFacility>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Tüm konfigürasyonları otomatik uygula
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }

    // SaveChanges override — UpdatedAt otomatik güncellemesi
    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = DateTime.UtcNow;
            }
        }
        return base.SaveChangesAsync(cancellationToken);
    }
}
```

### 5.4 Index Önerileri

```sql
-- Performans için önerilen indeksler
CREATE INDEX IX_Persons_UserId ON Persons(UserId);
CREATE INDEX IX_Children_UserId ON Children(UserId);
CREATE INDEX IX_Medicines_PersonId ON Medicines(PersonId);
CREATE INDEX IX_Vaccines_VaccineScheduleId ON Vaccines(VaccineScheduleId);
CREATE INDEX IX_Vaccines_ChildId ON Vaccines(ChildId);
CREATE INDEX IX_VaccineSchedules_ChildId ON VaccineSchedules(ChildId);
CREATE INDEX IX_Reminders_PersonId ON Reminders(PersonId);
CREATE INDEX IX_Reminders_DateTime ON Reminders(DateTime);
CREATE INDEX IX_Illnesses_PersonId ON Illnesses(PersonId);
CREATE INDEX IX_Allergies_PersonId ON Allergies(PersonId);
CREATE INDEX IX_RefreshTokens_UserId ON RefreshTokens(UserId);
CREATE INDEX IX_RefreshTokens_Token ON RefreshTokens(Token);
CREATE UNIQUE INDEX IX_Users_Email ON Users(Email);
CREATE UNIQUE INDEX IX_NotificationSettings_UserId ON NotificationSettings(UserId);
CREATE INDEX IX_BlogArticles_Category ON BlogArticles(Category);
CREATE INDEX IX_HealthFacilities_Type ON HealthFacilities(Type);
```

---

## 6. Repository Katmanı

> Repository'ler `SaglikPusulasi.DataAccess/Repositories/` klasöründe bulunur.
> `AppDbContext`'i doğrudan kullanırlar. Dışarıya interface yerine concrete sınıf olarak açılırlar.

### 6.1 GenericRepository (Temel CRUD)

```csharp
// DataAccess/Repositories/GenericRepository.cs
public class GenericRepository<T> where T : BaseEntity
{
    protected readonly AppDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public GenericRepository(AppDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(Guid id)
    {
        return await _dbSet.FindAsync(id);
    }

    public async Task<List<T>> GetAllAsync()
    {
        return await _dbSet.ToListAsync();
    }

    public async Task<List<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await _dbSet.Where(predicate).ToListAsync();
    }

    public async Task<T> AddAsync(T entity)
    {
        await _dbSet.AddAsync(entity);
        await _context.SaveChangesAsync();
        return entity;
    }

    public async Task UpdateAsync(T entity)
    {
        _dbSet.Update(entity);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(T entity)
    {
        _dbSet.Remove(entity);
        await _context.SaveChangesAsync();
    }

    public async Task<bool> ExistsAsync(Guid id)
    {
        return await _dbSet.AnyAsync(e => e.Id == id);
    }
}
```

### 6.2 Özelleştirilmiş Repository'ler

Her entity için genel CRUD yeterli olmadığında, `GenericRepository<T>`'den türeyen özel repository sınıfları yazılır:

```csharp
// DataAccess/Repositories/UserRepository.cs
public class UserRepository : GenericRepository<User>
{
    public UserRepository(AppDbContext context) : base(context) { }

    public async Task<User?> GetByEmailAsync(string email)
    {
        return await _dbSet.FirstOrDefaultAsync(u => u.Email == email && !u.IsDeleted);
    }

    public async Task<bool> EmailExistsAsync(string email)
    {
        return await _dbSet.AnyAsync(u => u.Email == email);
    }
}
```

```csharp
// DataAccess/Repositories/PersonRepository.cs
public class PersonRepository : GenericRepository<Person>
{
    public PersonRepository(AppDbContext context) : base(context) { }

    public async Task<Person?> GetWithDetailsAsync(Guid id)
    {
        return await _dbSet
            .Include(p => p.Illnesses)
            .Include(p => p.Allergies)
            .Include(p => p.Medicines).ThenInclude(m => m.ReminderTimes)
            .Include(p => p.Vaccines)
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<List<Person>> GetByUserIdAsync(Guid userId)
    {
        return await _dbSet
            .Include(p => p.Illnesses)
            .Include(p => p.Allergies)
            .Where(p => p.UserId == userId)
            .ToListAsync();
    }

    public async Task<Person?> GetSelfProfileAsync(Guid userId)
    {
        return await _dbSet
            .Include(p => p.Illnesses)
            .Include(p => p.Allergies)
            .Include(p => p.Medicines).ThenInclude(m => m.ReminderTimes)
            .Include(p => p.Vaccines)
            .FirstOrDefaultAsync(p => p.UserId == userId && p.Relationship == Relationship.Self);
    }
}
```

```csharp
// DataAccess/Repositories/ChildRepository.cs
public class ChildRepository : GenericRepository<Child>
{
    public ChildRepository(AppDbContext context) : base(context) { }

    public async Task<Child?> GetWithVaccineScheduleAsync(Guid id)
    {
        return await _dbSet
            .Include(c => c.VaccineSchedules)
                .ThenInclude(vs => vs.Vaccines)
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task<List<Child>> GetByUserIdAsync(Guid userId)
    {
        return await _dbSet
            .Include(c => c.VaccineSchedules)
                .ThenInclude(vs => vs.Vaccines)
            .Where(c => c.UserId == userId)
            .ToListAsync();
    }
}
```

```csharp
// DataAccess/Repositories/MedicineRepository.cs
public class MedicineRepository : GenericRepository<Medicine>
{
    public MedicineRepository(AppDbContext context) : base(context) { }

    public async Task<List<Medicine>> GetByPersonIdAsync(Guid personId)
    {
        return await _dbSet
            .Include(m => m.ReminderTimes)
            .Where(m => m.PersonId == personId)
            .ToListAsync();
    }

    public async Task<Medicine?> GetWithReminderTimesAsync(Guid id)
    {
        return await _dbSet
            .Include(m => m.ReminderTimes)
            .FirstOrDefaultAsync(m => m.Id == id);
    }

    public async Task<List<Medicine>> GetActiveMedicinesAsync(Guid personId)
    {
        var today = DateTime.UtcNow.Date;
        return await _dbSet
            .Include(m => m.ReminderTimes)
            .Where(m => m.PersonId == personId &&
                        m.StartDate <= today &&
                        (m.EndDate == null || m.EndDate >= today))
            .ToListAsync();
    }
}
```

```csharp
// DataAccess/Repositories/ReminderRepository.cs
public class ReminderRepository : GenericRepository<Reminder>
{
    public ReminderRepository(AppDbContext context) : base(context) { }

    public async Task<List<Reminder>> GetByPersonIdAsync(Guid personId)
    {
        return await _dbSet
            .Where(r => r.PersonId == personId)
            .OrderBy(r => r.DateTime)
            .ToListAsync();
    }

    public async Task<List<Reminder>> GetByDateAsync(Guid personId, DateTime date)
    {
        return await _dbSet
            .Where(r => r.PersonId == personId && r.DateTime.Date == date.Date)
            .OrderBy(r => r.DateTime)
            .ToListAsync();
    }

    public async Task<List<Reminder>> GetUpcomingAsync(Guid personId, int days = 7)
    {
        var endDate = DateTime.UtcNow.AddDays(days);
        return await _dbSet
            .Where(r => r.PersonId == personId &&
                        r.DateTime >= DateTime.UtcNow &&
                        r.DateTime <= endDate &&
                        r.IsActive)
            .OrderBy(r => r.DateTime)
            .ToListAsync();
    }
}
```

```csharp
// DataAccess/Repositories/VaccineRepository.cs
public class VaccineRepository : GenericRepository<Vaccine>
{
    public VaccineRepository(AppDbContext context) : base(context) { }

    public async Task<List<Vaccine>> GetByChildIdAsync(Guid childId)
    {
        return await _dbSet
            .Where(v => v.ChildId == childId)
            .OrderBy(v => v.Date)
            .ToListAsync();
    }

    public async Task<List<Vaccine>> GetUpcomingAsync(List<Guid> childIds)
    {
        return await _dbSet
            .Where(v => childIds.Contains(v.ChildId!.Value) &&
                        v.Status == VaccineStatus.Pending &&
                        v.Date >= DateTime.UtcNow)
            .OrderBy(v => v.Date)
            .ToListAsync();
    }

    public async Task<List<Vaccine>> GetOverdueAsync(List<Guid> childIds)
    {
        return await _dbSet
            .Where(v => childIds.Contains(v.ChildId!.Value) &&
                        v.Status == VaccineStatus.Pending &&
                        v.Date < DateTime.UtcNow)
            .OrderBy(v => v.Date)
            .ToListAsync();
    }
}
```

---

## 7. Service Katmanı

> Service'ler `SaglikPusulasi.Business/Services/` klasöründe bulunur.
> Doğrudan Repository sınıflarını kullanırlar (interface yok — basitlik için).
> Tüm metotlar `Result<T>` döner.

### 7.1 AuthService

```csharp
// Business/Services/AuthService.cs
public class AuthService
{
    private readonly UserRepository _userRepository;
    private readonly GenericRepository<RefreshToken> _refreshTokenRepository;
    private readonly TokenService _tokenService;

    public AuthService(
        UserRepository userRepository,
        GenericRepository<RefreshToken> refreshTokenRepository,
        TokenService tokenService)
    {
        _userRepository = userRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _tokenService = tokenService;
    }

    public async Task<Result<AuthResponseDto>> LoginAsync(LoginRequestDto request) { /* ... */ }
    public async Task<Result<AuthResponseDto>> RegisterAsync(RegisterRequestDto request) { /* ... */ }
    public async Task<Result<bool>> ForgotPasswordAsync(ForgotPasswordRequestDto request) { /* ... */ }
    public async Task<Result<bool>> ChangePasswordAsync(Guid userId, ChangePasswordRequestDto request) { /* ... */ }
    public async Task<Result<AuthResponseDto>> RefreshTokenAsync(RefreshTokenRequestDto request) { /* ... */ }
    public async Task<Result<bool>> LogoutAsync(Guid userId, string refreshToken) { /* ... */ }
}
```

### 7.2 UserService

```csharp
// Business/Services/UserService.cs
public class UserService
{
    private readonly UserRepository _userRepository;
    private readonly IMapper _mapper;

    public UserService(UserRepository userRepository, IMapper mapper)
    {
        _userRepository = userRepository;
        _mapper = mapper;
    }

    public async Task<Result<UserDto>> GetByIdAsync(Guid id) { /* ... */ }
    public async Task<Result<UserDto>> UpdateAsync(Guid id, UpdateUserDto dto) { /* ... */ }
    public async Task<Result<bool>> DeleteAccountAsync(Guid id) { /* ... */ }
}
```

### 7.3 PersonService

```csharp
// Business/Services/PersonService.cs
public class PersonService
{
    private readonly PersonRepository _personRepository;
    private readonly IMapper _mapper;

    public PersonService(PersonRepository personRepository, IMapper mapper)
    {
        _personRepository = personRepository;
        _mapper = mapper;
    }

    public async Task<Result<PersonDto>> GetCurrentPersonAsync(Guid userId) { /* ... */ }
    public async Task<Result<PersonDto>> CreateProfileAsync(Guid userId, CreatePersonDto dto) { /* ... */ }
    public async Task<Result<PersonDto>> UpdateAsync(Guid personId, UpdatePersonDto dto) { /* ... */ }
    public async Task<Result<List<PersonDto>>> GetFamilyMembersAsync(Guid userId) { /* ... */ }
    public async Task<Result<PersonDto>> AddFamilyMemberAsync(Guid userId, CreatePersonDto dto) { /* ... */ }
    public async Task<Result<bool>> DeleteFamilyMemberAsync(Guid userId, Guid personId) { /* ... */ }
}
```

### 7.4 ChildService

```csharp
// Business/Services/ChildService.cs
public class ChildService
{
    private readonly ChildRepository _childRepository;
    private readonly VaccineScheduleGenerator _scheduleGenerator;
    private readonly IMapper _mapper;

    public ChildService(
        ChildRepository childRepository,
        VaccineScheduleGenerator scheduleGenerator,
        IMapper mapper)
    {
        _childRepository = childRepository;
        _scheduleGenerator = scheduleGenerator;
        _mapper = mapper;
    }

    public async Task<Result<List<ChildDto>>> GetAllAsync(Guid userId) { /* ... */ }
    public async Task<Result<ChildDto>> GetByIdAsync(Guid userId, Guid childId) { /* ... */ }
    public async Task<Result<ChildDto>> CreateAsync(Guid userId, CreateChildDto dto) { /* ... */ }
    public async Task<Result<ChildDto>> UpdateAsync(Guid userId, Guid childId, UpdateChildDto dto) { /* ... */ }
    public async Task<Result<bool>> DeleteAsync(Guid userId, Guid childId) { /* ... */ }
    public async Task<Result<ChildDto>> UpdateVaccineStatusAsync(Guid userId, Guid childId, Guid scheduleId, Guid vaccineId, UpdateVaccineStatusDto dto) { /* ... */ }
    public async Task<Result<ChildDto>> AddManualVaccineAsync(Guid userId, Guid childId, Guid scheduleId, CreateVaccineDto dto) { /* ... */ }
    public async Task<Result<ChildDto>> DeleteVaccineAsync(Guid userId, Guid childId, Guid scheduleId, Guid vaccineId) { /* ... */ }
}
```

### 7.5 MedicineService

```csharp
// Business/Services/MedicineService.cs
public class MedicineService
{
    private readonly MedicineRepository _medicineRepository;
    private readonly IMapper _mapper;

    public MedicineService(MedicineRepository medicineRepository, IMapper mapper)
    {
        _medicineRepository = medicineRepository;
        _mapper = mapper;
    }

    public async Task<Result<List<MedicineDto>>> GetAllAsync(Guid userId) { /* ... */ }
    public async Task<Result<List<MedicineDto>>> GetByPersonIdAsync(Guid personId) { /* ... */ }
    public async Task<Result<MedicineDto>> GetByIdAsync(Guid id) { /* ... */ }
    public async Task<Result<MedicineDto>> CreateAsync(Guid userId, CreateMedicineDto dto) { /* ... */ }
    public async Task<Result<MedicineDto>> UpdateAsync(Guid id, UpdateMedicineDto dto) { /* ... */ }
    public async Task<Result<bool>> DeleteAsync(Guid id) { /* ... */ }
}
```

### 7.6 ReminderService

```csharp
// Business/Services/ReminderService.cs
public class ReminderService
{
    private readonly ReminderRepository _reminderRepository;
    private readonly IMapper _mapper;

    public ReminderService(ReminderRepository reminderRepository, IMapper mapper)
    {
        _reminderRepository = reminderRepository;
        _mapper = mapper;
    }

    public async Task<Result<List<ReminderDto>>> GetAllAsync(Guid userId) { /* ... */ }
    public async Task<Result<List<ReminderDto>>> GetByDateAsync(Guid userId, DateTime date) { /* ... */ }
    public async Task<Result<ReminderDto>> GetByIdAsync(Guid id) { /* ... */ }
    public async Task<Result<ReminderDto>> CreateAsync(Guid userId, CreateReminderDto dto) { /* ... */ }
    public async Task<Result<ReminderDto>> UpdateAsync(Guid id, UpdateReminderDto dto) { /* ... */ }
    public async Task<Result<bool>> DeleteAsync(Guid id) { /* ... */ }
    public async Task<Result<ReminderDto>> ToggleCompleteAsync(Guid id) { /* ... */ }
}
```

### 7.7 VaccineService

```csharp
// Business/Services/VaccineService.cs
public class VaccineService
{
    private readonly VaccineRepository _vaccineRepository;
    private readonly ChildRepository _childRepository;
    private readonly IMapper _mapper;

    public VaccineService(
        VaccineRepository vaccineRepository,
        ChildRepository childRepository,
        IMapper mapper)
    {
        _vaccineRepository = vaccineRepository;
        _childRepository = childRepository;
        _mapper = mapper;
    }

    public async Task<Result<List<VaccineDto>>> GetByChildIdAsync(Guid childId) { /* ... */ }
    public async Task<Result<List<VaccineDto>>> GetUpcomingVaccinesAsync(Guid userId) { /* ... */ }
    public async Task<Result<List<VaccineDto>>> GetOverdueVaccinesAsync(Guid userId) { /* ... */ }
}
```

### 7.8 Diğer Service'ler

```csharp
// Business/Services/BlogService.cs
public class BlogService
{
    private readonly GenericRepository<BlogArticle> _blogRepository;
    private readonly IMapper _mapper;

    public BlogService(GenericRepository<BlogArticle> blogRepository, IMapper mapper)
    {
        _blogRepository = blogRepository;
        _mapper = mapper;
    }

    public async Task<Result<List<BlogArticleDto>>> GetAllAsync(string? category = null) { /* ... */ }
    public async Task<Result<List<BlogArticleDto>>> GetFeaturedAsync() { /* ... */ }
    public async Task<Result<BlogArticleDto>> GetByIdAsync(Guid id) { /* ... */ }
    public async Task<Result<List<BlogArticleDto>>> SearchAsync(string query) { /* ... */ }
}

// Business/Services/HealthFacilityService.cs
public class HealthFacilityService
{
    private readonly GenericRepository<HealthFacility> _facilityRepository;
    private readonly IMapper _mapper;

    public HealthFacilityService(GenericRepository<HealthFacility> facilityRepository, IMapper mapper)
    {
        _facilityRepository = facilityRepository;
        _mapper = mapper;
    }

    public async Task<Result<List<HealthFacilityDto>>> GetNearbyAsync(double lat, double lng, string? type = null, double radiusKm = 10) { /* ... */ }
    public async Task<Result<List<HealthFacilityDto>>> GetDutyPharmaciesAsync(double lat, double lng) { /* ... */ }
}

// Business/Services/NotificationService.cs
public class NotificationService
{
    private readonly GenericRepository<NotificationSetting> _settingRepository;
    private readonly IMapper _mapper;

    public NotificationService(GenericRepository<NotificationSetting> settingRepository, IMapper mapper)
    {
        _settingRepository = settingRepository;
        _mapper = mapper;
    }

    public async Task<Result<NotificationSettingDto>> GetSettingsAsync(Guid userId) { /* ... */ }
    public async Task<Result<NotificationSettingDto>> UpdateSettingsAsync(Guid userId, NotificationSettingDto dto) { /* ... */ }
}
```

### 7.9 TokenService

```csharp
// Business/Services/TokenService.cs
public class TokenService
{
    private readonly JwtSettings _settings;

    public TokenService(IOptions<JwtSettings> settings)
    {
        _settings = settings.Value;
    }

    public string GenerateAccessToken(User user)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, $"{user.Name} {user.Surname}"),
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_settings.AccessTokenExpirationMinutes),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public RefreshToken GenerateRefreshToken()
    {
        return new RefreshToken
        {
            Token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)),
            ExpiresAt = DateTime.UtcNow.AddDays(_settings.RefreshTokenExpirationDays)
        };
    }
}

// JwtSettings model (appsettings.json ile eşleşir)
public class JwtSettings
{
    public string Secret { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int AccessTokenExpirationMinutes { get; set; }
    public int RefreshTokenExpirationDays { get; set; }
}
```

### 7.10 VaccineScheduleGenerator (İş Mantığı)

```csharp
// Business/Services/VaccineScheduleGenerator.cs
// T.C. Sağlık Bakanlığı Çocukluk Çağı Aşı Takvimine göre otomatik takvim oluşturur
public class VaccineScheduleGenerator
{
    // Flutter tarafındaki _generateScheduleForChild metodunun birebir karşılığı
    public List<VaccineSchedule> Generate(Guid childId, DateTime birthDate)
    {
        var template = new[]
        {
            new { Month = 0,  Period = "Doğumda",             Vaccines = new[] { ("Hepatit B", "1. Doz") } },
            new { Month = 1,  Period = "1. Ay Sonu",          Vaccines = new[] { ("Hepatit B", "2. Doz") } },
            new { Month = 2,  Period = "2. Ay Sonu",          Vaccines = new[] { ("BCG (Verem)", "1. Doz"), ("DaBT-İPA-Hib (5'li Karma)", "1. Doz"), ("KPA (Konjuge Pnömokok)", "1. Doz") } },
            new { Month = 4,  Period = "4. Ay Sonu",          Vaccines = new[] { ("DaBT-İPA-Hib (5'li Karma)", "2. Doz"), ("KPA (Konjuge Pnömokok)", "2. Doz") } },
            new { Month = 6,  Period = "6. Ay Sonu",          Vaccines = new[] { ("Hepatit B", "3. Doz"), ("DaBT-İPA-Hib (5'li Karma)", "3. Doz"), ("OPA (Çocuk Felci)", "1. Doz") } },
            new { Month = 12, Period = "12. Ay (1 Yaş)",      Vaccines = new[] { ("KKK (Kızamık-Kızamıkçık-Kabakulak)", "1. Doz"), ("KPA (Konjuge Pnömokok)", "Pekiştirme"), ("Su Çiçeği", "1. Doz") } },
            new { Month = 18, Period = "18. Ay",              Vaccines = new[] { ("DaBT-İPA (4'lü Karma)", "Pekiştirme"), ("OPA (Çocuk Felci)", "2. Doz"), ("Hepatit A", "1. Doz") } },
            new { Month = 24, Period = "24. Ay (2 Yaş)",      Vaccines = new[] { ("Hepatit A", "2. Doz") } },
            new { Month = 48, Period = "48. Ay (4 Yaş)",      Vaccines = new[] { ("DaBT-İPA (4'lü Karma)", "Rapel"), ("KKK (Kızamık-Kızamıkçık-Kabakulak)", "2. Doz") } },
            new { Month = 72, Period = "1. Sınıf (6 Yaş)",   Vaccines = new[] { ("Td (Difteri-Tetanoz)", "Rapel"), ("OPA (Çocuk Felci)", "Rapel") } },
        };

        return template.Select(t =>
        {
            var scheduledDate = birthDate.AddMonths(t.Month);
            return new VaccineSchedule
            {
                Id = Guid.NewGuid(),
                ChildId = childId,
                Period = t.Period,
                MonthIndex = t.Month,
                ScheduledDate = scheduledDate,
                Vaccines = t.Vaccines.Select(v => new Vaccine
                {
                    Id = Guid.NewGuid(),
                    Name = v.Item1,
                    Date = scheduledDate,
                    Dose = v.Item2,
                    Status = VaccineStatus.Pending,
                    ChildId = childId
                }).ToList()
            };
        }).ToList();
    }
}
```

---

## 8. Controller & API Endpoint Tasarımı

> Controller'lar `SaglikPusulasi.API/Controllers/` klasöründe bulunur.
> Her controller, ilgili Service sınıfını constructor injection ile alır.

### 8.1 AuthController

```
POST   /api/auth/login              → Login (email + password → JWT token)
POST   /api/auth/register           → Register (name, surname, email, password)
POST   /api/auth/forgot-password    → Forgot Password (email → reset link)
POST   /api/auth/refresh-token      → Refresh Token (refreshToken → new JWT)
POST   /api/auth/logout             → Logout (invalidate refresh token)
```

```csharp
// API/Controllers/AuthController.cs
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AuthService _authService;

    public AuthController(AuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    [ProducesResponseType(typeof(ApiResponse<AuthResponseDto>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 401)]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        var result = await _authService.LoginAsync(request);
        if (!result.IsSuccess)
            return Unauthorized(ApiResponse<object>.Fail(result.ErrorMessage!));

        return Ok(ApiResponse<AuthResponseDto>.Ok(result.Data!));
    }

    [HttpPost("register")]
    [ProducesResponseType(typeof(ApiResponse<AuthResponseDto>), 201)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto request)
    {
        var result = await _authService.RegisterAsync(request);
        if (!result.IsSuccess)
            return BadRequest(ApiResponse<object>.Fail(result.ErrorMessage!));

        return CreatedAtAction(nameof(Register), ApiResponse<AuthResponseDto>.Ok(result.Data!));
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequestDto request)
    {
        var result = await _authService.ForgotPasswordAsync(request);
        return Ok(ApiResponse<bool>.Ok(true, "Şifre sıfırlama bağlantısı gönderildi"));
    }

    [HttpPost("refresh-token")]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequestDto request)
    {
        var result = await _authService.RefreshTokenAsync(request);
        if (!result.IsSuccess)
            return Unauthorized(ApiResponse<object>.Fail(result.ErrorMessage!));

        return Ok(ApiResponse<AuthResponseDto>.Ok(result.Data!));
    }

    [HttpPost("logout")]
    [Authorize]
    public async Task<IActionResult> Logout([FromBody] RefreshTokenRequestDto request)
    {
        var userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await _authService.LogoutAsync(userId, request.RefreshToken);
        return Ok(ApiResponse<bool>.Ok(true, "Çıkış yapıldı"));
    }
}
```

### 8.2 UsersController

```
GET    /api/users/profile            → Get Current User Profile
PUT    /api/users/profile            → Update User Profile
PUT    /api/users/change-password    → Change Password
DELETE /api/users/account            → Delete User Account (Soft Delete)
```

```csharp
// API/Controllers/UsersController.cs
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly UserService _userService;
    private readonly AuthService _authService;

    public UsersController(UserService userService, AuthService authService)
    {
        _userService = userService;
        _authService = authService;
    }

    private Guid GetUserId() => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var result = await _userService.GetByIdAsync(GetUserId());
        if (!result.IsSuccess) return NotFound(ApiResponse<object>.Fail(result.ErrorMessage!));
        return Ok(ApiResponse<UserDto>.Ok(result.Data!));
    }

    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateUserDto dto)
    {
        var result = await _userService.UpdateAsync(GetUserId(), dto);
        if (!result.IsSuccess) return BadRequest(ApiResponse<object>.Fail(result.ErrorMessage!));
        return Ok(ApiResponse<UserDto>.Ok(result.Data!));
    }

    [HttpPut("change-password")]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequestDto dto)
    {
        var result = await _authService.ChangePasswordAsync(GetUserId(), dto);
        if (!result.IsSuccess) return BadRequest(ApiResponse<object>.Fail(result.ErrorMessage!));
        return Ok(ApiResponse<bool>.Ok(true, "Şifre başarıyla değiştirildi"));
    }

    [HttpDelete("account")]
    public async Task<IActionResult> DeleteAccount()
    {
        var result = await _userService.DeleteAccountAsync(GetUserId());
        if (!result.IsSuccess) return BadRequest(ApiResponse<object>.Fail(result.ErrorMessage!));
        return Ok(ApiResponse<bool>.Ok(true, "Hesap silindi"));
    }
}
```

### 8.3 PersonsController

```
GET    /api/persons/me                → Get Current Person (Self Profile)
POST   /api/persons/profile           → Create Initial Profile (Profile Entrance)
PUT    /api/persons/{id}              → Update Person Profile
GET    /api/persons/family             → Get Family Members
POST   /api/persons/family             → Add Family Member
DELETE /api/persons/family/{id}        → Delete Family Member

POST   /api/persons/{personId}/illnesses    → Add Illness
DELETE /api/persons/{personId}/illnesses/{id} → Delete Illness

POST   /api/persons/{personId}/allergies    → Add Allergy
DELETE /api/persons/{personId}/allergies/{id} → Delete Allergy
```

### 8.4 ChildrenController

```
GET    /api/children                  → Get All Children
GET    /api/children/{id}             → Get Child By Id (with vaccine schedule)
POST   /api/children                  → Create Child (auto-generates vaccine schedule)
PUT    /api/children/{id}             → Update Child
DELETE /api/children/{id}             → Delete Child

PUT    /api/children/{childId}/schedules/{scheduleId}/vaccines/{vaccineId}/status
       → Update Vaccine Status

POST   /api/children/{childId}/schedules/{scheduleId}/vaccines
       → Add Manual Vaccine to Schedule Period

DELETE /api/children/{childId}/schedules/{scheduleId}/vaccines/{vaccineId}
       → Delete Vaccine from Schedule
```

### 8.5 MedicinesController

```
GET    /api/medicines                 → Get All Medicines (current user)
GET    /api/medicines/{id}            → Get Medicine By Id
GET    /api/medicines/person/{personId} → Get Medicines By Person
POST   /api/medicines                 → Create Medicine
PUT    /api/medicines/{id}            → Update Medicine
DELETE /api/medicines/{id}            → Delete Medicine
```

### 8.6 RemindersController

```
GET    /api/reminders                 → Get All Reminders (current user)
GET    /api/reminders/{id}            → Get Reminder By Id
GET    /api/reminders/date/{date}     → Get Reminders By Date (yyyy-MM-dd)
POST   /api/reminders                 → Create Reminder
PUT    /api/reminders/{id}            → Update Reminder
DELETE /api/reminders/{id}            → Delete Reminder
PUT    /api/reminders/{id}/toggle     → Toggle Active Status
```

### 8.7 VaccinesController

```
GET    /api/vaccines/child/{childId}  → Get Vaccines By Child
GET    /api/vaccines/upcoming         → Get Upcoming Vaccines (all children)
GET    /api/vaccines/overdue          → Get Overdue Vaccines (all children)
```

### 8.8 BlogController

```
GET    /api/blog                      → Get All Articles (?category=Beslenme)
GET    /api/blog/featured             → Get Featured Articles
GET    /api/blog/{id}                 → Get Article By Id
GET    /api/blog/search?q=...         → Search Articles
```

### 8.9 HealthFacilitiesController

```
GET    /api/health-facilities/nearby?lat=...&lng=...&type=pharmacy&radius=10
       → Get Nearby Facilities (filtered by type)

GET    /api/health-facilities/duty-pharmacies?lat=...&lng=...
       → Get Duty Pharmacies
```

### 8.10 NotificationsController

```
GET    /api/notifications/settings    → Get Notification Settings
PUT    /api/notifications/settings    → Update Notification Settings
```

---

## 9. Authentication & Authorization

### 9.1 JWT Yapılandırması

```json
// appsettings.json
{
  "JwtSettings": {
    "Secret": "SUPER_SECRET_KEY_MIN_256_BITS_LONG_ASJHDALSJKDHASKJDHSAD",
    "Issuer": "SaglikPusulasi.API",
    "Audience": "SaglikPusulasi.Flutter",
    "AccessTokenExpirationMinutes": 60,
    "RefreshTokenExpirationDays": 7
  },
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=SaglikPusulasi;Trusted_Connection=true;TrustServerCertificate=true;"
  }
}
```

### 9.2 Auth Akışı

```
┌──────────┐                          ┌──────────┐
│  Flutter  │                          │  Backend  │
│   App     │                          │   API     │
└─────┬─────┘                          └─────┬─────┘
      │  POST /api/auth/login                │
      │  { email, password }                 │
      │─────────────────────────────────────>│
      │                                      │ 1. Email/Password doğrula (BCrypt)
      │                                      │ 2. Access Token (JWT) oluştur
      │                                      │ 3. Refresh Token oluştur & DB'ye kaydet
      │  { token, refreshToken, user }       │
      │<─────────────────────────────────────│
      │                                      │
      │  GET /api/reminders                  │
      │  Authorization: Bearer <token>       │
      │─────────────────────────────────────>│
      │                                      │ Token doğrula & UserId çıkar
      │  { data: [...] }                     │
      │<─────────────────────────────────────│
      │                                      │
      │  (Token expired — 401 hatası)        │
      │  POST /api/auth/refresh-token        │
      │  { refreshToken }                    │
      │─────────────────────────────────────>│
      │                                      │ Refresh token doğrula
      │                                      │ Eski token'ı revoke et
      │                                      │ Yeni token çifti oluştur
      │  { token, refreshToken, user }       │
      │<─────────────────────────────────────│
```

### 9.3 Program.cs JWT Konfigürasyonu

```csharp
// Program.cs içinde
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>()!;
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings.Issuer,
        ValidAudience = jwtSettings.Audience,
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtSettings.Secret)),
        ClockSkew = TimeSpan.Zero // Süre aşımını tam olarak uygula
    };
});

builder.Services.AddAuthorization();
```

### 9.4 Flutter Tarafı Token Yönetimi

Flutter `ApiClient` sınıfında zaten `Bearer` token header'ı hazır:
```dart
Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
};
```

Sadece `login/register` response'undan gelen token'ın `SharedPreferences`'e kaydedilmesi ve `ApiClient.setAuthToken()` ile setlenmesi gerekecektir.

---

## 10. Validation & Error Handling

### 10.1 FluentValidation Kuralları

```csharp
// Business/Validators/LoginRequestValidator.cs
public class LoginRequestValidator : AbstractValidator<LoginRequestDto>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-posta adresi gereklidir")
            .EmailAddress().WithMessage("Geçerli bir e-posta adresi girin");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Şifre gereklidir")
            .MinimumLength(6).WithMessage("Şifre en az 6 karakter olmalıdır");
    }
}

// Business/Validators/RegisterRequestValidator.cs
public class RegisterRequestValidator : AbstractValidator<RegisterRequestDto>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Ad gereklidir");
        RuleFor(x => x.Surname).NotEmpty().WithMessage("Soyad gereklidir");
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-posta adresi gereklidir")
            .EmailAddress().WithMessage("Geçerli bir e-posta adresi girin");
        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Şifre gereklidir")
            .MinimumLength(6).WithMessage("Şifre en az 6 karakter olmalıdır");
        RuleFor(x => x.ConfirmPassword)
            .Equal(x => x.Password).WithMessage("Şifreler eşleşmiyor");
    }
}

// Business/Validators/ChangePasswordValidator.cs
public class ChangePasswordValidator : AbstractValidator<ChangePasswordRequestDto>
{
    public ChangePasswordValidator()
    {
        RuleFor(x => x.CurrentPassword)
            .NotEmpty().WithMessage("Mevcut şifre gereklidir");
        RuleFor(x => x.NewPassword)
            .NotEmpty().WithMessage("Yeni şifre gereklidir")
            .MinimumLength(8).WithMessage("Şifre en az 8 karakter olmalıdır")
            .Matches("[A-Z]").WithMessage("En az bir büyük harf gereklidir")
            .Matches("[a-z]").WithMessage("En az bir küçük harf gereklidir")
            .Matches("[0-9]").WithMessage("En az bir rakam gereklidir");
        RuleFor(x => x.ConfirmNewPassword)
            .Equal(x => x.NewPassword).WithMessage("Yeni şifreler eşleşmiyor");
    }
}

// Business/Validators/CreateChildValidator.cs
public class CreateChildValidator : AbstractValidator<CreateChildDto>
{
    public CreateChildValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Çocuğun adı gereklidir")
            .MaximumLength(100);
        RuleFor(x => x.BirthDate)
            .LessThanOrEqualTo(DateTime.UtcNow).WithMessage("Doğum tarihi gelecekte olamaz");
        RuleFor(x => x.Gender)
            .Must(g => g == "male" || g == "female")
            .WithMessage("Cinsiyet 'male' veya 'female' olmalıdır");
    }
}

// Business/Validators/CreateMedicineValidator.cs
public class CreateMedicineValidator : AbstractValidator<CreateMedicineDto>
{
    public CreateMedicineValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("İlaç adı gereklidir")
            .MaximumLength(200);
        RuleFor(x => x.FrequencyType)
            .Must(f => Enum.TryParse<FrequencyType>(f, true, out _))
            .WithMessage("Geçersiz kullanım sıklığı");
        RuleFor(x => x.TimesPerDay)
            .InclusiveBetween(1, 10).WithMessage("Günlük kullanım 1-10 arası olmalıdır");
        RuleFor(x => x.StartDate)
            .NotEmpty().WithMessage("Başlangıç tarihi gereklidir");
    }
}

// Business/Validators/CreateReminderValidator.cs
public class CreateReminderValidator : AbstractValidator<CreateReminderDto>
{
    public CreateReminderValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Başlık gereklidir")
            .MaximumLength(200);
        RuleFor(x => x.Type)
            .Must(t => Enum.TryParse<ReminderType>(t, true, out _))
            .WithMessage("Geçersiz hatırlatma türü");
        RuleFor(x => x.DateTime)
            .NotEmpty().WithMessage("Tarih ve saat gereklidir");
        RuleFor(x => x.RepeatType)
            .Must(r => Enum.TryParse<RepeatType>(r, true, out _))
            .WithMessage("Geçersiz tekrar türü");
    }
}
```

### 10.2 Global Exception Handling Middleware

```csharp
// API/Middleware/ExceptionHandlingMiddleware.cs
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Beklenmeyen hata: {Message}", ex.Message);
            await HandleExceptionAsync(context, ex);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var (statusCode, response) = exception switch
        {
            ValidationException validationEx => (
                StatusCodes.Status400BadRequest,
                ApiResponse<object>.Fail("Doğrulama hatası",
                    validationEx.Errors.Select(e => e.ErrorMessage).ToList())
            ),
            UnauthorizedAccessException => (
                StatusCodes.Status401Unauthorized,
                ApiResponse<object>.Fail("Yetkisiz erişim")
            ),
            KeyNotFoundException => (
                StatusCodes.Status404NotFound,
                ApiResponse<object>.Fail("Kayıt bulunamadı")
            ),
            InvalidOperationException invalidOpEx => (
                StatusCodes.Status400BadRequest,
                ApiResponse<object>.Fail(invalidOpEx.Message)
            ),
            _ => (
                StatusCodes.Status500InternalServerError,
                ApiResponse<object>.Fail("Sunucu hatası oluştu")
            )
        };

        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(response);
    }
}
```

### 10.3 Hata Yanıt Formatı

Tüm API yanıtları aynı formatta döner — Flutter `ApiResponse` sınıfıyla uyumludur:

```json
// Başarılı yanıt
{
  "success": true,
  "data": { ... },
  "message": null,
  "errors": null
}

// Hata yanıtı
{
  "success": false,
  "data": null,
  "message": "Doğrulama hatası",
  "errors": [
    "E-posta adresi gereklidir",
    "Şifre en az 6 karakter olmalıdır"
  ]
}
```

---

## 11. Dependency Injection Yapısı

> 3 katmanlı mimaride DI yapısı çok basittir. Tüm kayıtlar doğrudan `Program.cs` içinde yapılır.

```csharp
// Program.cs — Tüm DI Yapılandırması

var builder = WebApplication.CreateBuilder(args);

// ────────────────────────────────────────────────────
// 1. DATABASE (DataAccess katmanı)
// ────────────────────────────────────────────────────
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// ────────────────────────────────────────────────────
// 2. REPOSITORIES (DataAccess katmanı)
// ────────────────────────────────────────────────────
builder.Services.AddScoped(typeof(GenericRepository<>));
builder.Services.AddScoped<UserRepository>();
builder.Services.AddScoped<PersonRepository>();
builder.Services.AddScoped<ChildRepository>();
builder.Services.AddScoped<MedicineRepository>();
builder.Services.AddScoped<VaccineRepository>();
builder.Services.AddScoped<ReminderRepository>();

// ────────────────────────────────────────────────────
// 3. SERVICES (Business katmanı)
// ────────────────────────────────────────────────────
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<PersonService>();
builder.Services.AddScoped<ChildService>();
builder.Services.AddScoped<MedicineService>();
builder.Services.AddScoped<VaccineService>();
builder.Services.AddScoped<ReminderService>();
builder.Services.AddScoped<BlogService>();
builder.Services.AddScoped<HealthFacilityService>();
builder.Services.AddScoped<NotificationService>();
builder.Services.AddScoped<TokenService>();
builder.Services.AddSingleton<VaccineScheduleGenerator>();

// ────────────────────────────────────────────────────
// 4. AUTOMAPPER
// ────────────────────────────────────────────────────
builder.Services.AddAutoMapper(typeof(MappingProfile).Assembly);

// ────────────────────────────────────────────────────
// 5. FLUENTVALIDATION
// ────────────────────────────────────────────────────
builder.Services.AddValidatorsFromAssemblyContaining<LoginRequestValidator>();

// ────────────────────────────────────────────────────
// 6. JWT AUTHENTICATION
// ────────────────────────────────────────────────────
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>()!;
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings.Issuer,
            ValidAudience = jwtSettings.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSettings.Secret)),
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();

// ────────────────────────────────────────────────────
// 7. API (Controllers + Swagger + CORS + JSON)
// ────────────────────────────────────────────────────
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter(JsonNamingPolicy.CamelCase));
        options.JsonSerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Sağlık Pusulası API",
        Version = "v1",
        Description = "Sağlık Pusulası mobil uygulaması için RESTful API"
    });

    // JWT Auth için Swagger desteği
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header. Örnek: 'Bearer {token}'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// CORS (Flutter için)
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterApp", policy =>
    {
        policy.AllowAnyOrigin()      // Geliştirme aşamasında
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddHttpContextAccessor();

// ════════════════════════════════════════════════════
// MIDDLEWARE PIPELINE
// ════════════════════════════════════════════════════
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseCors("FlutterApp");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## 12. NuGet Paket Önerileri

### SaglikPusulasi.DataAccess

| Paket | Versiyon | Kullanım |
|-------|----------|----------|
| **Microsoft.EntityFrameworkCore** | 8.x | ORM — veritabanı işlemleri |
| **Microsoft.EntityFrameworkCore.SqlServer** | 8.x | SQL Server provider |
| **Microsoft.EntityFrameworkCore.Tools** | 8.x | Migration araçları |

### SaglikPusulasi.Business

| Paket | Versiyon | Kullanım |
|-------|----------|----------|
| **AutoMapper.Extensions.Microsoft.DependencyInjection** | 12.x | DTO ↔ Entity dönüşümleri |
| **FluentValidation.AspNetCore** | 11.x | Request validation |
| **BCrypt.Net-Next** | 4.x | Şifre hash'leme |
| **System.IdentityModel.Tokens.Jwt** | 7.x | JWT oluşturma |

### SaglikPusulasi.API

| Paket | Versiyon | Kullanım |
|-------|----------|----------|
| **Microsoft.AspNetCore.Authentication.JwtBearer** | 8.x | JWT token doğrulama |
| **Swashbuckle.AspNetCore** | 6.x | Swagger / OpenAPI dokümantasyonu |
| **Serilog.AspNetCore** | 8.x | Structured logging |
| **Serilog.Sinks.Console** | 5.x | Console log sink |
| **Serilog.Sinks.File** | 5.x | File log sink |

### Opsiyonel Paketler

| Paket | Kullanım |
|-------|----------|
| **Npgsql.EntityFrameworkCore.PostgreSQL** | PostgreSQL kullanılacaksa (SqlServer yerine) |
| **MailKit** | E-posta gönderimi (şifre sıfırlama) |
| **Microsoft.Extensions.Caching.Memory** | In-memory cache |

---

## 13. MVVM Uyumlu Veri Akışı

Flutter uygulaması **Provider + ChangeNotifier** tabanlı MVVM mimarisine sahiptir. Backend API tasarımı bu yapıya uyumlu olarak şekillendirilmiştir:

```
┌────────────────────────────────────────────────────────────────────┐
│                        Flutter (Frontend)                         │
│                                                                   │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────┐            │
│  │   View    │◄──│  ViewModel   │◄──│  Repository   │            │
│  │ (Widget)  │   │ (ChangeNot.) │   │ (Data Layer)  │            │
│  └──────────┘    └──────────────┘    └──────┬───────┘            │
│       │UI Events      │State              │  API calls           │
│       ▼               ▼                   ▼                      │
│  User taps      notifyListeners()    ApiClient                   │
│  "Kaydet"       → rebuild UI         .post('/api/medicines',     │
│                                        body: dto.toJson(),       │
│                                        headers: Bearer token)    │
└───────────────────────────────────────────┬──────────────────────┘
                                            │ HTTP Request
                                            ▼
┌────────────────────────────────────────────────────────────────────┐
│                     ASP.NET Core (Backend)                        │
│                                                                   │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐        │
│  │  Controller   │──>│   Service     │──>│  Repository   │        │
│  │ (API Katmanı) │   │ (Business K.) │   │(DataAccess K.)│        │
│  └──────────────┘    └──────────────┘    └──────┬───────┘        │
│       │                    │                     │                │
│   DTO validation     İş mantığı            EF Core               │
│   JWT doğrulama      DTO ↔ Entity          DbContext             │
│   HTTP response      Result<T>             SQL sorguları         │
│                                                                   │
└────────────────────────────────────────────────────────────────────┘
```

### Veri Akış Örneği: İlaç Ekleme

```
1. [Flutter View] Kullanıcı "İlacı Kaydet" butonuna basar
2. [Flutter ViewModel] addMedicineVM.saveMedicine() çağrılır
3. [Flutter Repository] medicineRepository.create(medicine) → apiClient.post()
4. [HTTP] POST /api/medicines + Bearer token + JSON body
5. [ASP.NET Controller] MedicinesController.Create(CreateMedicineDto)
      ↓ FluentValidation ile DTO doğrulanır
      ↓ JWT token'dan UserId alınır
6. [ASP.NET Service] MedicineService.CreateAsync(userId, dto)
      ↓ DTO → Entity dönüşümü (AutoMapper)
      ↓ PersonId doğrulama (kullanıcıya ait mi?)
      ↓ Entity veritabanına eklenir
      ↓ Entity → DTO dönüşümü (AutoMapper)
7. [HTTP Response] 201 Created + MedicineDto (JSON)
8. [Flutter Repository] JSON → Medicine.fromJson()
9. [Flutter ViewModel] status = saved, notifyListeners()
10. [Flutter View] Widget rebuild → başarı mesajı gösterilir
```

### JSON Sözleşmesi

Backend JSON serialization ayarları Flutter modelleriyle tam uyumludur:

```csharp
// Program.cs içinde zaten ayarlandı:
options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
```

Bu ayar, Flutter'daki `fromJson`/`toJson` metotlarındaki `camelCase` JSON key'leriyle (`id`, `userId`, `birthDate`, `frequencyType`) tam uyum sağlar.

---

## 14. Ekran-Endpoint Eşleme Matrisi

| Flutter Ekranı | Backend Endpoint(ler) | HTTP | Açıklama |
|---|---|---|---|
| **SplashScreen** | — | — | Sadece SharedPreferences okur, API çağrısı yok |
| **OnboardingScreen** | — | — | Sadece SharedPreferences yazar, API çağrısı yok |
| **LoginView** | `/api/auth/login` | POST | Email + password → JWT token |
| **LoginView** (Şifremi Unuttum) | `/api/auth/forgot-password` | POST | Password reset email |
| **RegisterView** | `/api/auth/register` | POST | Yeni kullanıcı kaydı |
| **ProfileEntranceScreen** | `/api/persons/profile` | POST | İlk profil oluşturma (cinsiyet, boy, kilo, hastalıklar, alerjiler) |
| **HomeScreen** | `/api/reminders` | GET | Tüm hatırlatmalar (bugünün filtrelenmesi client-side) |
| **HomeScreen** | `/api/persons/me` | GET | Karşılama için kullanıcı adı |
| **HomeScreen** | `/api/reminders/{id}/toggle` | PUT | Hatırlatma tamamlama |
| **HomeScreen** | `/api/reminders/{id}` | DELETE | Hatırlatma silme |
| **CalendarScreen** | `/api/reminders` | GET | Tüm etkinlikler (map'e dönüştürülür) |
| **CalendarScreen** | `/api/reminders` | POST | Yeni etkinlik ekleme |
| **CalendarScreen** | `/api/reminders/{id}/toggle` | PUT | Etkinlik tamamlama |
| **CalendarScreen** | `/api/reminders/{id}` | DELETE | Etkinlik silme |
| **BlogScreen** | `/api/blog` | GET | Makaleler (?category=...) |
| **BlogScreen** | `/api/blog/featured` | GET | Öne çıkan makaleler |
| **BlogScreen** | `/api/blog/search?q=...` | GET | Makale arama |
| **NearbyFacilitiesScreen** | `/api/health-facilities/nearby` | GET | Yakındaki tesisler (?type=pharmacy) |
| **NearbyFacilitiesScreen** | `/api/health-facilities/duty-pharmacies` | GET | Nöbetçi eczaneler |
| **ProfileView** | `/api/users/profile` | GET | Kullanıcı bilgileri |
| **ProfileView** | `/api/persons/me` | GET | Kişi profili |
| **ProfileView** (Logout) | `/api/auth/logout` | POST | Token invalidation |
| **EditProfileScreen** | `/api/users/profile` | PUT | Ad, soyad, email güncelleme |
| **ChangePasswordScreen** | `/api/users/change-password` | PUT | Şifre değiştirme |
| **NotificationSettingsScreen** | `/api/notifications/settings` | GET/PUT | Bildirim tercihleri |
| **VaccinesScreen** | `/api/children` | GET | Çocuk listesi |
| **VaccinesScreen** | `/api/children` | POST | Çocuk ekleme (+ otomatik aşı takvimi) |
| **VaccinesScreen** | `/api/children/{id}` | PUT | Çocuk güncelleme |
| **VaccinesScreen** | `/api/children/{id}` | DELETE | Çocuk silme |
| **VaccinesScreen** | `.../vaccines/{id}/status` | PUT | Aşı durumu güncelleme |
| **VaccinesScreen** | `.../vaccines` | POST | Manuel aşı ekleme |
| **VaccinesScreen** | `.../vaccines/{id}` | DELETE | Aşı silme |
| **AddReminderScreen** | `/api/reminders` | POST | Hatırlatma oluşturma |
| **ReminderListScreen** | `/api/reminders` | GET | Tüm hatırlatmalar |
| **ReminderListScreen** | `/api/reminders/{id}` | PUT/DELETE | Güncelleme/silme |
| **ReminderListScreen** | `/api/reminders/{id}/toggle` | PUT | Tamamlama toggle |
| **AddMedicineScreen** | `/api/medicines` | POST | Hızlı ilaç ekleme |
| **MedicineListScreen** | `/api/medicines` | GET | İlaç listesi |
| **MedicineListScreen** | `/api/medicines/{id}` | DELETE | İlaç silme |
| **MedicineRecordView** | `/api/medicines` | POST | Detaylı ilaç kaydı |
| **AboutScreen** | — | — | Statik, API çağrısı yok |
| **PrivacyPolicyScreen** | — | — | Statik, API çağrısı yok |
| **TermsOfServiceScreen** | — | — | Statik, API çağrısı yok |

---

## 15. Ek Notlar & İleriye Dönük Öneriler

### 15.1 Geliştirme Öncelikleri (Sprint Planı)

| Sprint | Odak | Endpoint Grubu |
|--------|-------|----------------|
| **Sprint 1** | Auth + Core | Auth, Users, Persons — Login/Register/Profile akışı |
| **Sprint 2** | Sağlık Verileri | Medicines, Reminders — İlaç ve hatırlatma yönetimi |
| **Sprint 3** | Çocuk/Aşı | Children, Vaccines — Aşı takvimi ve takibi |
| **Sprint 4** | İçerik + Harita | Blog, HealthFacilities — Statik içerik ve konum servisleri |
| **Sprint 5** | Bildirimler + Polish | Notifications, push notification, hata iyileştirmeleri |

### 15.2 İleriye Dönük Geliştirmeler

| Özellik | Açıklama |
|---------|----------|
| **Push Notification** | Firebase Cloud Messaging (FCM) entegrasyonu — hatırlatma saatlerinde bildirim gönderimi |
| **AI Asistan** | GPT/LLM tabanlı sağlık danışmanı (MainScreen'deki "Asistan" tab'ı için) |
| **Google Maps API** | Gerçek konum bazlı hastane/eczane sorgusu |
| **Nöbetçi Eczane API** | T.C. Sağlık Bakanlığı veya 3. parti nöbetçi eczane API entegrasyonu |
| **Dosya Upload** | Profil fotoğrafı, sağlık raporu yükleme (Azure Blob / AWS S3) |
| **Rate Limiting** | API isteklerini sınırlandırma (AspNetCoreRateLimit) |
| **Health Check** | `/health` endpoint'i ile servis durumu kontrolü |
| **API Versioning** | `/api/v1/...`, `/api/v2/...` desteği |
| **Caching** | Sık erişilen verilere Redis/Memory cache |
| **Background Jobs** | Hangfire ile periyodik görevler (aşı gecikme kontrolü, hatırlatma e-postaları) |
| **Audit Log** | Kritik işlemlerin loglanması (ilaç ekleme/silme, profil değişikliği) |

### 15.3 Flutter Tarafında Yapılması Gereken Değişiklikler

Backend hazır olduğunda Flutter tarafında:

1. **`ApiClient.baseUrl`** güncellenmeli (`https://api.example.com` → gerçek URL)
2. **Repository'lerdeki TODO blokları** açılmalı (HTTP istekleri aktif edilmeli)
3. **Mock data blokları** kaldırılmalı
4. **Token yönetimi**: Login/Register sonrası `SharedPreferences`'e token kaydı + `ApiClient.setAuthToken()`
5. **Refresh token mekanizması**: 401 response alındığında otomatik token yenileme (interceptor)
6. **`dio` paketi** eklenmeli (interceptor desteği için `http` yerine tercih edilir)

### 15.4 Güvenlik Kontrol Listesi

- [x] Password hashing (BCrypt)
- [x] JWT ile stateless authentication
- [x] Refresh Token rotation
- [x] Input validation (FluentValidation)
- [x] Global exception handling (hassas hata detayları gizlenir)
- [ ] HTTPS zorunluluğu (production)
- [ ] Rate limiting
- [ ] CORS kısıtlaması (production'da AllowAnyOrigin kaldırılmalı)
- [ ] SQL Injection koruması (EF Core parameterized queries ile otomatik)
- [ ] XSS koruması (API dönen HTML encode)
- [ ] Audit logging

### 15.5 Veritabanı Seçimi

| Seçenek | Avantaj | Dezavantaj |
|---------|---------|------------|
| **SQL Server** | .NET ekosistemiyle en iyi entegrasyon, EF Core tam destek | Lisans maliyeti (Express ücretsiz) |
| **PostgreSQL** | Ücretsiz, açık kaynak, JSON desteği güçlü | .NET'te biraz daha az yaygın |
| **SQLite** | Geliştirme aşaması için ideal, sıfır yapılandırma | Production için uygun değil |

**Öneri:** Geliştirmede SQLite veya SQL Server LocalDB, production'da SQL Server veya PostgreSQL.

### 15.6 Projeyi Oluşturma Komutları

Backend projesini sıfırdan oluşturmak için terminal komutları:

```bash
# 1. Solution oluştur
dotnet new sln -n SaglikPusulasi

# 2. Projeleri oluştur
dotnet new classlib -n SaglikPusulasi.DataAccess -o src/SaglikPusulasi.DataAccess
dotnet new classlib -n SaglikPusulasi.Business -o src/SaglikPusulasi.Business
dotnet new webapi -n SaglikPusulasi.API -o src/SaglikPusulasi.API

# 3. Solution'a ekle
dotnet sln add src/SaglikPusulasi.DataAccess
dotnet sln add src/SaglikPusulasi.Business
dotnet sln add src/SaglikPusulasi.API

# 4. Proje referanslarını ayarla
cd src/SaglikPusulasi.Business
dotnet add reference ../SaglikPusulasi.DataAccess

cd ../SaglikPusulasi.API
dotnet add reference ../SaglikPusulasi.Business

# 5. NuGet paketlerini yükle
# DataAccess
cd ../SaglikPusulasi.DataAccess
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools

# Business
cd ../SaglikPusulasi.Business
dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
dotnet add package FluentValidation.AspNetCore
dotnet add package BCrypt.Net-Next
dotnet add package System.IdentityModel.Tokens.Jwt

# API
cd ../SaglikPusulasi.API
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Swashbuckle.AspNetCore
dotnet add package Serilog.AspNetCore

# 6. İlk migration
cd ../SaglikPusulasi.API
dotnet ef migrations add InitialCreate --project ../SaglikPusulasi.DataAccess
dotnet ef database update
```

---

> **Doküman Versiyonu:** 2.0 (3 Katmanlı Mimari)
> **Oluşturma Tarihi:** 2025
> **Kaynak:** Flutter (Sağlık Pusulası) uygulaması kaynak kodu analizi
> **Hedef:** ASP.NET Core 8.0 Web API — 3 Katmanlı Mimari
