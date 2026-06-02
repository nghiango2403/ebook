import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/services/firebase_service.dart';
import 'src/core/theme_and_router/app_router.dart';
import 'src/core/theme_and_router/app_theme.dart';

void main() async {
  // Khởi tạo Firebase và các binding cần thiết
  await FirebaseService.init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ebook App',
      debugShowCheckedModeBanner: false,
      
      // Cấu hình Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Cấu hình Router
      routerConfig: AppRouter.router,
    );
  }
}
