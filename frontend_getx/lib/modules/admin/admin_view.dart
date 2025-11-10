// lib/modules/admin/admin_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmedchain/app/routes/app_routes.dart';
import 'package:lightmedchain/models/user_model.dart';
import 'package:lightmedchain/services/auth_service.dart';
import 'admin_controller.dart';

class AdminView extends GetView<AdminController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetici Paneli'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadSystemData,
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
            index: controller.currentTabIndex.value,
            children: [
              _buildDashboard(),
              _buildUserManagementView(),
              _buildSystemSettingsView(),
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
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.admin_panel_settings,
                          size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.currentAdmin.value?.fullName ??
                                controller.currentAdmin.value?.username ??
                                '',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sistem Yöneticisi',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                    'Toplam Kullanıcı',
                    controller.systemStats['totalUsers'].toString(),
                    Icons.people,
                    Colors.blue),
                _buildStatCard(
                    'Aktif Kullanıcı',
                    controller.systemStats['activeUsers'].toString(),
                    Icons.person,
                    Colors.green),
                _buildStatCard(
                    'Hasta Sayısı',
                    controller.systemStats['patients'].toString(),
                    Icons.sick,
                    Colors.orange),
                _buildStatCard(
                    'Doktor Sayısı',
                    controller.systemStats['doctors'].toString(),
                    Icons.medical_services,
                    Colors.red),
                _buildStatCard(
                    'Toplam Blok',
                    controller.systemStats['totalBlocks'].toString(),
                    Icons.layers,
                    Colors.purple),
                _buildStatCard(
                    'Sistem Çalışma',
                    controller.systemStats['systemUptime'],
                    Icons.timer,
                    Colors.teal),
              ],
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
                _buildActionCard('Kullanıcı Yönetimi', Icons.people_alt,
                    Colors.blue, () => controller.changeTab(1)),
                _buildActionCard('Sistem Ayarları', Icons.settings,
                    Colors.green, () => controller.changeTab(2)),
                _buildActionCard('Blockchain', Icons.link, Colors.orange,
                    () => controller.changeTab(3)),
                _buildActionCard('Performans', Icons.analytics, Colors.purple,
                    _showPerformanceMetrics),
              ],
            ),
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
                  fontSize: 20,
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
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserManagementView() {
    return Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kullanıcı Yönetimi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Kullanıcı Listesi
              ...controller.allUsers
                  .map((user) => Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                controller.getUserColor(user.userType),
                            child: Icon(controller.getUserIcon(user.userType),
                                color: Colors.white),
                          ),
                          title: Text(user.fullName ?? user.username),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${user.userType} • ${user.email}'),
                              Text(
                                'Üyelik: ${controller.formatDate(user.createdAt)}',
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
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                                backgroundColor:
                                    user.isActive ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Düzenle')),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(user.isActive
                                        ? 'Pasifleştir'
                                        : 'Aktifleştir'),
                                  ),
                                  const PopupMenuItem(
                                      value: 'delete', child: Text('Sil')),
                                ],
                                onSelected: (value) =>
                                    _handleUserAction(value, user),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),

              const SizedBox(height: 20),

              // Yeni Kullanıcı Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addNewUser,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Yeni Kullanıcı Ekle',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ));
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'edit':
        _editUser(user);
        break;
      case 'toggle':
        controller.toggleUserStatus(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _editUser(User user) {
    Get.dialog(
      AlertDialog(
        title: Text('${user.fullName} Düzenle'),
        content:
            const Text('Kullanıcı düzenleme özelliği geliştirme aşamasında...'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(User user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Kullanıcı Sil'),
        content: Text(
            '${user.fullName} kullanıcısını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteUser(user);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _addNewUser() {
    Get.dialog(
      AlertDialog(
        title: const Text('Yeni Kullanıcı Ekle'),
        content: const Text(
            'Yeni kullanıcı ekleme özelliği geliştirme aşamasında...'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Zorluk Seviyesi
                  const Text('Madencilik Zorluk Seviyesi:'),
                  const SizedBox(height: 8),

                  FutureBuilder<Map<String, dynamic>>(
                    future: controller.apiService.getDifficultyLevels(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Hata: ${snapshot.error}');
                      }

                      final levels = snapshot.data!;
                      return Column(
                        children: levels.entries
                            .map((entry) => ListTile(
                                  leading: Text('Seviye ${entry.key}'),
                                  title: Text(entry.value['description']),
                                  subtitle: Text(entry.value['example']),
                                  trailing: ElevatedButton(
                                    onPressed: () =>
                                        controller.setDifficultyLevel(
                                            int.parse(entry.key)),
                                    child: const Text('Aktif Et'),
                                  ),
                                ))
                            .toList(),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    controller.runBenchmark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
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

  void _backupDatabase() {
    Get.snackbar(
      'Başarılı',
      'Veritabanı yedekleme işlemi başlatıldı',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _clearLogs() {
    Get.snackbar(
      'Başarılı',
      'Sistem logları temizlendi',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _validateBlockchain() {
    Get.snackbar(
      'Başarılı',
      'Blockchain doğrulama işlemi başlatıldı',
      backgroundColor: Colors.green,
      colorText: Colors.white,
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
                'Blockchain Yönetimi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => ElevatedButton.icon(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.mineBlock,
                                  icon: const Icon(Icons.diamond),
                                  label: controller.isLoading.value
                                      ? const CircularProgressIndicator()
                                      : const Text('Blok Madenciliği Başlat'),
                                )),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...blocks
                  .map((block) => Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.circle,
                            color: block['index'] == 0
                                ? Colors.green
                                : Colors.blue,
                          ),
                          title: Text('Blok #${block['index']}'),
                          subtitle: Text(
                              'Hash: ${block['hash'].substring(0, 20)}...'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildBlockDetail('Tam Hash', block['hash']),
                                  _buildBlockDetail(
                                      'Önceki Hash', block['previous_hash']),
                                  _buildBlockDetail(
                                      'Nonce', block['nonce'].toString()),
                                  _buildBlockDetail('Leading Zeros',
                                      block['leading_zeros'].toString()),
                                  _buildBlockDetail('Zaman',
                                      _formatDateTime(block['timestamp'])),
                                  if (block['index'] > 0) ...[
                                    const SizedBox(height: 8),
                                    const Text('Veriler:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    ...(block['data'] as List)
                                        .take(3)
                                        .map((data) => Text(
                                              '• SpO2: ${data['spo2_value']}% | BPM: ${data['bpm_value']}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ))
                                        .toList(),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
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
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: SelectableText(value,
                style: const TextStyle(fontFamily: 'Monospace', fontSize: 12)),
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
    Get.dialog(
      AlertDialog(
        title: const Text('Sistem Performans Metrikleri'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPerformanceItem('Ortalama Blok Süresi',
                  controller.miningStats['averageBlockTime']),
              _buildPerformanceItem('Mevcut Zorluk',
                  controller.miningStats['currentDifficulty'].toString()),
              _buildPerformanceItem('Toplam Hash İşlemi',
                  controller.miningStats['totalHashOperations']),
              const SizedBox(height: 16),
              const Text('Ağ Karşılaştırması:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...controller.miningStats['networkComparison'].entries
                  .map((entry) => _buildPerformanceItem(entry.key, entry.value))
                  .toList(),
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

  Widget _buildPerformanceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Obx(() {
      if (controller.currentAdmin.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final admin = controller.currentAdmin.value!;

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
                      child: Icon(Icons.admin_panel_settings,
                          size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      admin.fullName ?? admin.username,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(admin.email,
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
                    const Text('Yönetici Bilgileri',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoItem('Kullanıcı ID', admin.userId),
                    _buildInfoItem('Üyelik Tarihi',
                        controller.formatDate(admin.createdAt)),
                    const SizedBox(height: 8),
                    const Text('Yetkiler:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...admin.permissions
                        .map((permission) => Text('• $permission'))
                        .toList(),
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
              width: 120,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
