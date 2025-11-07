// Doktor kontrol paneli - Hasta takip ve analiz
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/medical_data_model.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _currentIndex = 0;
  late Doctor _currentUser;
  List<Patient> _patients = [];
  List<Map<String, dynamic>> _patientData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPatientsData();
  }

  void _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentUser();
    if (user is Doctor) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _loadPatientsData() async {
    // Demo hasta verileri - gerçek uygulamada API'den alınır
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _patients = [
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

      _patientData = [
        {
          'patient': _patients[0],
          'latestData': OximeterData(
            dataId: 'data_001',
            patientId: 'patient_001',
            timestamp: DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
            spo2Value: 88.5,
            bpmValue: 72.0,
            ahiIndex: 'Moderate',
          ),
          'trend': 'stable',
        },
        {
          'patient': _patients[1],
          'latestData': OximeterData(
            dataId: 'data_002',
            patientId: 'patient_002',
            timestamp: DateTime.now()
                .subtract(const Duration(hours: 1))
                .toIso8601String(),
            spo2Value: 92.0,
            bpmValue: 68.0,
            ahiIndex: 'Mild',
          ),
          'trend': 'improving',
        },
      ];

      _isLoading = false;
    });
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
                          'Dr. ${_currentUser.fullName ?? _currentUser.username}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentUser.specialization,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_currentUser.hospital != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _currentUser.hospital!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
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
              _buildStatCard('Toplam Hasta', _patients.length.toString(),
                  Icons.people, Colors.blue),
              _buildStatCard('Aktif Kayıt', '${_patients.length}',
                  Icons.monitor_heart, Colors.green),
              _buildStatCard('Kritik Durum', '1', Icons.warning, Colors.orange),
              _buildStatCard('Blok Sayısı', '12', Icons.link, Colors.purple),
            ],
          ),

          const SizedBox(height: 20),

          // Hastalar Listesi
          const Text(
            'Hastalarım',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ..._patientData.map((data) => _buildPatientCard(data)).toList(),
        ],
      ),
    );
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
                color: Colors.blue,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> data) {
    final patient = data['patient'] as Patient;
    final latestData = data['latestData'] as OximeterData;
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Yaş: ${_calculateAge(patient.dateOfBirth)} • ${patient.gender ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTrendIndicator(trend),
              ],
            ),

            const SizedBox(height: 12),

            // Tıbbi Veriler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem('SpO2', '${latestData.spo2Value}%',
                    _getSpo2Color(latestData.spo2Value)),
                _buildMetricItem('BPM', '${latestData.bpmValue}',
                    _getBpmColor(latestData.bpmValue)),
                _buildMetricItem('AHI', latestData.ahiIndex,
                    _getAhiColor(latestData.ahiIndex)),
              ],
            ),

            const SizedBox(height: 12),

            // İşlem Butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewPatientDetails(patient),
                    child: const Text('Detayları Gör'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _analyzePatientData(patient),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Analiz Et',
                      style: TextStyle(color: Colors.white),
                    ),
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
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
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

  Color _getSpo2Color(double spo2) {
    if (spo2 < 85) return Colors.red;
    if (spo2 < 90) return Colors.orange;
    if (spo2 < 95) return Colors.yellow;
    return Colors.green;
  }

  Color _getBpmColor(double bpm) {
    if (bpm < 60 || bpm > 100) return Colors.red;
    if (bpm < 65 || bpm > 90) return Colors.orange;
    return Colors.green;
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

  int _calculateAge(String? birthDate) {
    if (birthDate == null) return 0;
    final birth = DateTime.parse(birthDate);
    final now = DateTime.now();
    return now.year - birth.year;
  }

  void _viewPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hasta Detayları - ${patient.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Tam Adı', patient.fullName ?? '-'),
              _buildDetailItem('E-posta', patient.email),
              if (patient.dateOfBirth != null)
                _buildDetailItem('Doğum Tarihi', patient.dateOfBirth!),
              if (patient.gender != null)
                _buildDetailItem('Cinsiyet', patient.gender!),
              if (patient.phone != null)
                _buildDetailItem('Telefon', patient.phone!),
              if (patient.emergencyContact != null)
                _buildDetailItem('Acil İletişim', patient.emergencyContact!),
              if (patient.medicalConditions?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                const Text(
                  'Tıbbi Durumlar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...patient.medicalConditions!
                    .map((condition) => Text('• $condition'))
                    .toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _analyzePatientData(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${patient.fullName} - Medikal Analiz'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sleep Apnea Değerlendirmesi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reçete oluşturma işlemi
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Reçete oluşturuldu ve blockchain\'e kaydedildi'),
                  backgroundColor: Colors.green,
                ),
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
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
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
          Text(
            'Detaylı Analiz Paneli',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text('Geliştirme aşamasında...'),
        ],
      ),
    );
  }

  Widget _buildBlockchainView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Provider.of<ApiService>(context, listen: false)
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        children: [
                          _buildBlockchainStat('Toplam Blok',
                              stats['total_blocks'].toString(), Icons.layers),
                          _buildBlockchainStat(
                              'İşlem Sayısı',
                              stats['total_transactions'].toString(),
                              Icons.swap_horiz),
                          _buildBlockchainStat('Zorluk',
                              stats['difficulty'].toString(), Icons.speed),
                          _buildBlockchainStat(
                              'Bekleyen',
                              stats['pending_transactions'].toString(),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final apiService =
                              Provider.of<ApiService>(context, listen: false);
                          try {
                            await apiService.mineBlock();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Blok başarıyla madenci!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Madencilik hatası: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('Blok Madenciliği Başlat'),
                      ),
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
                    'Dr. ${_currentUser.fullName ?? _currentUser.username}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentUser.email,
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
                    'Mesleki Bilgiler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem('Lisans No', _currentUser.licenseNumber),
                  _buildInfoItem('Uzmanlık', _currentUser.specialization),
                  if (_currentUser.hospital != null)
                    _buildInfoItem('Hastane', _currentUser.hospital!),
                  _buildInfoItem(
                      'Üyelik Tarihi', _formatDate(_currentUser.createdAt)),
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
            width: 100,
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
        title: const Text('Doktor Paneli'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientsData,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          _buildAnalyticsView(),
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
      ),
    );
  }
}
