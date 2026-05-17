import 'package:flutter/material.dart';
import 'package:health_asistants/presentation/allergy/view/allergies_screen.dart';
import 'package:health_asistants/presentation/illness/view/illnesses_screen.dart';
import 'package:health_asistants/presentation/onboarding/view/onboarding_screen.dart';
import 'package:health_asistants/presentation/onboarding/view/profile_entrance_screen.dart';
// Sayfa Importları
import 'package:health_asistants/presentation/splash/view/splash_screen.dart';
import 'package:health_asistants/presentation/auth/login/view/login_view.dart';
import 'package:health_asistants/presentation/auth/register/view/register_view.dart';
import 'package:health_asistants/presentation/calendar/view/calendar_screen.dart';
import 'package:health_asistants/presentation/home/view/home_screen.dart';
import 'package:health_asistants/presentation/medicine/view/add_medicine_screen.dart';
import 'package:health_asistants/presentation/medicine/view/medicine_list_screen.dart';
import 'package:health_asistants/presentation/navigator/view/main_screen.dart';

import 'package:health_asistants/presentation/profile/view/profile_view.dart';
import 'package:health_asistants/presentation/profile/view/privacy_policy_screen.dart';
import 'package:health_asistants/presentation/profile/view/terms_of_service_screen.dart';
import 'package:health_asistants/presentation/profile/view/about_screen.dart';
import 'package:health_asistants/presentation/profile/view/change_password_screen.dart';
import 'package:health_asistants/presentation/profile/view/edit_profile_screen.dart';
import 'package:health_asistants/presentation/profile/view/notification_settings_screen.dart';
import 'package:health_asistants/presentation/profile/view/vaccines_screen.dart';
import 'package:health_asistants/presentation/profile/view/my_children_screen.dart';
import 'package:health_asistants/presentation/profile/view/family_members_screen.dart';
import 'package:health_asistants/presentation/profile/view/add_vaccine_screen.dart';
import 'package:health_asistants/presentation/record/view/medicine_view.dart';
import 'package:health_asistants/presentation/reminder/view/add_reminder_screen.dart';
import 'package:health_asistants/presentation/reminder/view/reminder_list_screen.dart';

/// Uygulama route sabitleri ve yönlendirme
class AppRoutes {
  AppRoutes._();

  // Route sabitleri
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const profileEntrance = '/profile-entrance';
  static const main = '/main';
  static const home = '/home';
  static const calendar = '/calendar';
  static const profile = '/profile';
  static const addReminder = '/add-reminder';
  static const addMedicine = '/add-medicine';
  static const medicineRecord = '/medicine-record';
  static const reminders = '/reminders';
  static const medicines = '/medicines';
  // --- BİZİM YENİ EKLENEN SABİTLERİMİZ ---
  static const illnesses = '/illnesses';
  static const allergies = '/allergies';
  // ---------------------------------------
  // Profile routes
  static const editProfile = '/edit-profile';
  static const changePassword = '/change-password';
  static const privacyPolicy = '/privacy-policy';
  static const termsOfService = '/terms-of-service';
  static const about = '/about';
  static const notificationSettings = '/notification-settings';
  static const myVaccines = '/my-vaccines';
  static const myChildren = '/my-children';
  static const familyMembers = '/family-members';
  static const addVaccine = '/add-vaccine';

  // Başlangıç route'u
  static const initial = splash;

  // Route map
  static final routes = <String, WidgetBuilder>{
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginView(),
    register: (_) => const RegisterView(),
    onboarding: (_) => const OnboardingScreen(),
    profileEntrance: (_) => const ProfileEntranceScreen(),
    main: (_) => const MainScreen(),
    home: (_) => const HomeScreen(),
    calendar: (_) => const CalendarScreen(),
    profile: (_) => const ProfileView(),
    addReminder: (_) => const AddReminderScreen(),
    addMedicine: (_) => const AddMedicineScreen(),
    medicineRecord: (_) => const MedicineView(),
    reminders: (_) => const ReminderListScreen(),
    medicines: (_) => const MedicineListScreen(),
    // Profile routes
    editProfile: (_) => const EditProfileScreen(),
    changePassword: (_) => const ChangePasswordScreen(),
    privacyPolicy: (_) => const PrivacyPolicyScreen(),
    termsOfService: (_) => const TermsOfServiceScreen(),
    about: (_) => const AboutScreen(),
    notificationSettings: (_) => const NotificationSettingsScreen(),
    myVaccines: (_) => const MyVaccinesScreen(),
    myChildren: (_) => const MyChildrenScreen(),
    familyMembers: (_) => const FamilyMembersScreen(),
    addVaccine: (_) => const AddVaccineScreen(),
        illnesses: (_) => const IllnessesScreen(),
    allergies: (_) => const AllergiesScreen(),
  };

  // --- DÜZELTİLEN YÖNLENDİRME METODLARI ---

  // void yerine Future<dynamic> yaptık ve return ekledik.
  static Future<dynamic> push(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(context, route, arguments: arguments);
  }

  static Future<dynamic> replace(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(context, route, arguments: arguments);
  }

  static Future<dynamic> clearAndPush(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (_) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }
}
