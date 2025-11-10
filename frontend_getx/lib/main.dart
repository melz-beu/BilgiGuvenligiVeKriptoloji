// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmedchain/app/bindings/auth_binding.dart';
import 'package:lightmedchain/app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LightMedChain',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.LOGIN,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      initialBinding: AuthBinding(),
    );
  }
}