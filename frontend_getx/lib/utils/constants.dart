// lib/utils/constants.dart
class AppConstants {
  static const String appName = 'LightMedChain';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl = 'http://127.0.0.1:5000/api';
  
  static const List<String> userTypes = ['patient', 'doctor', 'admin'];
  
  static const Map<String, String> ahiCategories = {
    'Normal': '0-5',
    'Mild': '5-15', 
    'Moderate': '15-30',
    'Severe': '30+'
  };
  
  static const Map<int, String> difficultyLevels = {
    1: 'Çok Kolay',
    2: 'Kolay',
    3: 'Orta',
    4: 'Zor', 
    5: 'Çok Zor'
  };
}