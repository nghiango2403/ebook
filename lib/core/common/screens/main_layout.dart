import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  /// Đây là đối tượng điều khiển luồng của GoRouter StatefulShellRoute.
  /// Nó chứa trạng thái của các nhánh (branches) và phương thức để chuyển đổi giữa chúng.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,

      // Sử dụng Widget Bottom Bar riêng biệt mà Nghĩa đã tách ra.
      bottomNavigationBar: AppBottomNavigationBar(
        navigationShell: navigationShell,
      ),
    );
  }
}