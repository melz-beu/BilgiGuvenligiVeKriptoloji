// lib/modules/doctor/doctor_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmedchain/models/medical_data_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart'; 

class DoctorController extends GetxController {
 final AuthService authService = Get.find();
  final ApiService apiService = Get.find();

  final Rx<Doctor?> currentDoctor = Rx<Doctor?>(null);
  final RxList<Patient> patients = <Patient>[].obs;
  final RxList<Map<String, dynamic>> patientData = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctorData();
    loadPatientsData();
  }

  void loadDoctorData() {
    final user = authService.currentUser.value;
    if (user is Doctor) {
      currentDoctor.value = user;
    }
  }

  Future<void> loadPatientsData() async {
    try {
      isLoading.value = true;
      
      // Demo hasta verileri - gerçek uygulamada API'den alınır
      await Future.delayed(const Duration(seconds: 2));
      
      final demoPatients = [
        Patient(
          userId: 'patient_001',
          username: 'ahmet_yilmaz',
          email: 'ahmet@test.com',
          fullName: 'Ahmet Yılmaz',
          createdAt: '2024-01-01T00:00:00Z',
          isActive: true,
          dateOfBirth: '1980-05-15',
          gender: 'Erkek',
          phone: '+90 555 123 4567',
          medicalConditions: ['Sleep Apnea', 'Hipertansiyon'],
        ),
        Patient(
          userId: 'patient_002',
          username: 'ayse_demir',
          email: 'ayse@test.com',
          fullName: 'Ayşe Demir',
          createdAt: '2024-01-02T00:00:00Z',
          isActive: true,
          dateOfBirth: '1975-12-20',
          gender: 'Kadın',
          phone: '+90 555 765 4321',
          medicalConditions: ['Sleep Apnea', 'Obezite'],
        ),
      ];

      patients.assignAll(demoPatients);

      patientData.assignAll([
        {
          'patient': demoPatients[0],
          'latestData': OximeterData(
            dataId: 'data_001',
            patientId: 'patient_001',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            spo2Value: 88.5,
            bpmValue: 72.0,
            ahiIndex: 'Moderate',
          ),
          'trend': 'stable',
        },
        {
          'patient': demoPatients[1],
          'latestData': OximeterData(
            dataId: 'data_002',
            patientId: 'patient_002',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
            spo2Value: 92.0,
            bpmValue: 68.0,
            ahiIndex: 'Mild',
          ),
          'trend': 'improving',
        },
      ]);

    } catch (e) {
      Get.snackbar('Hata', 'Hasta verileri yüklenirken hata: $e');
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

  String calculateAge(String? birthDate) {
    if (birthDate == null) return '0';
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    return (now.year - birth.year).toString();
  }

  Color getSpo2Color(double spo2) {
    if (spo2 < 85) return Colors.red;
    if (spo2 < 90) return Colors.orange;
    if (spo2 < 95) return Colors.yellow;
    return Colors.green;
  }

  Color getBpmColor(double bpm) {
    if (bpm < 60 || bpm > 100) return Colors.red;
    if (bpm < 65 || bpm > 90) return Colors.orange;
    return Colors.green;
  }

  Color getAhiColor(String ahiIndex) {
    switch (ahiIndex) {
      case 'Severe': return Colors.red;
      case 'Moderate': return Colors.orange;
      case 'Mild': return Colors.yellow;
      default: return Colors.green;
    }
  }

  void viewPatientDetails(Patient patient) {
    Get.dialog(
      AlertDialog(
        title: Text('Hasta Detayları - ${patient.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Tam Adı', patient.fullName ?? '-'),
              _buildDetailItem('E-posta', patient.email),
              if (patient.dateOfBirth != null) _buildDetailItem('Doğum Tarihi', patient.dateOfBirth!),
              if (patient.gender != null) _buildDetailItem('Cinsiyet', patient.gender!),
              if (patient.phone != null) _buildDetailItem('Telefon', patient.phone!),
              if (patient.emergencyContact != null) _buildDetailItem('Acil İletişim', patient.emergencyContact!),
              if (patient.medicalConditions?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                const Text('Tıbbi Durumlar:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...patient.medicalConditions!.map((condition) => Text('• $condition')).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}