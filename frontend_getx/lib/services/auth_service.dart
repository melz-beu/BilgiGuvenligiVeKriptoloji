// lib/services/auth_service.dart
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'storage_service.dart';
import 'api_service.dart';
// JSON importunu ekleyelim
import 'dart:convert';

class AuthService extends GetxService {
  final StorageService storageService = Get.find();
  final ApiService apiService = Get.find();

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = storageService.getToken();
    final user = storageService.getCurrentUser();
    
    if (token != null && user != null) {
      currentUser.value = user;
      isLoggedIn.value = true;
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      print('🔐 DEBUG - Login attempt: $username');
      
      final response = await apiService.login(username, password);
      print('🔐 DEBUG - Raw login response: $response');
      
      // Backend response structure'unu kontrol et
      if (response.containsKey('token') && response.containsKey('user')) {
        final token = response['token'];
        final userData = response['user'];
        
        print('🔐 DEBUG - Token: $token');
        print('🔐 DEBUG - User data: $userData');
        
        if (token == null) {
          print('❌ DEBUG - Token is null from backend');
          throw Exception('Backend returned null token');
        }
        
        if (userData == null) {
          print('❌ DEBUG - User data is null from backend');
          throw Exception('Backend returned null user data');
        }
        
        // Save token and user
        storageService.saveToken(token);
        
        // Create user object based on type
       final user = _createUserFromBackendResponse(userData);
       // final user = User.fromJson(userData);
        storageService.saveCurrentUser(user);
        
        currentUser.value = user;
        isLoggedIn.value = true;
        
        print('✅ DEBUG - Login successful: ${user.userType}');
        return user;
      } else {
        print('❌ DEBUG - Invalid response structure from backend');
        print('❌ DEBUG - Expected keys: token, user');
        print('❌ DEBUG - Actual keys: ${response.keys}');
        throw Exception('Invalid response from backend');
      }
    } catch (e) {
      print('❌ DEBUG - Login error: $e');
      rethrow; // Hatayı yukarı fırlat, UI'da göstersin
    }
  }

  User _createUserFromBackendResponse(Map<String, dynamic> userData) {
    print('🔍 DEBUG - Creating user from backend: $userData');
    
    // Backend'in döndürdüğü field isimlerine göre ayarlayalım
    final userType = userData['user_type'] ?? 'patient';
    final userId = userData['user_id'] ?? 'unknown';
    final username = userData['username'] ?? 'unknown';
    final email = userData['email'] ?? 'unknown@email.com';
    final fullName = userData['full_name'] ?? userData['fullName'];
    
    // Boolean conversion
    bool parseBool(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true';
      return true;
    }
    
    final isActive = parseBool(userData['is_active'] ?? userData['isActive']);
    final createdAt = userData['created_at'] ?? userData['createdAt'] ?? DateTime.now().toIso8601String();

    print('🔍 DEBUG - Parsed: type=$userType, id=$userId, username=$username');

    switch (userType) {
      case 'patient':
        return Patient(
          userId: userId,
          username: username,
          email: email,
          fullName: fullName,
          createdAt: createdAt,
          isActive: isActive,
          dateOfBirth: userData['date_of_birth'] ?? userData['dateOfBirth'],
          gender: userData['gender'],
          phone: userData['phone'],
          emergencyContact: userData['emergency_contact'] ?? userData['emergencyContact'],
          medicalConditions: _parseList(userData['medical_conditions'] ?? userData['medicalConditions']),
          assignedDoctors: _parseList(userData['assigned_doctors'] ?? userData['assignedDoctors']),
        );
      
      case 'doctor':
        return Doctor(
          userId: userId,
          username: username,
          email: email,
          fullName: fullName,
          createdAt: createdAt,
          isActive: isActive,
          licenseNumber: userData['license_number'] ?? userData['licenseNumber'] ?? '',
          specialization: userData['specialization'] ?? '',
          hospital: userData['hospital'],
          patients: _parseList(userData['patients']),
        );
      
      case 'admin':
        return Admin(
          userId: userId,
          username: username,
          email: email,
          fullName: fullName,
          createdAt: createdAt,
          isActive: isActive,
          permissions: _parseList(userData['permissions']) ?? ['user_management'],
        );
      
      default:
        print('⚠️ DEBUG - Unknown user type: $userType, creating base User');
        return User(
          userId: userId,
          username: username,
          email: email,
          userType: userType,
          fullName: fullName,
          createdAt: createdAt,
          isActive: isActive,
        );
    }
  }

  List<String>? _parseList(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return null;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await apiService.register(userData);
      return response['message'] != null;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  void logout() {
    storageService.clearAllData();
    currentUser.value = null;
    isLoggedIn.value = false;
  }

  String? getToken() {
    return storageService.getToken();
  }
}

