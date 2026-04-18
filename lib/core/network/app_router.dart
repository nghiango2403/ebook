import 'package:ebook/features/auth/presentation/screens/login_screen.dart';
import 'package:ebook/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    // Route Home
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text("TRANG CHỦ")),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginScreen()
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => RegisterScreen()
    ),
  ],
  redirect: (context, state) {
    // Logic: Nếu chưa login mà vào trang 'reading' -> redirect sang 'login'
    return null;
  },
);