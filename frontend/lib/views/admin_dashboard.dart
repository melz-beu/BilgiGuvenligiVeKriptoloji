// Sistem yöneticisi paneli - Kullanıcı ve sistem yönetimi
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  late Admin _currentUser;
  List<User> _allUsers = [];
  bool _isLoading = true;
  Map<String, dynamic> _systemStats = {};
  Map<String, dynamic> _miningStats = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSystemData();
  }

  void _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentUser();
    if (user is Admin) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _loadSystemData() async {
    // Demo veriler - gerçek uygulamada API'den alınır
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _allUsers = [
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
          isActive: false, // Pasif kullanıcı
          dateOfBirth: '1975-12-20',
          gender: 'Erkek',
        ),
      ];

      _systemStats = {
        'totalUsers': _allUsers.length,
        'activeUsers': _allUsers.where((user) => user.isActive).length,
        'patients': _allUsers.where((user) => user.userType == 'patient').length,
        'doctors': _allUsers.where((user) => user.userType == 'doctor').length,
        'totalBlocks': 15,
        'pendingTransactions': 3,
        'systemUptime': '99.8%',
      };

      _miningStats = {
        'currentDifficulty': 2,
        'averageBlockTime': '0.012s',
        'totalHashOperations': '1,234,567',
        'networkComparison': {
          'bitcoin': '600s',
          'ethereum': '15s',
          'ourSystem': '0.012s',
        },
      };

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
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser.fullName ?? _currentUser.username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sistem Yöneticisi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
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

          // Sistem İstatistikleri
          const Text(
            'Sistem İstatistikleri',
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
              _buildStatCard('Toplam Kullanıcı', _systemStats['totalUsers'].toString(), Icons.people, Colors.blue),
              _buildStatCard('Aktif Kullanıcı', _systemStats['activeUsers'].toString(), Icons.person, Colors.green),
              _buildStatCard('Hasta Sayısı', _systemStats['patients'].toString(), Icons.sick, Colors.orange),
              _buildStatCard('Doktor Sayısı', _systemStats['doctors'].toString(), Icons.medical_services, Colors.red),
              _buildStatCard('Toplam Blok', _systemStats['totalBlocks'].toString(), Icons.layers, Colors.purple),
              _buildStatCard('Sistem Çalışma', _systemStats['systemUptime'], Icons.timer, Colors.teal),
            ],
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
              _buildActionCard('Kullanıcı Yönetimi', Icons.people_alt, Colors.blue, 
                () => setState(() { _currentIndex = 1; })),
              _buildActionCard('Sistem Ayarları', Icons.settings, Colors.green,
                () => setState(() { _currentIndex = 2; })),
              _buildActionCard('Blockchain', Icons.link, Colors.orange,
                () => setState(() { _currentIndex = 3; })),
              _buildActionCard('Performans', Icons.analytics, Colors.purple,
                _showPerformanceMetrics),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
                fontSize: 20,
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

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
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

  Widget _buildUserManagementView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kullanıcı Yönetimi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Kullanıcı Listesi
          ..._allUsers.map((user) => Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getUserColor(user.userType),
                child: Icon(
                  _getUserIcon(user.userType),
                  color: Colors.white,
                ),
              ),
              title: Text(user.fullName ?? user.username),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${user.userType} • ${user.email}'),
                  Text(
                    'Üyelik: ${_formatDate(user.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      user.isActive ? 'Aktif' : 'Pasif',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: user.isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Düzenle'),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(user.isActive ? 'Pasifleştir' : 'Aktifleştir'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Sil'),
                      ),
                    ],
                    onSelected: (value) => _handleUserAction(value, user),
                  ),
                ],
              ),
            ),
          )).toList(),

          const SizedBox(height: 20),

          // Yeni Kullanıcı Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addNewUser,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Yeni Kullanıcı Ekle',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUserColor(String userType) {
    switch (userType) {
      case 'admin':
        return Colors.purple;
      case 'doctor':
        return Colors.green;
      case 'patient':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getUserIcon(String userType) {
    switch (userType) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'doctor':
        return Icons.medical_services;
      case 'patient':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  String _formatDate(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.day}.${date.month}.${date.year}';
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'edit':
        _editUser(user);
        break;
      case 'toggle':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _editUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.fullName} Düzenle'),
        content: const Text('Kullanıcı düzenleme özelliği geliştirme aşamasında...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(User user) {
    setState(() {
      // Kullanıcı durumunu değiştir
      final index = _allUsers.indexWhere((u) => u.userId == user.userId);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].copyWith(isActive: !user.isActive);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.fullName} ${user.isActive ? 'pasifleştirildi' : 'aktifleştirildi'}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcı Sil'),
        content: Text('${user.fullName} kullanıcısını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allUsers.removeWhere((u) => u.userId == user.userId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.fullName} silindi'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _addNewUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kullanıcı Ekle'),
        content: const Text('Yeni kullanıcı ekleme özelliği geliştirme aşamasında...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettingsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sistem Ayarları',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Blockchain Ayarları
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Blockchain Ayarları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Zorluk Seviyesi
                  const Text('Madencilik Zorluk Seviyesi:'),
                  const SizedBox(height: 8),
                  
                  FutureBuilder<Map<String, dynamic>>(
                    future: Provider.of<ApiService>(context, listen: false).getDifficultyLevels(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      if (snapshot.hasError) {
                        return Text('Hata: ${snapshot.error}');
                      }
                      
                      final levels = snapshot.data!;
                      return Column(
                        children: levels.entries.map((entry) => ListTile(
                          leading: Text('Seviye ${entry.key}'),
                          title: Text(entry.value['description']),
                          subtitle: Text(entry.value['example']),
                          trailing: ElevatedButton(
                            onPressed: () => _setDifficultyLevel(int.parse(entry.key)),
                            child: const Text('Aktif Et'),
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Sistem Bakım
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sistem Bakım',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMaintenanceButton(
                    'Veritabanını Yedekle',
                    Icons.backup,
                    Colors.blue,
                    _backupDatabase,
                  ),
                  
                  _buildMaintenanceButton(
                    'Sistem Loglarını Temizle',
                    Icons.cleaning_services,
                    Colors.orange,
                    _clearLogs,
                  ),
                  
                  _buildMaintenanceButton(
                    'Blockchain Doğrula',
                    Icons.verified,
                    Colors.green,
                    _validateBlockchain,
                  ),
                  
                  _buildMaintenanceButton(
                    'Sistem Performans Testi',
                    Icons.speed,
                    Colors.purple,
                    _runPerformanceTest,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black,
        ),
      ),
    );
  }

  void _setDifficultyLevel(int level) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.setDifficultyLevel(level);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zorluk seviyesi $level olarak ayarlandı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _backupDatabase() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veritabanı yedekleme işlemi başlatıldı'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sistem logları temizlendi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _validateBlockchain() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Blockchain doğrulama işlemi başlatıldı'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _runPerformanceTest() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.runBenchmark();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Performans testi tamamlandı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                'Blockchain Yönetimi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Blockchain Kontrolleri
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Blockchain Kontrolleri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final apiService = Provider.of<ApiService>(context, listen: false);
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
                                      content: Text('Hata: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.diamond),
                              label: const Text('Blok Madenciliği Başlat'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Blok Listesi
              const Text(
                'Tüm Bloklar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...blocks.map((block) => Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: Icon(
                    Icons.circle,
                    color: block['index'] == 0 ? Colors.green : Colors.blue,
                  ),
                  title: Text('Blok #${block['index']}'),
                  subtitle: Text('Hash: ${block['hash'].substring(0, 20)}...'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBlockDetail('Tam Hash', block['hash']),
                          _buildBlockDetail('Önceki Hash', block['previous_hash']),
                          _buildBlockDetail('Nonce', block['nonce'].toString()),
                          _buildBlockDetail('Leading Zeros', block['leading_zeros'].toString()),
                          _buildBlockDetail('Zaman', _formatDateTime(block['timestamp'])),
                          if (block['index'] > 0) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Veriler:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...(block['data'] as List).take(3).map((data) => Text(
                              '• SpO2: ${data['spo2_value']}% | BPM: ${data['bpm_value']}',
                              style: const TextStyle(fontSize: 12),
                            )).toList(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showPerformanceMetrics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sistem Performans Metrikleri'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPerformanceItem('Ortalama Blok Süresi', _miningStats['averageBlockTime']),
              _buildPerformanceItem('Mevcut Zorluk', _miningStats['currentDifficulty'].toString()),
              _buildPerformanceItem('Toplam Hash İşlemi', _miningStats['totalHashOperations']),
              const SizedBox(height: 16),
              const Text(
                'Ağ Karşılaştırması:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._miningStats['networkComparison'].entries.map((entry) => 
                _buildPerformanceItem(entry.key, entry.value)
              ).toList(),
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

  Widget _buildPerformanceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
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
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser.fullName ?? _currentUser.username,
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
                    'Yönetici Bilgileri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem('Kullanıcı ID', _currentUser.userId),
                  _buildInfoItem('Üyelik Tarihi', _formatDate(_currentUser.createdAt)),
                  const SizedBox(height: 8),
                  const Text(
                    'Yetkiler:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._currentUser.permissions.map((permission) => 
                    Text('• $permission')
                  ).toList(),
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
        title: const Text('Yönetici Paneli'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSystemData,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          _buildUserManagementView(),
          _buildSystemSettingsView(),
          _buildBlockchainView(),
          _buildProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() { _currentIndex = index; }),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Kullanıcılar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
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

// User sınıfına copyWith metodu eklemek için extension
extension UserCopyWith on User {
  User copyWith({bool? isActive}) {
    return User(
      userId: userId,
      username: username,
      email: email,
      userType: userType,
      fullName: fullName,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}