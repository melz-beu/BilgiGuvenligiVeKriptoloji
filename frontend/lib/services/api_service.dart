// Backend API servisleri - Flask API ile iletişim
import 'dart:convert';
import 'package:http/http.dart' as http; 
import '../models/medical_data_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000/api';
  
  final http.Client client;

  ApiService({required this.client});

  // Hata yönetimi
  void _handleError(dynamic error) {
    print('API Hatası: $error');
    throw Exception('API bağlantı hatası: $error');
  }

  // Blockchain API Methods

  /// Blockchain durumunu getirir
  Future<BlockchainStats> getBlockchainStatus() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/blockchain/status'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BlockchainStats.fromJson(data);
      } else {
        throw Exception('Blockchain durumu alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Tam blockchain verisini getirir
  Future<Map<String, dynamic>> getFullChain() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/blockchain/chain'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Blockchain verisi alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Yeni blok madenci
  Future<Map<String, dynamic>> mineBlock() async {
    try {
      final response = await client.post(Uri.parse('$baseUrl/blockchain/mine'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Madencilik başarısız: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Tıbbi Veri API Methods

  /// Tıbbi veri kaydı oluşturur
  Future<Map<String, dynamic>> recordMedicalData({
    required String patientId,
    required double spo2Value,
    required double bpmValue,
    String deviceId = 'BT_OXIMETER_001',
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/medical-data/record'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': patientId,
          'spo2_value': spo2Value,
          'bpm_value': bpmValue,
          'device_id': deviceId,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Veri kaydı başarısız: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Hastanın tıbbi verilerini getirir
Future<Map<String, dynamic>> getPatientMedicalData(String patientId) async {
  print("🔍 DEBUG - getPatientMedicalData called with patientId: $patientId");
  try {
    final response = await client.get(
      Uri.parse('$baseUrl/medical-data/patient/$patientId'),
    );
    
    print("🔍 DEBUG - Response status: ${response.statusCode}");
    print("🔍 DEBUG - Response body: ${response.body}");
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Hasta verileri alınamadı: ${response.statusCode}');
    }
  } catch (e) {
    print("❌ DEBUG - getPatientMedicalData error: $e");
    _handleError(e);
    rethrow;
  }
}

  // Oksimetre API Methods

  /// Kullanılabilir oksimetre cihazlarını tara
  Future<List<String>> scanOximeterDevices() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/oximeter/scan'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['available_devices']);
      } else {
        throw Exception('Cihaz tarama başarısız: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Oksimetre cihazına bağlan
  Future<Map<String, dynamic>> connectOximeter(String deviceId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/oximeter/connect'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'device_id': deviceId}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Cihaz bağlantısı başarısız: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Oksimetre ile veri kaydı başlat
  Future<Map<String, dynamic>> startOximeterRecording({
    required String patientId,
    required String deviceId,
    int duration = 60,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/oximeter/record'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': patientId,
          'device_id': deviceId,
          'duration': duration,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Kayıt başlatma başarısız: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Madencilik API Methods

  /// Tüm zorluk seviyelerini getirir
  Future<Map<String, dynamic>> getDifficultyLevels() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/mining/difficulty'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Zorluk seviyeleri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Zorluk seviyesini ayarlar
  Future<Map<String, dynamic>> setDifficultyLevel(int level) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/mining/difficulty/$level'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Zorluk seviyesi ayarlanamadı: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Performans benchmark testi çalıştırır
  Future<Map<String, dynamic>> runBenchmark() async {
    try {
      final response = await client.post(Uri.parse('$baseUrl/mining/benchmark'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Benchmark testi başarısız: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Sistem Yönetimi API Methods

  /// Sistem performans metriklerini getirir
  Future<Map<String, dynamic>> getSystemPerformance() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/system/performance'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Sistem performansı alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}