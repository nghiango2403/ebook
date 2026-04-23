import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/book_entity.dart';
import '../../providers/book_provider.dart';

class MyBooksScreen extends ConsumerStatefulWidget {
  const MyBooksScreen({super.key});

  @override
  ConsumerState<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends ConsumerState<MyBooksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Gọi dữ liệu ngay khi vào màn hình
    Future.microtask(() => ref.read(bookProvider.notifier).fetchMyBooks());

    // Lắng nghe sự kiện cuộn để load more
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(bookProvider.notifier).fetchMyBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tủ sách của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_outlined),
            onPressed: () => context.push('/profile/mybooks/addbook'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(bookProvider.notifier).refreshMyBooks(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(BookState state) {
    if (state.isLoading && state.myBooks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.myBooks.isEmpty) {
      return Center(child: Text('Lỗi: ${state.error}'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bookProvider.notifier).refreshMyBooks(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.myBooks.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.myBooks.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return _buildBookItem(state.myBooks[index]);
        },
      ),
    );
  }

  Widget _buildBookItem(BookEntity book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            book.imageUrl,
            width: 60,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.book),
            ),
          ),
        ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              book.authorName,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildStatusChip(book),
          ],
        ),
        trailing: _buildPopupMenu(book),
      ),
    );
  }

  Widget _buildStatusChip(BookEntity book) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: book.isHidden ? Colors.grey[200] : Colors.green[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        book.isHidden ? "Đang ẩn" : book.status.label,
        style: TextStyle(
          fontSize: 12,
          color: book.isHidden ? Colors.grey[600] : Colors.green[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BookEntity book) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleAction(value, book),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
        PopupMenuItem(
          value: book.isHidden ? 'unhide' : 'hide',
          child: Text(book.isHidden ? 'Hiện sách' : 'Ẩn sách'),
        ),
        const PopupMenuItem(value: 'status', child: Text('Đổi trạng thái')),
      ],
    );
  }

  void _handleAction(String action, BookEntity book) {
    final notifier = ref.read(bookProvider.notifier);
    switch (action) {
      case 'hide':
        notifier.hideBook(book.id);
        break;
      case 'unhide':
        notifier.unHideBook(book.id);
        break;
      case 'edit':
        // Điều hướng sang màn hình update
        break;
    }
  }
}
