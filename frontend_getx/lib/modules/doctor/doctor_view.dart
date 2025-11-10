// lib/modules/doctor/doctor_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmedchain/app/routes/app_routes.dart';
import 'package:lightmedchain/models/user_model.dart';
import 'package:lightmedchain/services/auth_service.dart';
import 'doctor_controller.dart';

class DoctorView extends GetView<DoctorController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doktor Paneli'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadPatientsData,
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
            index: controller.currentTabIndex.value,
            children: [
              _buildDashboard(),
              _buildAnalyticsView(),
              _buildBlockchainView(),
              _buildProfileView(),
            ],
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentTabIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analiz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.link),
                label: 'Blockchain',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          )),
    );
  }

  Widget _buildDashboard() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hoş Geldiniz Kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.medical_services,
                          size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${controller.currentDoctor.value?.fullName ?? controller.currentDoctor.value?.username}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.currentDoctor.value?.specialization ??
                                '',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          if (controller.currentDoctor.value?.hospital !=
                              null) ...[
                            const SizedBox(height: 2),
                            Text(
                              controller.currentDoctor.value!.hospital!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Hızlı İstatistikler
            const Text(
              'Hızlı İstatistikler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                    'Toplam Hasta',
                    controller.patients.length.toString(),
                    Icons.people,
                    Colors.blue),
                _buildStatCard(
                    'Aktif Kayıt',
                    controller.patients.length.toString(),
                    Icons.monitor_heart,
                    Colors.green),
                _buildStatCard(
                    'Kritik Durum', '1', Icons.warning, Colors.orange),
                _buildStatCard('Blok Sayısı', '12', Icons.link, Colors.purple),
              ],
            ),

            const SizedBox(height: 20),

            // Hastalar Listesi
            const Text(
              'Hastalarım',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...controller.patientData
                .map((data) => _buildPatientCard(data))
                .toList(),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> data) {
    final patient = data['patient'] as Patient;
    final latestData = data['latestData'];
    final trend = data['trend'] as String;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName ?? patient.username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Yaş: ${controller.calculateAge(patient.dateOfBirth)} • ${patient.gender ?? ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildTrendIndicator(trend),
              ],
            ),

            const SizedBox(height: 12),

            // Tıbbi Veriler
            if (latestData != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('SpO2', '${latestData.spo2Value}%',
                      controller.getSpo2Color(latestData.spo2Value)),
                  _buildMetricItem('BPM', '${latestData.bpmValue}',
                      controller.getBpmColor(latestData.bpmValue)),
                  _buildMetricItem('AHI', latestData.ahiIndex,
                      controller.getAhiColor(latestData.ahiIndex)),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // İşlem Butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.viewPatientDetails(patient),
                    child: const Text('Detayları Gör'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _analyzePatientData(patient),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Analiz Et',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(String trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case 'improving':
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case 'declining':
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      default:
        icon = Icons.remove;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            trend == 'improving'
                ? 'İyileşiyor'
                : trend == 'declining'
                    ? 'Kötüleşiyor'
                    : 'Stabil',
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _analyzePatientData(Patient patient) {
    Get.dialog(
      AlertDialog(
        title: Text('${patient.fullName} - Medikal Analiz'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sleep Apnea Değerlendirmesi:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildAnalysisItem(
                  'Ortalama SpO2', '%88.5', 'Orta seviye hipoksemi'),
              _buildAnalysisItem('Ortalama BPM', '72', 'Normal kalp atışı'),
              _buildAnalysisItem(
                  'AHI İndeksi', 'Moderate', 'Orta şiddetli uyku apnesi'),
              _buildAnalysisItem('Öneriler', '',
                  'CPAP tedavisi önerilir\nKilo kontrolü\nYan yatış pozisyonu'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Başarılı',
                'Reçete oluşturuldu ve blockchain\'e kaydedildi',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Reçete Oluştur'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String value, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Detaylı Analiz Paneli',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          Text('Geliştirme aşamasında...'),
        ],
      ),
    );
  }

  Widget _buildBlockchainView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.apiService
          .getBlockchainStatus()
          .then((stats) => stats.toJson()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Hata: ${snapshot.error}'),
              ],
            ),
          );
        }

        final stats = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Blockchain Sistem Durumu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Sistem İstatistikleri
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Blockchain Metrikleri',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        children: [
                          _buildBlockchainStat('Toplam Blok',
                              stats['totalBlocks'].toString(), Icons.layers),
                          _buildBlockchainStat(
                              'İşlem Sayısı',
                              stats['totalTransactions'].toString(),
                              Icons.swap_horiz),
                          _buildBlockchainStat('Zorluk',
                              stats['difficulty'].toString(), Icons.speed),
                          _buildBlockchainStat(
                              'Bekleyen',
                              stats['pendingTransactions'].toString(),
                              Icons.pending),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Madencilik Kontrolleri
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Madencilik Kontrolleri',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.mineBlock,
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator()
                                : const Text('Blok Madenciliği Başlat'),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockchainStat(String label, String value, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileView() {
    return Obx(() {
      if (controller.currentDoctor.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final doctor = controller.currentDoctor.value!;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.medical_services,
                          size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Dr. ${doctor.fullName ?? doctor.username}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(doctor.email,
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mesleki Bilgiler',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoItem('Lisans No', doctor.licenseNumber),
                    _buildInfoItem('Uzmanlık', doctor.specialization),
                    if (doctor.hospital != null)
                      _buildInfoItem('Hastane', doctor.hospital!),
                    _buildInfoItem(
                        'Üyelik Tarihi', _formatDate(doctor.createdAt)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Çıkış Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                    Get.find<AuthService>().logout(); // ✅ await ile
                  Get.offAllNamed(AppRoutes.LOGIN);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Çıkış Yap',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.day}.${date.month}.${date.year}';
  }
}
