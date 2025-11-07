// Hasta kontrol paneli - Makaledeki hasta işlevselliği
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/medical_data_model.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentIndex = 0;
  Patient? _currentUser;
  List<OximeterData> _medicalData = [];
  bool _isLoading = true;
  bool _isRecording = false;
  String _recordingStatus = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMedicalData();
  }

void _loadUserData() async {
  print("🔍 DEBUG - _loadUserData started");
  final authService = Provider.of<AuthService>(context, listen: false);
  final user = await authService.getCurrentUser();
  print("🔍 DEBUG - User from auth: $user");
  print("🔍 DEBUG - User type: ${user?.runtimeType}");
  
  if (user is Patient) {
    setState(() {
      _currentUser = user;
    });
    print("✅ DEBUG - Patient set: ${user.username}");
    
    // Medical data'yı da yükle
    _loadMedicalData();
  } else {
    print("❌ DEBUG - User is not Patient");
  }
}

  void _loadMedicalData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final response =
          await apiService.getPatientMedicalData(_currentUser!.userId);
      setState(() {
        _medicalData = (response['database_records'] as List)
            .map((item) => OximeterData.fromJson(item))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Veri yükleme hatası: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startOximeterRecording() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _isRecording = true;
      _recordingStatus = 'Cihaz bağlanıyor...';
    });

    try {
      // Cihazları tara ve bağlan
      final devices = await apiService.scanOximeterDevices();
      if (devices.isEmpty) {
        throw Exception('Cihaz bulunamadı');
      }

      setState(() {
        _recordingStatus = 'Cihaza bağlanıyor...';
      });

      await apiService.connectOximeter(devices.first);

      setState(() {
        _recordingStatus = 'Veri kaydı başlatılıyor...';
      });

      // Kaydı başlat
      await apiService.startOximeterRecording(
        patientId: _currentUser!.userId,
        deviceId: devices.first,
        duration: 30, // 30 saniye kayıt
      );

      setState(() {
        _recordingStatus = 'Veri kaydı başladı...';
      });

      // Kayıt bitene kadar bekle
      await Future.delayed(const Duration(seconds: 35));

      setState(() {
        _isRecording = false;
        _recordingStatus = 'Kayıt tamamlandı!';
      });

      // Verileri yenile
      _loadMedicalData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veri kaydı başarıyla tamamlandı ve blockchain\'e eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isRecording = false;
        _recordingStatus = 'Hata: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDashboard() {
    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Kullanıcı bilgileri yükleniyor...'),
          ],
        ),
      );
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
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hoş geldiniz, ${_currentUser!.fullName ?? _currentUser!.username}',
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
                _startOximeterRecording,
              ),
              _buildActionCard(
                'Verilerimi Gör',
                Icons.visibility,
                Colors.blue,
                () => setState(() {
                  _currentIndex = 1;
                }),
              ),
              _buildActionCard(
                'Blok Zinciri',
                Icons.link,
                Colors.orange,
                () => setState(() {
                  _currentIndex = 2;
                }),
              ),
              _buildActionCard(
                'Profilim',
                Icons.person,
                Colors.purple,
                () => setState(() {
                  _currentIndex = 3;
                }),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLatestMeasurements(),
                ],
              ),
            ),
          ),

          // Kayıt Durumu
          if (_isRecording) ...[
            const SizedBox(height: 20),
            Card(
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _recordingStatus,
                            style: TextStyle(
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
          ],
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestMeasurements() {
    if (_medicalData.isEmpty) {
      return const ListTile(
        leading: Icon(Icons.info, color: Colors.orange),
        title: Text('Henüz ölçüm bulunmuyor'),
        subtitle:
            Text('Oksimetre başlat butonuna tıklayarak ilk ölçümünüzü yapın'),
      );
    }

    final latestData = _medicalData.take(3).toList();
    return Column(
      children: latestData
          .map((data) => ListTile(
                leading: const Icon(Icons.monitor_heart, color: Colors.red),
                title: Text('SpO2: ${data.spo2Value}% - BPM: ${data.bpmValue}'),
                subtitle: Text(
                    'AHI: ${data.ahiIndex} - ${_formatTime(data.timestamp)}'),
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

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDataVisualization() {
    if (_medicalData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz veri bulunmuyor',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text('Oksimetre ile veri kaydı yaparak grafikleri görüntüleyin'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // SpO2 Grafiği
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Oksijen Satürasyonu (SpO2)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                            spots: _medicalData.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                e.value.spo2Value,
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.3)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // BPM Grafiği
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kalp Atış Hızı (BPM)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                            spots: _medicalData.asMap().entries.map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                e.value.bpmValue,
                              );
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
          ),

          const SizedBox(height: 20),

          // Veri Listesi
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tüm Ölçümler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._medicalData
                      .map((data) => ListTile(
                            leading:
                                Icon(Icons.monitor_heart, color: Colors.green),
                            title: Text(
                                'SpO2: ${data.spo2Value}% | BPM: ${data.bpmValue}'),
                            subtitle: Text(
                                'Zaman: ${_formatDateTime(data.timestamp)}'),
                            trailing: Chip(
                              label: Text(data.ahiIndex),
                              backgroundColor: _getAhiColor(data.ahiIndex),
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAhiColor(String ahiIndex) {
    switch (ahiIndex) {
      case 'Severe':
        return Colors.red;
      case 'Moderate':
        return Colors.orange;
      case 'Mild':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  String _formatDateTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBlockchainView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Provider.of<ApiService>(context, listen: false).getFullChain(),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                                      fontSize: 16,
                                    ),
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
                                const Text(
                                  'Tıbbi Veriler:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileView() {
    if (_currentUser == null) {
      return Center(child: CircularProgressIndicator());
    }

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
                    _currentUser!.fullName ?? _currentUser!.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentUser!.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
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
                  const Text(
                    'Kişisel Bilgiler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem('Kullanıcı ID', _currentUser!.userId),
                  if (_currentUser!.dateOfBirth != null)
                    _buildInfoItem('Doğum Tarihi', _currentUser!.dateOfBirth!),
                  if (_currentUser!.gender != null)
                    _buildInfoItem('Cinsiyet', _currentUser!.gender!),
                  if (_currentUser!.phone != null)
                    _buildInfoItem('Telefon', _currentUser!.phone!),
                  _buildInfoItem(
                      'Üyelik Tarihi', _formatDate(_currentUser!.createdAt)),
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
                  const Text(
                    'Tıbbi Durum',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentUser!.medicalConditions?.isNotEmpty ?? false) ...[
                    ..._currentUser!.medicalConditions!
                        .map((condition) => _buildInfoItem('Durum', condition))
                        .toList(),
                  ] else ...[
                    const Text('Henüz tıbbi durum bilgisi eklenmemiş'),
                  ],
                  if (_currentUser!.emergencyContact != null)
                    _buildInfoItem(
                        'Acil Durum İletişim', _currentUser!.emergencyContact!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Çıkış Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Provider.of<AuthService>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasta Paneli'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedicalData,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          _buildDataVisualization(),
          _buildBlockchainView(),
          _buildProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
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
      ),
    );
  }
}
