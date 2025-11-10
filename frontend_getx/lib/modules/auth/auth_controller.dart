// lib/modules/auth/auth_controller.dart
import 'package:get/get.dart';
import 'package:lightmedchain/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.find();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await authService.login(username, password);

      if (user != null) {
        _redirectBasedOnUserType(user.userType);
      } else {
        errorMessage.value = 'Giriş başarısız';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _redirectBasedOnUserType(String userType) {
    switch (userType) {
      case 'patient':
        Get.offAllNamed(AppRoutes.PATIENT_DASHBOARD);
        break;
      case 'doctor':
        Get.offAllNamed(AppRoutes.DOCTOR_DASHBOARD);
        break;
      case 'admin':
        Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
        break;
      default:
        Get.offAllNamed(AppRoutes.PATIENT_DASHBOARD);
    }
  }

  Future<void> logout() async {
      authService.logout(); // ✅ Burada await kullanılabilir çünkü logout Future<void> döndürüyor
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  bool get isLoggedIn => authService.isLoggedIn.value;
  User? get currentUser => authService.currentUser.value;
}