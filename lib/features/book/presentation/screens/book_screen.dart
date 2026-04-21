import 'package:ebook/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../model/book_view_model.dart';
import '../providers/book_detail_provider.dart';

class BookScreen extends ConsumerStatefulWidget {
  final String bookId;
  const BookScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final asyncBook = ref.watch(bookDetailProvider(widget.bookId));
    final theme = Theme.of(context);
  ref.listen<AsyncValue<void>>(bookInteractionProvider, (previous, next) {
  next.whenOrNull(
    error: (err, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${err.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    },
  );
});
    return Scaffold(
      body: asyncBook.when(
        data: (viewModel) => Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(viewModel, theme, context),
              _buildStickyTabBar(theme),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildIntroductionTab(viewModel, theme),
                const Center(child: Text("Tính năng bình luận đang phát triển")),
                const Center(child: Text("Danh sách chương đang cập nhật")),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(theme, viewModel),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Lỗi: $err")),
      ),
    );
  }

  Widget _buildSliverAppBar(BookViewModel viewModel, ThemeData theme, BuildContext context) {
    final book = viewModel.book;
    return SliverAppBar(
      expandedHeight: 440,
      pinned: true,
      stretch: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        book.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(book.imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Hero(
                      tag: book.id,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 25)],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(book.imageUrl),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(book.title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(book.authorName, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn("Lượt xem", book.views.toString()),
                        _buildStatColumn("Theo dõi", book.totalFollows.toString()),
                        _buildStatColumn("Lưu", book.totalBookmarks.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            viewModel.isFollowed ? Icons.favorite : Icons.favorite_border,
            color: viewModel.isFollowed ? Colors.red : Colors.white,
          ),
          onPressed: () async{
            if(ref.read(authProvider).user == null){
              context.go('/login');
            }else{
              ref.read(bookInteractionProvider.notifier).toggleFollowBook(book.id);
            }
          }
        ),
        // Nút Đánh dấu (Bookmark)
        IconButton(
          icon: Icon(
            viewModel.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: viewModel.isBookmarked ? Colors.amber : Colors.white,
          ),
          onPressed: () async{
            if(ref.read(authProvider).user == null){
              context.go('/login');
            }else{
              ref.read(bookInteractionProvider.notifier).toggleBookmark(book.id);
            }
          }
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStickyTabBar(ThemeData theme) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Giới thiệu"),
            Tab(text: "Bình luận"),
            Tab(text: "Chương"),
          ],
        ),
      ),
    );
  }

  // Nội dung Tab Giới thiệu
  Widget _buildIntroductionTab(BookViewModel viewModel, ThemeData theme) {
    final book = viewModel.book;
    final category = viewModel.category;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mô tả nội dung", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            book.description,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 24),
          _buildDetailRow("Ngày đăng", "20/04/2026"),
          _buildDetailRow("Trạng thái", book.status.label.toString()),
          if (category != null)
            _buildDetailRow("Thể loại", category.name, color: category.color)
          else
            _buildDetailRow("Thể loại", "Đang cập nhật"),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color?.withValues(alpha: 0.1) ?? Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, BookViewModel viewModel) {
    final book = viewModel.book;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: Icon(
                viewModel.isFollowed ? Icons.favorite : Icons.favorite_border,
                color: viewModel.isFollowed ? Colors.red : Colors.white,
              ),
              onPressed: () async{
                if(ref.read(authProvider).user == null){
                  context.go('/login');
                }else{
                  ref.read(bookInteractionProvider.notifier).toggleFollowBook(book.id);
                }
              }
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: Icon(
                viewModel.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: viewModel.isBookmarked ? Colors.amber : theme.colorScheme.primary,
              ),
              onPressed: () async{
                if(ref.read(authProvider).user == null){
                  context.go('/login');
                }else{
                  ref.read(bookInteractionProvider.notifier).toggleBookmark(book.id);
                }
              }
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {},
              child: const Text("BẮT ĐẦU ĐỌC", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}