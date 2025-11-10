// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Helpers {
  static void showSnackBar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Hata' : 'Başarılı',
      message,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
    );
  }

  static String formatDateTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  static String calculateAge(String? birthDate) {
    if (birthDate == null) return '0';
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return '0';
    }
  }

  static Color getAhiColor(String ahiIndex) {
    switch (ahiIndex) {
      case 'Severe': return Colors.red;
      case 'Moderate': return Colors.orange;
      case 'Mild': return Colors.yellow;
      default: return Colors.green;
    }
  }
}