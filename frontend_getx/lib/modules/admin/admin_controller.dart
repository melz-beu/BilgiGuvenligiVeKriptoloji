// lib/modules/admin/admin_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AdminController extends GetxController {
  final AuthService authService = Get.find();
  final ApiService apiService = Get.find();

  final Rx<Admin?> currentAdmin = Rx<Admin?>(null);
  final RxList<User> allUsers = <User>[].obs;
  final RxMap<String, dynamic> systemStats = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> miningStats = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdminData();
    loadSystemData();
  }

  void loadAdminData() {
    final user = authService.currentUser.value;
    if (user is Admin) {
      currentAdmin.value = user;
    }
  }

  Future<void> loadSystemData() async {
    try {
      isLoading.value = true;
      
      // Demo sistem verileri
      await Future.delayed(const Duration(seconds: 2));

      final demoUsers = [
        Admin(
          userId: 'admin_001',
          username: 'admin',
          email: 'admin@test.com',
          fullName: 'Sistem Yöneticisi',
          createdAt: '2024-01-01T00:00:00Z',
          isActive: true,
          permissions: ['all'],
        ),
        Doctor(
          userId: 'doctor_001',
          username: 'doktor',
          email: 'doktor@test.com',
          fullName: 'Dr. Ayşe Demir',
          createdAt: '2024-01-02T00:00:00Z',
          isActive: true,
          licenseNumber: 'MED123456',
          specialization: 'Kardiyoloji',
          hospital: 'İstanbul Tıp Merkezi',
        ),
        Patient(
          userId: 'patient_001',
          username: 'hasta',
          email: 'hasta@test.com',
          fullName: 'Ahmet Yılmaz',
          createdAt: '2024-01-03T00:00:00Z',
          isActive: true,
          dateOfBirth: '1980-05-15',
          gender: 'Erkek',
        ),
        Patient(
          userId: 'patient_002',
          username: 'hasta2',
          email: 'hasta2@test.com',
          fullName: 'Mehmet Kaya',
          createdAt: '2024-01-04T00:00:00Z',
          isActive: false,
          dateOfBirth: '1975-12-20',
          gender: 'Erkek',
        ),
      ];

      allUsers.assignAll(demoUsers);

      systemStats.value = {
        'totalUsers': allUsers.length,
        'activeUsers': allUsers.where((user) => user.isActive).length,
        'patients': allUsers.where((user) => user.userType == 'patient').length,
        'doctors': allUsers.where((user) => user.userType == 'doctor').length,
        'totalBlocks': 15,
        'pendingTransactions': 3,
        'systemUptime': '99.8%',
      };

      miningStats.value = {
        'currentDifficulty': 2,
        'averageBlockTime': '0.012s',
        'totalHashOperations': '1,234,567',
        'networkComparison': {
          'bitcoin': '600s',
          'ethereum': '15s',
          'ourSystem': '0.012s',
        },
      };

    } catch (e) {
      Get.snackbar('Hata', 'Sistem verileri yüklenirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDifficultyLevel(int level) async {
    try {
      isLoading.value = true;
      await apiService.setDifficultyLevel(level);
      Get.snackbar('Başarılı', 'Zorluk seviyesi $level olarak ayarlandı',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Hata', 'Zorluk seviyesi ayarlanırken hata: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> runBenchmark() async {
    try {
      isLoading.value = true;
      await apiService.runBenchmark();
      Get.snackbar('Başarılı', 'Performans testi tamamlandı',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Hata', 'Benchmark testi sırasında hata: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> mineBlock() async {
    try {
      isLoading.value = true;
      await apiService.mineBlock();
      Get.snackbar('Başarılı', 'Blok başarıyla madenci!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Hata', 'Madencilik sırasında hata: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void toggleUserStatus(User user) {
    final index = allUsers.indexWhere((u) => u.userId == user.userId);
    if (index != -1) {
      // User tipine göre doğru copyWith metodunu kullan
      final updatedUser = _getUpdatedUserWithStatus(allUsers[index], !user.isActive);
      allUsers[index] = updatedUser;
      loadSystemData(); // İstatistikleri yenile
    }
  }

  User _getUpdatedUserWithStatus(User user, bool newStatus) {
    // User tipine göre doğru copyWith metodunu kullan
    if (user is Patient) {
      return user.copyWithPatient(isActive: newStatus);
    } else if (user is Doctor) {
      return user.copyWithDoctor(isActive: newStatus);
    } else if (user is Admin) {
      return user.copyWithAdmin(isActive: newStatus);
    } else {
      return user.copyWith(isActive: newStatus);
    }
  }

  void deleteUser(User user) {
    allUsers.removeWhere((u) => u.userId == user.userId);
    loadSystemData(); // İstatistikleri yenile
    Get.snackbar('Başarılı', '${user.fullName} silindi',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Color getUserColor(String userType) {
    switch (userType) {
      case 'admin': return Colors.purple;
      case 'doctor': return Colors.green;
      case 'patient': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData getUserIcon(String userType) {
    switch (userType) {
      case 'admin': return Icons.admin_panel_settings;
      case 'doctor': return Icons.medical_services;
      case 'patient': return Icons.person;
      default: return Icons.person;
    }
  }

  String formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return timestamp;
    }
  }
}