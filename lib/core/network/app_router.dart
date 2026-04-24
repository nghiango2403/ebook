import 'package:ebook/features/auth/presentation/screens/login_screen.dart';
import 'package:ebook/features/auth/presentation/screens/register_screen.dart';
import 'package:ebook/features/book/presentation/screens/home_screen.dart';
import 'package:ebook/features/book/presentation/screens/my_books/add_book_screen.dart';
import 'package:ebook/features/book/presentation/screens/my_books/edit_book_screen.dart';
import 'package:ebook/features/book/presentation/screens/my_books/my_books_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/book/presentation/screens/book_screen.dart';
import '../../features/book/presentation/screens/library_screen.dart';
import '../../features/chapter/presentation/screens/management/add_edit_chapter_screen.dart';
import '../../features/chapter/presentation/screens/management/management_chapter_screen.dart';
import '../../features/chapter/presentation/screens/reader/chapter_reader_screen.dart';
import '../../features/user_profile/presentation/screens/user_profile_screen.dart';
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
              builder: (context, state) => LibraryScreen(),
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
              builder: (context, state) =>
                  const Center(child: Text("XẾP HẠNG")),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => UserProfileScreen(),
              routes: [
                GoRoute(
                  path: '/mybooks',
                  name: 'mybooks',
                  builder: (context, state) => MyBooksScreen(),
                  routes: [
                    GoRoute(
                      path: 'addbook',
                      name: 'addbook',
                      builder: (context, state) => AddBookScreen(),
                    ),
                    GoRoute(
                      path: 'editbook/:bookId',
                      name: 'editbook',
                      builder: (context, state) {
                        final id = state.pathParameters['bookId']!;
                        return EditBookScreen(bookId: id);
                      },
                    ),
                    GoRoute(
                      path: 'getlistchapter/:bookId',
                      name: 'getlistchapter',
                      builder: (context, state) {
                        final id = state.pathParameters['bookId']!;
                        return ManagementChapterScreen(bookId: id);
                      },
                      routes: [
                        GoRoute(
                          path: 'addchapter',
                          name: 'addchapter',
                          builder: (context, state) {
                            final bookId = state.pathParameters['bookId']!;
                            return AddEditChapterScreen(bookId: bookId);
                          },
                        ),
                        GoRoute(
                          path: 'editchapter/:chapterId',
                          name: 'editchapter',
                          builder: (context, state) {
                            final bookId = state.pathParameters['bookId']!;
                            final chapterId =
                                state.pathParameters['chapterId']!;
                            return AddEditChapterScreen(
                              bookId: bookId,
                              chapterId: chapterId,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
      },
      routes: [
        GoRoute(
          path: ':chapterId',
          builder: (context, state) {
            final bookId = state.pathParameters['bookId']!;
            final chapterId = state.pathParameters['chapterId']!;
            return ChapterReaderScreen(bookId: bookId, chapterId: chapterId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => RegisterScreen(),
    ),
  ],
  redirect: (context, state) {
    // Logic: Nếu chưa login mà vào trang 'reading' -> redirect sang 'login'
    return null;
  },
);
