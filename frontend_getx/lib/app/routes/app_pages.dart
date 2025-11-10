// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:lightmedchain/app/bindings/api_binding.dart';
import 'package:lightmedchain/app/bindings/auth_binding.dart';
import '../routes/app_routes.dart';
import '../../modules/auth/login_view.dart';
import '../../modules/patient/patient_view.dart';
import '../../modules/doctor/doctor_view.dart';
import '../../modules/admin/admin_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.PATIENT_DASHBOARD,
      page: () => PatientView(),
      binding: ApiBinding(),
    ),
    GetPage(
      name: AppRoutes.DOCTOR_DASHBOARD,
      page: () => DoctorView(),
      binding: ApiBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_DASHBOARD,
      page: () => AdminView(),
      binding: ApiBinding(),
    ),
  ];
}