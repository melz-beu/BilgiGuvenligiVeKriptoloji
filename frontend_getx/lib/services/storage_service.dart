// lib/services/storage_service.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';

class StorageService extends GetxService {
  late GetStorage _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = GetStorage();
  }

  // Token management
  void saveToken(String token) {
    _storage.write('auth_token', token);
  }

  String? getToken() {
    return _storage.read('auth_token');
  }

  void removeToken() {
    _storage.remove('auth_token');
  }

  // User management
  void saveCurrentUser(User user) {
    _storage.write('current_user', user.toJson());
  }

  User? getCurrentUser() {
    final userData = _storage.read('current_user');
    if (userData == null) return null;

    final userType = userData['userType'] ?? 'patient';
    
    switch (userType) {
      case 'patient':
        return Patient.fromJson(userData);
      case 'doctor':
        return Doctor.fromJson(userData);
      case 'admin':
        return Admin.fromJson(userData);
      default:
        return User.fromJson(userData);
    }
  }

  void removeCurrentUser() {
    _storage.remove('current_user');
  }

  // Clear all data - ✅ void döndürüyor, await GEREKMİYOR
  void clearAllData() {
    _storage.erase();
  }
}