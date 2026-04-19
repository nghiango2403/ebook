import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_nav_bar_painter.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final int currentIndex = navigationShell.currentIndex;

    return SizedBox(
      height: 110,
      width: size.width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 10,
            child: CustomPaint(
              size: Size(size.width, 90),
              painter: AppNavBarPainter(selectedIndex: currentIndex),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            height: 90,
            child: Row(
              children: [
                _buildNavItem(0, Icons.auto_stories_outlined, Icons.auto_stories, "Tủ truyện"),
                _buildNavItem(1, Icons.explore_outlined, Icons.explore, "Khám phá"),
                _buildNavItem(2, Icons.leaderboard_outlined, Icons.leaderboard, "Xếp hạng"),
                _buildNavItem(3, Icons.person_outline, Icons.person, "Tài khoản"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final bool isSelected = navigationShell.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => navigationShell.goBranch(index),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: isSelected ? -10 : 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF29B6F6) : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 8))]
                          : [],
                    ),
                    child: Icon(
                      isSelected ? selectedIcon : icon,
                      color: isSelected ? Colors.white : Colors.blueGrey[200],
                      size: 26,
                    ),
                  ),

                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 0 : 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.blueGrey[200],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}