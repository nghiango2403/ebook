import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/chapter_entity.dart';
import '../../providers/chapter_provider.dart';

class ManagementChapterScreen extends ConsumerStatefulWidget {
  final String bookId;

  const ManagementChapterScreen({super.key, required this.bookId});

  @override
  ConsumerState<ManagementChapterScreen> createState() =>
      _ManagementChapterScreenState();
}

class _ManagementChapterScreenState
    extends ConsumerState<ManagementChapterScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(chapterProvider.notifier).fetchChapters(widget.bookId),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Chỉ fetch thêm khi chưa đạt giới hạn cuối và không đang load
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(chapterProvider);
      if (!state.isLoading && !state.hasReachedMax) {
        ref.read(chapterProvider.notifier).fetchChapters(widget.bookId);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm xử lý xóa chương
  void _onDeleteChapter(ChapterEntity chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa "${chapter.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // Hiển thị loading nhẹ hoặc disable nút
              final navigator = Navigator.of(context);
              await ref
                  .read(chapterProvider.notifier)
                  .deleteChapter(widget.bookId, chapter.id);
              navigator.pop();
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chapterProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Column(
          children: [
            Text(
              'Quản lý nội dung',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Danh sách chương',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Nút thêm chương mới với Style nổi bật hơn
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () => context.push(
                '/profile/mybooks/getlistchapter/${widget.bookId}/addchapter',
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Thêm mới'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                backgroundColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ChapterState state) {
    if (state.isLoading && state.chapters.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Nếu đang load và đã có data, có thể hiện loading ở cuối danh sách (đã xử lý trong ListView.builder)

    if (state.error != null && state.chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Lỗi kết nối: ${state.error}'),
            ElevatedButton(
              onPressed: () => ref
                  .read(chapterProvider.notifier)
                  .refreshChapters(widget.bookId),
              child: const Text('Tải lại trang'),
            ),
          ],
        ),
      );
    }

    if (state.chapters.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: 80, color: Colors.black12),
            SizedBox(height: 16),
            Text('Chưa có nội dung nào.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(chapterProvider.notifier).refreshChapters(widget.bookId),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: state.chapters.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.chapters.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          return _buildManagementItem(state.chapters[index]);
        },
      ),
    );
  }

  Widget _buildManagementItem(ChapterEntity chapter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${chapter.orderIndex}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
        ),
        title: Text(
          chapter.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.access_time, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              chapter.createdAt.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'edit') {
              context.push(
                '/profile/mybooks/getlistchapter/${widget.bookId}/editchapter/${chapter.id}',
              );
            } else if (value == 'delete') {
              _onDeleteChapter(chapter);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa chương', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => context.push('/mybook/${chapter.bookId}/${chapter.id}'),
      ),
    );
  }
}
