// Kimlik doğrulama servisi
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // Geçici kullanıcı veritabanı (gerçek uygulamada backend'den alınır)
  static final Map<String, dynamic> _mockUsers = {
    'patient': {
      'userId': 'patient_001',
      'username': 'hasta',
      'email': 'hasta@test.com',
      'userType': 'patient',
      'fullName': 'Ahmet Yılmaz',
      'createdAt': '2024-01-01T00:00:00Z',
      'isActive': true,
    },
    'doctor': {
      'userId': 'doctor_001',
      'username': 'doktor',
      'email': 'doktor@test.com',
      'userType': 'doctor',
      'fullName': 'Dr. Ayşe Demir',
      'createdAt': '2024-01-01T00:00:00Z',
      'isActive': true,
    },
    'admin': {
      'userId': 'admin_001',
      'username': 'admin',
      'email': 'admin@test.com',
      'userType': 'admin',
      'fullName': 'Sistem Yöneticisi',
      'createdAt': '2024-01-01T00:00:00Z',
      'isActive': true,
    },
  };

  /// Kullanıcı girişi yapar
  Future<User?> login(String username, String password) async {
    // Simüle giriş işlemi - gerçek uygulamada backend API kullanılır
    await Future.delayed(const Duration(seconds: 1));

    // Basit doğrulama
    if (username == 'hasta' && password == '123456') {
      return Patient.fromJson(_mockUsers['patient']);
    } else if (username == 'doktor' && password == '123456') {
      return Doctor.fromJson(_mockUsers['doctor']);
    } else if (username == 'admin' && password == '123456') {
      return Admin.fromJson(_mockUsers['admin']);
    } else {
      throw Exception('Geçersiz kullanıcı adı veya şifre');
    }
  }

  /// Kullanıcı çıkışı yapar
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  /// Oturum açık mı kontrol eder
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  /// Mevcut kullanıcıyı getirir
Future<User?> getCurrentUser() async {
  print("🔍 DEBUG - getCurrentUser called");
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString(_userKey);
  
  print("🔍 DEBUG - User JSON from storage: $userJson");
  
  if (userJson != null) {
    final userData = json.decode(userJson);
    print("🔍 DEBUG - User data: $userData");
    
    switch (userData['userType']) {
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
  
  print("❌ DEBUG - No user found in storage");
  return null;
}

  /// Kullanıcıyı kaydeder
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
}