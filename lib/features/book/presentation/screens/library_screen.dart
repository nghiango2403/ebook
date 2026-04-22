import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/book_entity.dart';
import '../providers/library_provider.dart';
import '../widgets/book_card_vertical.dart'; // Giả sử bạn đã có widget item

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final readLibraryState = ref.read(libraryProvider.notifier);

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
        body: libraryState.when(
          data: (data) => TabBarView(
            children: [
              _buildBookList(data.bookmarked.books, (bookId) {
                readLibraryState.removeBookFromBookmarked(bookId);
              }),
              _buildBookList(data.followed.books, (bookId) {
                readLibraryState.removeBookFromFollowed(bookId);
              }),
              _buildBookList(data.history.books, (bookId) {
                // Logic xóa lịch sử nếu cần
              }),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Đã có lỗi: $err')),
        ),
      ),
    );
  }

  Widget _buildBookList(List<BookEntity> books, Function(String) onAction) {
    if (books.isEmpty) {
      return const Center(child: Text('Danh sách này đang trống'));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCardVertical(
            book: book,
            onTap: () => onAction(book.id),
          );
        },
      ),
    );
  }
}