import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/chapter_entity.dart';
import '../../providers/chapter_provider.dart';

class ChapterListScreen extends ConsumerStatefulWidget {
  final String bookId;

  const ChapterListScreen({super.key, required this.bookId});

  @override
  ConsumerState<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends ConsumerState<ChapterListScreen> {
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(chapterProvider.notifier).fetchChapters(widget.bookId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chapterProvider);

    return Scaffold(backgroundColor: Colors.grey[50], body: _buildBody(state));
  }

  Widget _buildBody(ChapterState state) {
    if (state.isLoading && state.chapters.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.error != null && state.chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: ${state.error}'),
            TextButton(
              onPressed: () => ref
                  .read(chapterProvider.notifier)
                  .refreshChapters(widget.bookId),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state.chapters.isEmpty) {
      return const Center(child: Text('Chưa có chương nào được đăng.'));
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(chapterProvider.notifier).refreshChapters(widget.bookId),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: state.chapters.length + (state.hasReachedMax ? 0 : 1),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= state.chapters.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
            );
          }
          return _buildChapterItem(state.chapters[index]);
        },
      ),
    );
  }

  Widget _buildChapterItem(ChapterEntity chapter) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Text(
            '${chapter.orderIndex}',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          chapter.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Cập nhật: ${chapter.createdAt}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => context.push('/book/${chapter.bookId}/${chapter.id}'),
      ),
    );
  }
}
