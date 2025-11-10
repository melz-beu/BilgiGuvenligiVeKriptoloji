// Ana uygulama dosyası
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'views/login_screen.dart';
import 'views/patient_dashboard.dart';
import 'views/doctor_dashboard.dart';
import 'views/admin_dashboard.dart';
import 'package:http/http.dart' as http;

void main() {
  // Backend testi - uygulama başlarken çalışır
 /* WidgetsFlutterBinding.ensureInitialized();
  print('🔍 Backend testi başlatılıyor...');
  ApiService(client: http.Client()).getBlockchainStatus().then((status) {
    print('✅ BACKEND BAĞLANTISI BAŞARILI!');
    print('📊 Blok Sayısı: ${status.totalBlocks}');
  }).catchError((e) {
    print('❌ BACKEND HATASI: $e');
  });*/

    // Token debug
  WidgetsFlutterBinding.ensureInitialized();
 AuthService().clearAllData();
  runApp(MyApp());
}
void _debugTokenCheck() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  print('🎯 DEBUG - CURRENT TOKEN IN STORAGE: $token');
  if (token != null) {
    if (token.startsWith('eyJ')) {
      print('✅ DEBUG - Storage has REAL JWT token');
    } else {
      print('❌ DEBUG - Storage has DEMO token: $token');
    }
  }
}
 
class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Router configuration
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/patient',
        builder: (context, state) => const PatientDashboard(),
      ),
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorDashboard(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(client: http.Client()),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp.router(
        title: 'LightMedChain',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}