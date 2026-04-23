import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_provider.dart';
import '../widgets/book_horizontal_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(homeProvider.notifier).fetchHomeData();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Chào bạn 👋", style: TextStyle(fontSize: 16)),
                      const Text(
                        "Hôm nay đọc gì nào?",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm sách...",
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Nội dung sách
              if (homeState.isLoading && homeState.recentlyUpdated.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (homeState.error != null &&
                  homeState.recentlyUpdated.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text("Đã có lỗi xảy ra: ${homeState.error}"),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: BookHorizontalList(
                    title: "📚 Vừa cập nhật",
                    books: homeState.recentlyUpdated,
                  ),
                ),
                SliverToBoxAdapter(
                  child: BookHorizontalList(
                    title: "✨ Truyện mới đăng",
                    books: homeState.newlyUploaded,
                  ),
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
            ],
          ),
        ),
      ),
    );
  }
}
