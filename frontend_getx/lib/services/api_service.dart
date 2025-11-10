// lib/services/api_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lightmedchain/models/medical_data_model.dart'; 
import 'storage_service.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'http://127.0.0.1:5000/api';
  final StorageService storageService = Get.find();

  // Headers with authentication
  Map<String, String> _getHeaders() {
    final token = storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // Auth endpoints
  // ApiService'deki login metoduna debug ekleyin:
Future<Map<String, dynamic>> login(String username, String password) async {
  try {
    print('🌐 DEBUG - API Login call: $username');
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    print('🌐 DEBUG - Response status: ${response.statusCode}');
    print('🌐 DEBUG - Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('🌐 DEBUG - Parsed data: $data');
      return data;
    } else {
      print('❌ DEBUG - Login failed with status: ${response.statusCode}');
      throw Exception('Login failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ DEBUG - API connection error: $e');
    throw Exception('API connection error: $e');
  }
}

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  // Blockchain endpoints
  Future<BlockchainStats> getBlockchainStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blockchain/status'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BlockchainStats.fromJson(data);
      } else {
        throw Exception('Failed to get blockchain status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  Future<Map<String, dynamic>> getFullChain() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blockchain/chain'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get blockchain chain: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  Future<Map<String, dynamic>> mineBlock() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/blockchain/mine'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Mining failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  // Medical data endpoints
  Future<Map<String, dynamic>> recordMedicalData({
    required String patientId,
    required double spo2Value,
    required double bpmValue,
    String deviceId = 'BT_OXIMETER_001',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medical-data/record'),
        headers: _getHeaders(),
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
        throw Exception('Data recording failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  Future<Map<String, dynamic>> getPatientMedicalData(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medical-data/patient/$patientId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get patient data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  // Oximeter endpoints
  Future<List<String>> scanOximeterDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/oximeter/scan'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['available_devices']);
      } else {
        throw Exception('Device scan failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  Future<Map<String, dynamic>> connectOximeter(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/oximeter/connect'),
        headers: _getHeaders(),
        body: json.encode({'device_id': deviceId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Device connection failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  // Mining endpoints
  Future<Map<String, dynamic>> getDifficultyLevels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mining/difficulty'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get difficulty levels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  Future<Map<String, dynamic>> setDifficultyLevel(int level) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mining/difficulty/$level'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to set difficulty level: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  Future<Map<String, dynamic>> runBenchmark() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mining/benchmark'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Benchmark failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  // System endpoints
  Future<Map<String, dynamic>> getSystemPerformance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/system/performance'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get system performance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }
}