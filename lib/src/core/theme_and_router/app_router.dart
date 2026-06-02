import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'scaffold_with_nav_bar.dart';

/// [Summary]: Quản lý định tuyến (Routing) cho toàn bộ ứng dụng.
/// Sử dụng StatefulShellRoute để cấu hình BottomNavigationBar dùng chung.
class AppRouter {
  // Route Paths
  static const String root = '/';
  static const String library = '/library';
  static const String profile = '/profile';
  static const String login = '/login';

  // Khóa điều hướng cho các Navigator riêng biệt
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// [Summary]: Cấu hình GoRouter với StatefulShellRoute.
  static final GoRouter router = GoRouter(
    initialLocation: root,
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Điều hướng chính chứa BottomNavigationBar dùng chung
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Trang chủ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: root,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Home Screen')),
                ),
              ),
            ],
          ),
          // Tab 2: Thư viện sách
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: library,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Library Screen')),
                ),
              ),
            ],
          ),
          // Tab 3: Hồ sơ người dùng
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Profile Screen')),
                ),
              ),
            ],
          ),
        ],
      ),

      // Các route không có BottomNavigationBar (ví dụ: Login)
      // Sử dụng parentNavigatorKey để hiển thị đè lên thanh điều hướng
      GoRoute(
        path: login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
