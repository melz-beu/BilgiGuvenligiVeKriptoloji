// lib/modules/patient/patient_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lightmedchain/app/routes/app_routes.dart';
import 'package:lightmedchain/services/auth_service.dart';
import 'patient_controller.dart';

class PatientView extends GetView<PatientController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Paneli'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadMedicalData,
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
            index: controller.currentTabIndex.value,
            children: [
              _buildDashboard(),
              _buildDataVisualization(),
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
                icon: Icon(Icons.show_chart),
                label: 'Grafikler',
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
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoş geldiniz, ${controller.currentPatient.value?.fullName ?? controller.currentPatient.value?.username}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sleep Apnea Takip Sistemi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Hızlı İşlemler
          const Text(
            'Hızlı İşlemler',
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
              _buildActionCard(
                'Oksimetre Başlat',
                Icons.play_arrow,
                Colors.green,
                controller.startOximeterRecording,
              ),
              _buildActionCard(
                'Verilerimi Gör',
                Icons.visibility,
                Colors.blue,
                () => controller.changeTab(1),
              ),
              _buildActionCard(
                'Blok Zinciri',
                Icons.link,
                Colors.orange,
                () => controller.changeTab(2),
              ),
              _buildActionCard(
                'Profilim',
                Icons.person,
                Colors.purple,
                () => controller.changeTab(3),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Son Ölçümler
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Son Ölçümler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildLatestMeasurements(),
                ],
              ),
            ),
          ),

          // Kayıt Durumu
          Obx(() => controller.isRecording.value
              ? _buildRecordingStatus()
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestMeasurements() {
    if (controller.medicalData.isEmpty) {
      return const ListTile(
        leading: Icon(Icons.info, color: Colors.orange),
        title: Text('Henüz ölçüm bulunmuyor'),
        subtitle:
            Text('Oksimetre başlat butonuna tıklayarak ilk ölçümünüzü yapın'),
      );
    }

    final latestData = controller.medicalData.take(3).toList();
    return Column(
      children: latestData
          .map((data) => ListTile(
                leading: const Icon(Icons.monitor_heart, color: Colors.red),
                title: Text('SpO2: ${data.spo2Value}% - BPM: ${data.bpmValue}'),
                subtitle: Text(
                    'AHI: ${data.ahiIndex} - ${controller.formatTime(data.timestamp)}'),
                trailing: _getStatusIcon(data.ahiIndex),
              ))
          .toList(),
    );
  }

  Widget _getStatusIcon(String ahiIndex) {
    switch (ahiIndex) {
      case 'Severe':
        return const Icon(Icons.warning, color: Colors.red);
      case 'Moderate':
        return const Icon(Icons.warning, color: Colors.orange);
      case 'Mild':
        return const Icon(Icons.info, color: Colors.yellow);
      default:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }

  Widget _buildRecordingStatus() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        elevation: 3,
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Veri Kaydı Devam Ediyor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Obx(() => Text(
                          controller.recordingStatus.value,
                          style: TextStyle(color: Colors.grey[600]),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataVisualization() {
    return Obx(() {
      if (controller.medicalData.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Henüz veri bulunmuyor',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              Text('Oksimetre ile veri kaydı yaparak grafikleri görüntüleyin'),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSpO2Chart(),
            const SizedBox(height: 20),
            _buildBPMChart(),
            const SizedBox(height: 20),
            _buildDataList(),
          ],
        ),
      );
    });
  }

  Widget _buildSpO2Chart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Oksijen Satürasyonu (SpO2)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.medicalData.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.spo2Value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBPMChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kalp Atış Hızı (BPM)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: controller.medicalData.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.bpmValue);
                      }).toList(),
                      isCurved: true,
                      color: Colors.red,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.red.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tüm Ölçümler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...controller.medicalData
                .map((data) => ListTile(
                      leading:
                          const Icon(Icons.monitor_heart, color: Colors.green),
                      title: Text(
                          'SpO2: ${data.spo2Value}% | BPM: ${data.bpmValue}'),
                      subtitle: Text(
                          'Zaman: ${controller.formatTime(data.timestamp)}'),
                      trailing: Chip(
                        label: Text(data.ahiIndex),
                        backgroundColor: controller.getAhiColor(data.ahiIndex),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.apiService.getFullChain(),
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

        final chainData = snapshot.data!;
        final blocks = chainData['chain'] as List;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Blockchain Verilerim',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Blockchain İstatistikleri
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Blockchain Durumu',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                              'Toplam Blok', blocks.length.toString()),
                          _buildStatItem(
                              'Zorluk', chainData['difficulty'].toString()),
                          _buildStatItem('Bekleyen',
                              chainData['pending_data'].length.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Madencilik Butonu
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Madencilik Kontrolleri',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
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

              const SizedBox(height: 20),

              // Blok Listesi
              ...blocks
                  .map((blockData) => Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: blockData['index'] == 0
                                        ? Colors.green
                                        : Colors.blue,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Blok #${blockData['index']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'Hash: ${blockData['hash'].substring(0, 20)}...'),
                              Text(
                                  'Önceki Hash: ${blockData['previous_hash'].substring(0, 20)}...'),
                              Text('Nonce: ${blockData['nonce']}'),
                              Text(
                                  'Leading Zeros: ${blockData['leading_zeros']}'),
                              if (blockData['index'] > 0) ...[
                                const SizedBox(height: 8),
                                const Text('Tıbbi Veriler:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                ...(blockData['data'] as List)
                                    .take(2)
                                    .map((data) => Text(
                                          '• SpO2: ${data['spo2_value']}% | BPM: ${data['bpm_value']}',
                                          style: const TextStyle(fontSize: 12),
                                        ))
                                    .toList(),
                              ],
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileView() {
    return Obx(() {
      if (controller.currentPatient.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final patient = controller.currentPatient.value!;

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
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      patient.fullName ?? patient.username,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(patient.email,
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
                    const Text('Kişisel Bilgiler',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoItem('Kullanıcı ID', patient.userId),
                    if (patient.dateOfBirth != null)
                      _buildInfoItem('Doğum Tarihi', patient.dateOfBirth!),
                    if (patient.gender != null)
                      _buildInfoItem('Cinsiyet', patient.gender!),
                    if (patient.phone != null)
                      _buildInfoItem('Telefon', patient.phone!),
                    _buildInfoItem('Üyelik Tarihi',
                        controller.formatDate(patient.createdAt)),
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
                    const Text('Tıbbi Durum',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (patient.medicalConditions?.isNotEmpty ?? false) ...[
                      ...patient.medicalConditions!
                          .map(
                              (condition) => _buildInfoItem('Durum', condition))
                          .toList(),
                    ] else ...[
                      const Text('Henüz tıbbi durum bilgisi eklenmemiş'),
                    ],
                    if (patient.emergencyContact != null)
                      _buildInfoItem(
                          'Acil Durum İletişim', patient.emergencyContact!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Çıkış Butonu
            // Çıkış Butonu kısmını şu şekilde güncelleyin:
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
              width: 120,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
