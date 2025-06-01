import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_app/app/data/database_service.dart';
import 'package:notes_app/app/routes/app_pages.dart';
import 'package:notes_app/app/theme/app_theme.dart';
import 'package:notes_app/app/theme/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await initServices();
  
  runApp(const MyApp());
}

Future<void> initServices() async {
  
  await Get.putAsync(() => ThemeService().init());
  
  
  await Get.putAsync(() => DatabaseService().init());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeService.to.theme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
