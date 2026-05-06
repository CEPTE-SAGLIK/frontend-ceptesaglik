import 'package:flutter/material.dart';
import 'package:health_asistants/presentation/allergy/viewmodel/allergy_viewmodel.dart';
import 'package:health_asistants/presentation/illness/viewmodel/illness_viewmodel.dart';
import 'package:health_asistants/presentation/onboarding/viewmodel/onboarding_viewmodel.dart';
import 'package:health_asistants/presentation/onboarding/viewmodel/profile_entrance_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:health_asistants/core/utils/theme/app_theme.dart';
import 'package:health_asistants/core/utils/navigation/app_routes.dart';
import 'package:health_asistants/core/network/api_client.dart';
import 'package:health_asistants/data/repository/auth_repository.dart';
import 'package:health_asistants/data/repository/person_repository.dart';
import 'package:health_asistants/data/repository/user_repository.dart';
import 'package:health_asistants/data/repository/reminder_repository.dart';
import 'package:health_asistants/data/repository/medicine_repository.dart';
import 'package:health_asistants/data/repository/child_repository.dart';
import 'package:health_asistants/data/repository/vaccine_repository.dart';
import 'package:health_asistants/data/repository/gemini_repository.dart';
import 'package:health_asistants/presentation/auth/login/viewmodel/login_viewmodel.dart';
import 'package:health_asistants/presentation/auth/register/viewmodel/register_viewmodel.dart';
import 'package:health_asistants/presentation/home/viewmodel/home_viewmodel.dart';
import 'package:health_asistants/presentation/medicine/viewmodel/add_medicine_viewmodel.dart';
import 'package:health_asistants/presentation/medicine/viewmodel/medicine_list_viewmodel.dart';
import 'package:health_asistants/presentation/navigator/viewmodel/navigator_viewmodel.dart';
import 'package:health_asistants/presentation/profile/viewmodel/profile_viewmodel.dart';
import 'package:health_asistants/presentation/reminder/viewmodel/add_reminder_viewmodel.dart';
import 'package:health_asistants/presentation/reminder/viewmodel/reminder_list_viewmodel.dart';
import 'package:health_asistants/presentation/record/viewmodel/medicine_record_viewmodel.dart';
import 'package:health_asistants/presentation/calendar/viewmodel/calendar_viewmodel.dart';
import 'package:health_asistants/presentation/profile/viewmodel/vaccines_viewmodel.dart';
import 'package:health_asistants/presentation/profile/viewmodel/family_viewmodel.dart';
import 'package:health_asistants/presentation/profile/viewmodel/my_vaccines_viewmodel.dart';
import 'package:health_asistants/presentation/home/viewmodel/gemini_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  final apiClient = ApiClient();
  final authRepository = AuthRepository(apiClient: apiClient);
  await authRepository.loadSavedTokens();

  runApp(MyApp(apiClient: apiClient, authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Singleton Repository'ler ──
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<PersonRepository>(
          create: (ctx) => PersonRepository(
            apiClient: ctx.read<ApiClient>(),
            authRepository: ctx.read<AuthRepository>(),
          ),
        ),
        Provider<UserRepository>(
          create: (ctx) => UserRepository(
            apiClient: ctx.read<ApiClient>(),
            personRepository: ctx.read<PersonRepository>(),
          ),
        ),
        Provider<ReminderRepository>(
          create: (ctx) => ReminderRepository(apiClient: ctx.read<ApiClient>()),
        ),
        ProxyProvider2<ApiClient, UserRepository, MedicineRepository>(
          create: (ctx) => MedicineRepository(
            apiClient: ctx.read<ApiClient>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (_, __, ___, previous) => previous!,
        ),
        ProxyProvider<UserRepository, ChildRepository>(
          create: (ctx) => ChildRepository(
            apiClient: ctx.read<ApiClient>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (_, __, previous) => previous!,
        ),
        Provider<VaccineRepository>(
          create: (ctx) => VaccineRepository(apiClient: ctx.read<ApiClient>()),
        ),
        Provider<GeminiRepository>(
          create: (ctx) => GeminiRepository(apiClient: ctx.read<ApiClient>()),
        ),

        // ── Auth ViewModels ──
        ChangeNotifierProxyProvider<AuthRepository, LoginViewModel>(
          create: (ctx) =>
              LoginViewModel(authRepository: ctx.read<AuthRepository>()),
          update: (_, __, vm) => vm!,
        ),
        ChangeNotifierProxyProvider<AuthRepository, RegisterViewModel>(
          create: (ctx) =>
              RegisterViewModel(authRepository: ctx.read<AuthRepository>()),
          update: (_, __, vm) => vm!,
        ),
        ChangeNotifierProxyProvider2<ApiClient, UserRepository, IllnessViewModel>(
          create: (ctx) => IllnessViewModel(
            apiClient: ctx.read<ApiClient>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (_, __, ___, vm) => vm!,
        ),
        ChangeNotifierProxyProvider2<ApiClient, UserRepository, AllergyViewModel>(
          create: (ctx) => AllergyViewModel(
            apiClient: ctx.read<ApiClient>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (_, __, ___, vm) => vm!,
        ),
        // ── App ViewModels ──
        ChangeNotifierProvider(create: (_) => NavigatorViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProxyProvider2<
          PersonRepository,
          AuthRepository,
          ProfileEntranceViewModel
        >(
          create: (ctx) => ProfileEntranceViewModel(
            personRepository: ctx.read<PersonRepository>(),
            authRepository: ctx.read<AuthRepository>(),
          ),
          update: (_, __, ___, vm) => vm!,
        ),

        ChangeNotifierProxyProvider4<
          ReminderRepository,
          PersonRepository,
          UserRepository,
          VaccineRepository,
          HomeViewModel
        >(
          create: (ctx) => HomeViewModel(
            reminderRepository: ctx.read<ReminderRepository>(),
            personRepository: ctx.read<PersonRepository>(),
            userRepository: ctx.read<UserRepository>(),
            vaccineRepository: ctx.read<VaccineRepository>(),
          ),
          update: (_, __, ___, ____, _____, vm) => vm!,
        ),

        ChangeNotifierProxyProvider2<ReminderRepository, UserRepository,
            AddReminderViewModel>(
          create: (ctx) => AddReminderViewModel(
            reminderRepository: ctx.read<ReminderRepository>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (_, __, ___, vm) => vm!,
        ),
        ChangeNotifierProxyProvider2<ReminderRepository, UserRepository,
            ReminderListViewModel>(
          create: (ctx) => ReminderListViewModel(
            repository: ctx.read<ReminderRepository>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (_, __, ___, vm) => vm!,
        ),
        ChangeNotifierProxyProvider3<ReminderRepository, UserRepository,
            MedicineRepository, CalendarViewModel>(
          create: (ctx) => CalendarViewModel(
            reminderRepository: ctx.read<ReminderRepository>(),
            medicineRepository: ctx.read<MedicineRepository>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (_, __, ___, ____, vm) => vm!,
        ),

        ChangeNotifierProxyProvider<MedicineRepository, AddMedicineViewModel>(
          create: (ctx) => AddMedicineViewModel(
            medicineRepository: ctx.read<MedicineRepository>(),
          ),
          update: (_, __, vm) => vm!,
        ),
        ChangeNotifierProxyProvider<MedicineRepository, MedicineListViewModel>(
          create: (ctx) =>
              MedicineListViewModel(repository: ctx.read<MedicineRepository>()),
          update: (_, __, vm) => vm!,
        ),
        ChangeNotifierProxyProvider<
          MedicineRepository,
          MedicineRecordViewModel
        >(
          create: (ctx) => MedicineRecordViewModel(
            medicineRepository: ctx.read<MedicineRepository>(),
          ),
          update: (_, __, vm) => vm!,
        ),

        ChangeNotifierProxyProvider2<
          UserRepository,
          PersonRepository,
          ProfileViewModel
        >(
          create: (ctx) => ProfileViewModel(
            userRepository: ctx.read<UserRepository>(),
            personRepository: ctx.read<PersonRepository>(),
          ),
          update: (_, __, ___, vm) => vm!,
        ),
        ChangeNotifierProxyProvider<ChildRepository, VaccinesViewModel>(
          create: (ctx) =>
              VaccinesViewModel(childRepository: ctx.read<ChildRepository>()),
          update: (_, __, vm) => vm!,
        ),
        ChangeNotifierProxyProvider2<UserRepository, VaccineRepository,
            FamilyViewModel>(
          create: (ctx) => FamilyViewModel(
            userRepository: ctx.read<UserRepository>(),
            vaccineRepository: ctx.read<VaccineRepository>(),
          ),
          update: (_, __, ___, vm) => vm!,
        ),
        ChangeNotifierProxyProvider2<VaccineRepository, UserRepository,
            MyVaccinesViewModel>(
          create: (ctx) => MyVaccinesViewModel(
            vaccineRepository: ctx.read<VaccineRepository>(),
            userRepository: ctx.read<UserRepository>(),
          ),
          update: (_, __, ___, vm) => vm!,
        ),
        ChangeNotifierProxyProvider3<
          GeminiRepository,
          MedicineRepository,
          ReminderRepository,
          GeminiViewModel
        >(
          create: (ctx) => GeminiViewModel(
            geminiRepository: ctx.read<GeminiRepository>(),
            medicineRepository: ctx.read<MedicineRepository>(),
            reminderRepository: ctx.read<ReminderRepository>(),
          ),
          update: (_, __, ___, ____, vm) => vm!,
        ),
      ],
      child: MaterialApp(
        title: 'Sağlık Pusulası',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initial,
        routes: AppRoutes.routes,
      ),
    );
  }
}
