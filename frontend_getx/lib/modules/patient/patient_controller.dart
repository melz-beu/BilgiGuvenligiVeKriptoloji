// lib/modules/patient/patient_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../models/medical_data_model.dart';

class PatientController extends GetxController {
  final AuthService authService = Get.find();
  final ApiService apiService = Get.find();

  final Rx<Patient?> currentPatient = Rx<Patient?>(null);
  final RxList<OximeterData> medicalData = <OximeterData>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRecording = false.obs;
  final RxString recordingStatus = ''.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPatientData();
    loadMedicalData();
  }

  void loadPatientData() {
    final user = authService.currentUser.value;
    if (user is Patient) {
      currentPatient.value = user;
    }
  }

  Future<void> loadMedicalData() async {
    try {
      if (currentPatient.value == null) return;
      
      isLoading.value = true;
      final response = await apiService.getPatientMedicalData(currentPatient.value!.userId);
      
      if (response['database_records'] != null) {

      /*  for (var i = 0; i < (response['database_records'] as List).length; i++) {

          var veri = response['database_records'][i];
          medicalData.add(veri);
        }*/
        medicalData.assignAll(
          (response['database_records'] as List)
              .map((item) => OximeterData.fromJson(item))
              .toList()
        );
      }
    } catch (e) {
      Get.snackbar('Hata', 'Veriler yüklenirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startOximeterRecording() async {
    try {
      isRecording.value = true;
      recordingStatus.value = 'Cihazlar taranıyor...';

      // Cihazları tara
      final devices = await apiService.scanOximeterDevices();
      if (devices.isEmpty) {
        throw Exception('Cihaz bulunamadı');
      }

      recordingStatus.value = 'Cihaza bağlanıyor...';
      await apiService.connectOximeter(devices.first);

      recordingStatus.value = 'Veri kaydı başlatılıyor...';
      
      // Demo veri kaydı
      await _recordDemoData(devices.first);

      recordingStatus.value = 'Kayıt tamamlandı!';
      
      // Verileri yenile
      await loadMedicalData();

      Get.snackbar(
        'Başarılı', 
        'Veri kaydı tamamlandı ve blockchain\'e eklendi!',
        backgroundColor: Colors.green, 
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar(
        'Hata', 
        'Kayıt sırasında hata: $e',
        backgroundColor: Colors.red, 
        colorText: Colors.white,
      );
    } finally {
      isRecording.value = false;
    }
  }

  Future<void> _recordDemoData(String deviceId) async {
    // Demo veri kaydı - 5 saniye boyunca veri kaydeder
    for (int i = 0; i < 5; i++) {
      if (!isRecording.value) break;
      
      final spo2 = 85.0 + (i * 3.0); // İyileşen SpO2
      final bpm = 75.0 + (i * 2.0);  // Artan BPM
      
      await apiService.recordMedicalData(
        patientId: currentPatient.value!.userId,
        spo2Value: spo2,
        bpmValue: bpm,
        deviceId: deviceId,
      );
      
      recordingStatus.value = 'Veri kaydediliyor... ${i + 1}/5';
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> mineBlock() async {
    try {
      isLoading.value = true;
      await apiService.mineBlock();
      Get.snackbar(
        'Başarılı', 
        'Blok başarıyla madenci!',
        backgroundColor: Colors.green, 
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata', 
        'Madencilik sırasında hata: $e',
        backgroundColor: Colors.red, 
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  String calculateAge(String? birthDate) {
    if (birthDate == null) return '0';
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return '0';
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

  String formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  Color getAhiColor(String ahiIndex) {
    switch (ahiIndex) {
      case 'Severe': return Colors.red;
      case 'Moderate': return Colors.orange;
      case 'Mild': return Colors.yellow;
      default: return Colors.green;
    }
  }
}