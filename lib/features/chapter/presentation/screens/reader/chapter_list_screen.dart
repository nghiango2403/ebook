import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../history/presentation/providers/reading_history_provider.dart';
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
  bool _hasScrolledToHistory = false;

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

  void _scrollToHistory(String? chapterId, List<ChapterEntity> chapters) {
    if (_hasScrolledToHistory || chapterId == null || chapters.isEmpty) return;

    final index = chapters.indexWhere((c) => c.id == chapterId);
    if (index != -1) {
      _hasScrolledToHistory = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          // Ước tính chiều cao mỗi item (Card + Separator) khoảng 90-100
          _scrollController.animateTo(
            index * 92.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      });
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
    final historyState = ref.watch(readingHistoryProvider);

    // Lấy chapterId đang đọc từ lịch sử
    final currentChapterId = historyState.histories
        .where((h) => h.bookId == widget.bookId)
        .firstOrNull
        ?.chapterId;

    // Tự động cuộn đến chương đang đọc khi dữ liệu tải xong
    if (state.chapters.isNotEmpty && currentChapterId != null) {
      _scrollToHistory(currentChapterId, state.chapters);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _buildBody(state, currentChapterId),
    );
  }

  Widget _buildBody(ChapterState state, String? currentChapterId) {
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
          final chapter = state.chapters[index];
          return _buildChapterItem(chapter, chapter.id == currentChapterId);
        },
      ),
    );
  }

  Widget _buildChapterItem(ChapterEntity chapter, bool isCurrent) {
    final theme = Theme.of(context);
    return Card(
      elevation: isCurrent ? 2 : 0.5,
      shadowColor: isCurrent
          ? theme.colorScheme.primary.withValues(alpha: 0.3)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      color: isCurrent
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
          : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isCurrent
              ? theme.colorScheme.primary
              : Colors.blue.shade50,
          child: Text(
            '${chapter.orderIndex}',
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          chapter.title,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: isCurrent ? theme.colorScheme.primary : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Cập nhật: ${chapter.createdAt}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isCurrent ? theme.colorScheme.primary : Colors.grey,
        ),
        onTap: () => context.push('/book/${chapter.bookId}/${chapter.id}'),
      ),
    );
  }
}
