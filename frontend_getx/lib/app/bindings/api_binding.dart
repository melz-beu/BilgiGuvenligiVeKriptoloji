// lib/app/bindings/api_binding.dart
import 'package:get/get.dart';
import 'package:lightmedchain/modules/patient/patient_controller.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ApiBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => PatientController());
  }
}