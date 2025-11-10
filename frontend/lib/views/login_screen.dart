// Giriş ekranı - Tüm kullanıcı türleri için
import 'package:flutter/material.dart';
import 'package:lightmedchain/services/api_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Demo hesaplar
  final List<Map<String, String>> _demoAccounts = [
    {
      'username': 'hasta',
      'password': '123456',
      'role': 'Hasta',
      'route': '/patient'
    },
    {
      'username': 'doktor',
      'password': '123456',
      'role': 'Doktor',
      'route': '/doctor'
    },
    {
      'username': 'admin',
      'password': '123456',
      'role': 'Yönetici',
      'route': '/admin'
    },
  ];
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final apiService = Provider.of<ApiService>(context, listen: false);

        print("🔍 DEBUG - Attempting login with: ${_usernameController.text}");

        final user = await authService.login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

        print("🔍 DEBUG - Login result: $user");
        print("🔍 DEBUG - User type: ${user?.userType}");

        if (user != null) {
          // ⭐⭐ BU KODLARI SİLİN/KALDIRIN ⭐⭐
          // final token = "demo_token_${user.userId}_${DateTime.now().millisecondsSinceEpoch}";
          // await authService.saveToken(token);
          // apiService.setToken(token);

          // ⭐⭐ YERİNE SADECE BUNU EKLEYİN ⭐⭐
          // Token zaten AuthService'de kaydedildi, sadece API Service'e set edelim
          final token = await authService.getToken();
          if (token != null) {
            apiService.setToken(token);
            print("✅ DEBUG - Token set to API service from AuthService");
          }

          print("✅ DEBUG - Login successful, redirecting...");

          // Kullanıcı türüne göre yönlendirme
          switch (user.userType) {
            case 'patient':
              context.go('/patient');
              break;
            case 'doctor':
              context.go('/doctor');
              break;
            case 'admin':
              context.go('/admin');
              break;
          }
        }
      } catch (e) {
        print("❌ DEBUG - Login error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _useDemoAccount(String username, String password, String role) {
    _usernameController.text = username;
    _passwordController.text = password;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('$role demo hesabı yüklendi. Giriş yap butonuna tıklayın.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve Logo
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.computer_outlined,
                      size: 80,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LightMedChain',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hafif Blockchain Tıbbi Kayıt Sistemi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Giriş Formu
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Sisteme Giriş',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Kullanıcı Adı
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen kullanıcı adınızı girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Şifre
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen şifrenizi girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Giriş Butonu
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Giriş Yap',
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
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Demo Hesaplar
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Hesaplar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._demoAccounts.map((account) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.account_circle,
                                color: Colors.blue[600],
                              ),
                              title: Text('${account['role']} Hesabı'),
                              subtitle: Text(
                                  'Kullanıcı: ${account['username']} | Şifre: ${account['password']}'),
                              trailing: ElevatedButton(
                                onPressed: () => _useDemoAccount(
                                  account['username']!,
                                  account['password']!,
                                  account['role']!,
                                ),
                                child: const Text('Kullan'),
                              ),
                              tileColor: Colors.grey[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // Sistem Bilgisi
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sistem Özellikleri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem('🔒 Blockchain Güvenliği',
                          'Tüm tıbbi kayıtlar blockchain ile korunuyor'),
                      _buildFeatureItem('📊 Gerçek Zamanlı Veri',
                          'Oksimetre verileri anlık takip ediliyor'),
                      _buildFeatureItem('⚡ Hafif Madencilik',
                          'Leading-zero algoritması ile hızlı işlemler'),
                      _buildFeatureItem('🏥 Sleep Apnea Takibi',
                          'SpO2 ve BPM verileri ile hasta izleme'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
