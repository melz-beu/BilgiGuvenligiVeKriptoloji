// Kimlik doğrulama servisi
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // TOKEN METODLARI - BU METODLAR OLMALI
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_tokenKey, token);
  
  // Token tipini kontrol et
  if (token.startsWith('eyJ')) {
    print('✅ DEBUG - REAL JWT Token saved: ${token.substring(0, 50)}...');
  } else {
    print('⚠️ DEBUG - DEMO Token saved: $token');
  }
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(_tokenKey);
  
  if (token != null) {
    if (token.startsWith('eyJ')) {
      print('✅ DEBUG - Found REAL JWT token in storage');
    } else {
      print('❌ DEBUG - Found DEMO token in storage: $token');
    }
  } else {
    print('⚠️ DEBUG - No token found in storage');
  }
  
  return token;
}

// AuthService class'ına bu metodu ekleyin
Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_userKey);
  await prefs.remove(_tokenKey);
  print('🗑️ DEBUG - All storage data cleared');
}


  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('🗑️ DEBUG - Token cleared from storage');
  }

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

 Future<User?> login(String username, String password) async {
  print("🌐 DEBUG - Calling REAL backend login: $username");
  
  String? finalToken;
  User? finalUser;

  try {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('http://127.0.0.1:5000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    print("🔍 DEBUG - Login response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final userData = data['user'];
      
      print("✅ DEBUG - Real JWT token received from backend!");
      finalToken = token; // GERÇEK TOKEN'ı sakla
      
      if (token == null) {
        throw Exception('Token alınamadı');
      }

      // USER oluşturmayı dene
      try {
        finalUser = _createUserFromResponse(userData);
        print("✅ DEBUG - User created from backend response");
      } catch (e) {
        print("❌ DEBUG - User creation failed: $e, using mock user");
        finalUser = await _mockLogin(username, password);
      }
      
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  } catch (e) {
    print("❌ DEBUG - Backend login failed: $e");
    // SADECE backend tamamen çöktüğünde fallback kullan
    finalUser = await _mockLogin(username, password);
    finalToken = _generateDemoJWTToken(username);
  }

  // TOKEN ve USER'ı KAYDET (hangisi başarılı olursa)
  if (finalToken != null) {
    await saveToken(finalToken);
    print("✅ DEBUG - Final token saved: ${finalToken.substring(0, 50)}...");
  }
  
  if (finalUser != null) {
    await saveUser(finalUser);
    print("✅ DEBUG - Final user saved: ${finalUser.username}");
  }

  return finalUser;
}

  String _generateDemoJWTToken(String username) {
    // Basit bir JWT-benzeri token oluştur
    final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
    final payload = base64Url.encode(utf8.encode(
        '{"sub":"$username","user_type":"patient","exp":${DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch}}'));
    final signature = base64Url.encode(utf8.encode('demo_signature_$username'));

    return '$header.$payload.$signature';
  }

  User _createUserFromResponse(Map<String, dynamic> userData) {
    final userType = userData['user_type'] ?? userData['userType'] ?? 'patient';

    // Boolean dönüşümü
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    switch (userType) {
      case 'patient':
        return Patient(
          userId: userData['user_id'] ?? userData['userId'] ?? 'patient_001',
          username: userData['username'] ?? 'hasta',
          email: userData['email'] ?? 'hasta@test.com',
          fullName:
              userData['full_name'] ?? userData['fullName'] ?? 'Ahmet Yılmaz',
          createdAt: userData['created_at'] ??
              userData['createdAt'] ??
              DateTime.now().toIso8601String(),
          isActive: parseBool(
              userData['is_active'] ?? userData['isActive']), // ← DÜZELTİLDİ
          dateOfBirth: userData['date_of_birth'] ?? userData['dateOfBirth'],
          gender: userData['gender'],
          phone: userData['phone'],
          emergencyContact:
              userData['emergency_contact'] ?? userData['emergencyContact'],
          medicalConditions: _parseList(
              userData['medical_conditions'] ?? userData['medicalConditions']),
          assignedDoctors: _parseList(
              userData['assigned_doctors'] ?? userData['assignedDoctors']),
        );
      case 'doctor':
        return Doctor(
          userId: userData['user_id'] ?? userData['userId'] ?? 'doctor_001',
          username: userData['username'] ?? 'doktor',
          email: userData['email'] ?? 'doktor@test.com',
          fullName:
              userData['full_name'] ?? userData['fullName'] ?? 'Dr. Ayşe Demir',
          createdAt: userData['created_at'] ??
              userData['createdAt'] ??
              DateTime.now().toIso8601String(),
          isActive: parseBool(
              userData['is_active'] ?? userData['isActive']), // ← DÜZELTİLDİ
          licenseNumber: userData['license_number'] ??
              userData['licenseNumber'] ??
              'DEMO123',
          specialization: userData['specialization'] ?? 'Cardiology',
          hospital: userData['hospital'],
          patients: _parseList(userData['patients']),
        );
      case 'admin':
        return Admin(
          userId: userData['user_id'] ?? userData['userId'] ?? 'admin_001',
          username: userData['username'] ?? 'admin',
          email: userData['email'] ?? 'admin@test.com',
          fullName: userData['full_name'] ??
              userData['fullName'] ??
              'Sistem Yöneticisi',
          createdAt: userData['created_at'] ??
              userData['createdAt'] ??
              DateTime.now().toIso8601String(),
          isActive: parseBool(
              userData['is_active'] ?? userData['isActive']), // ← DÜZELTİLDİ
          permissions: _parseList(userData['permissions']) ?? ['all'],
        );
      default:
        return User(
          userId: userData['user_id'] ?? userData['userId'] ?? 'user_001',
          username: userData['username'] ?? 'user',
          email: userData['email'] ?? 'user@test.com',
          userType: userType,
          fullName: userData['full_name'] ?? userData['fullName'],
          createdAt: userData['created_at'] ??
              userData['createdAt'] ??
              DateTime.now().toIso8601String(),
          isActive: userData['is_active'] ?? userData['isActive'] ?? true,
        );
    }
  }

  List<String>? _parseList(dynamic data) {
    if (data == null) return null;
    if (data is List) return List<String>.from(data);
    if (data is String) {
      try {
        return json.decode(data).cast<String>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Eski mock login'i yardımcı metod olarak taşı
  Future<User?> _mockLogin(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username == 'hasta' && password == '123456') {
      return Patient.fromJson(_mockUsers['patient']!);
    } else if (username == 'doktor' && password == '123456') {
      return Doctor.fromJson(_mockUsers['doctor']!);
    } else if (username == 'admin' && password == '123456') {
      return Admin.fromJson(_mockUsers['admin']!);
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

      // GEÇİCİ ÇÖZÜM: userType kontrolü
      String userType = userData['userType'] ?? 'patient'; // Varsayılan patient

      print("🔍 DEBUG - User type: $userType");

      switch (userType) {
        case 'patient':
          print("✅ DEBUG - Creating Patient object");
          return Patient.fromJson(userData);
        case 'doctor':
          print("✅ DEBUG - Creating Doctor object");
          return Doctor.fromJson(userData);
        case 'admin':
          print("✅ DEBUG - Creating Admin object");
          return Admin.fromJson(userData);
        default:
          print("⚠️ DEBUG - Unknown user type, creating base User");
          return User.fromJson(userData);
      }
    }

    print("❌ DEBUG - No user found in storage");
    return null;
  }

  /// Kullanıcıyı kaydeder
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    print("🔍 DEBUG - User to be saved:");
    print("  userType: ${user.userType}");
    print("  runtimeType: ${user.runtimeType}");

    final userJson = json.encode(user.toJson());
    print("🔍 DEBUG - JSON to save: $userJson");

    await prefs.setString(_userKey, userJson);
    print("✅ DEBUG - User saved successfully");
  }
}
