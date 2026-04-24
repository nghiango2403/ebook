import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../history/domain/entities/reading_history_entity.dart';
import '../../../history/presentation/providers/reading_history_provider.dart';
import '../providers/book_usecase_providers.dart';
import '../providers/library_provider.dart';
import '../widgets/book_card_vertical.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  void _refreshAll() {
    final userId = ref.read(authProvider).user?.uid;
    ref.read(libraryProvider.notifier).initLibrary();
    if (userId != null) {
      ref.read(readingHistoryProvider.notifier).fetchReadingHistories(userId, isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final authState = ref.watch(authProvider);
    final userId = authState.user?.uid ?? "";

    ref.listen(authProvider, (previous, next) {
      if (previous?.user == null && next.user != null) {
        _refreshAll();
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thư viện của tôi', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Đánh dấu'),
              Tab(text: 'Theo dõi'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Đánh dấu
            _buildBookList(
              isLoading: libraryState.isLoading,
              error: libraryState.error,
              books: libraryState.bookmarked,
              hasReachedMax: libraryState.hasReachedMaxBookmarked,
              onLoadMore: () => ref.read(libraryProvider.notifier).fetchMoreBookmarked(),
              onRemove: (id) => ref.read(libraryProvider.notifier).removeBookFromBookmarked(id),
            ),
            // Tab Theo dõi
            _buildBookList(
              isLoading: libraryState.isLoading,
              error: libraryState.error,
              books: libraryState.followed,
              hasReachedMax: libraryState.hasReachedMaxFollowed,
              onLoadMore: () => ref.read(libraryProvider.notifier).fetchMoreFollowed(),
              onRemove: (id) => ref.read(libraryProvider.notifier).removeBookFromFollowed(id),
            ),
            // Tab Lịch sử
            _HistoryTab(userId: userId),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList({
    required bool isLoading,
    required String? error,
    required List<dynamic> books,
    required bool hasReachedMax,
    required VoidCallback onLoadMore,
    required Function(String) onRemove,
  }) {
    if (isLoading && books.isEmpty) return const Center(child: CircularProgressIndicator());
    if (error != null && books.isEmpty) return Center(child: Text(error));
    if (books.isEmpty) return const Center(child: Text('Danh sách trống'));

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 && !hasReachedMax && !isLoading) {
          onLoadMore();
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async => ref.read(libraryProvider.notifier).initLibrary(),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: books.length + (hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= books.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            return BookCardVertical(
              book: books[index],
              onTap: () => onRemove(books[index].id),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final String userId;
  const _HistoryTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(readingHistoryProvider);

    if (historyState.isLoading && historyState.histories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (historyState.histories.isEmpty) {
      return const Center(child: Text('Bạn chưa đọc truyện nào'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 && 
            !historyState.hasReachedMax && !historyState.isLoading) {
          ref.read(readingHistoryProvider.notifier).fetchReadingHistories(userId);
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async => ref.read(readingHistoryProvider.notifier).fetchReadingHistories(userId, isRefresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: historyState.histories.length + (historyState.hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= historyState.histories.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }
            final history = historyState.histories[index];
            return _HistoryBookCard(history: history, userId: userId);
          },
        ),
      ),
    );
  }
}

class _HistoryBookCard extends ConsumerWidget {
  final ReadingHistoryEntity history;
  final String userId;
  const _HistoryBookCard({required this.history, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailProvider(history.bookId));

    return bookAsync.when(
      data: (result) => result.fold(
        (failure) => ListTile(title: Text('Lỗi: ${history.bookId}')),
        (book) => BookCardVertical(
          book: book,
          onTap: () {
            ref
                .read(readingHistoryProvider.notifier)
                .deleteHistory(history.bookId, history.chapterId, userId);
          },
        ),
      ),
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (err, stack) => ListTile(title: Text('Lỗi tải truyện')),
    );
  }
}
