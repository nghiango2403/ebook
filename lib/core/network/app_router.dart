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
      builder: (context, state) => const Scaffold(
        backgroundColor: Colors.yellow,
        body: Center(child: Text("TRANG LOGIN")),
      ),
    ),
  ],
  redirect: (context, state) {
    // Logic: Nếu chưa login mà vào trang 'reading' -> redirect sang 'login'
    return null;
  },
);