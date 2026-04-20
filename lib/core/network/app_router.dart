import 'package:ebook/features/auth/presentation/screens/login_screen.dart';
import 'package:ebook/features/auth/presentation/screens/register_screen.dart';
import 'package:ebook/features/book/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/book/presentation/screens/book_screen.dart';
import '../common/screens/main_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const Center(child: Text("TỦ TRUYỆN")),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              name: 'explore',
              builder: (context, state) => HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ranking',
              name: 'ranking',
              builder: (context, state) => const Center(child: Text("XẾP HẠNG")),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const Center(child: Text("Tài khoản")),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/book/:bookId',
      builder: (context, state) {
        final id = state.pathParameters['bookId']!;
        return BookScreen(bookId: id);
      },),
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