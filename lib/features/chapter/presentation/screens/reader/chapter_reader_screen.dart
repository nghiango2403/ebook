import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/chapter_provider.dart';

class ChapterReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  final String chapterId;

  const ChapterReaderScreen({
    super.key,
    required this.bookId,
    required this.chapterId,
  });

  @override
  ConsumerState<ChapterReaderScreen> createState() =>
      _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  double _fontSize = 18.0;
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  void _loadChapter() {
    Future.microtask(
      () => ref
          .read(chapterProvider.notifier)
          .loadChapterDetail(widget.bookId, widget.chapterId),
    );
  }

  void _toggleTheme() => setState(() => _isDarkTheme = !_isDarkTheme);

  void _increaseFontSize() =>
      setState(() => _fontSize = (_fontSize < 30) ? _fontSize + 2 : _fontSize);

  void _decreaseFontSize() =>
      setState(() => _fontSize = (_fontSize > 12) ? _fontSize - 2 : _fontSize);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chapterProvider);
    final chapter = state.currentChapter;

    return Scaffold(
      backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: _isDarkTheme ? Colors.grey[900] : Colors.white,
        foregroundColor: _isDarkTheme ? Colors.white : Colors.black,
        elevation: 0.5,
        title: Text(
          chapter?.title ?? 'Đang tải...',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _buildBody(state),
      bottomNavigationBar: _buildBottomNav(state),
    );
  }

  Widget _buildBody(ChapterState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadChapter,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final chapter = state.currentChapter;
    if (chapter == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapter.title,
            style: GoogleFonts.merriweather(
              fontSize: _fontSize + 6,
              fontWeight: FontWeight.bold,
              color: _isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            chapter.content,
            style: GoogleFonts.merriweather(
              fontSize: _fontSize,
              height: 1.8,
              color: _isDarkTheme ? Colors.grey[300] : Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomNav(ChapterState state) {
    final chapters = state.chapters;
    final currentIndex = chapters.indexWhere((c) => c.id == widget.chapterId);

    return BottomAppBar(
      color: _isDarkTheme ? Colors.grey[850] : Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: currentIndex > 0
                ? () => _navigateToChapter(chapters[currentIndex - 1].id)
                : null,
          ),
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.list),
            label: const Text('Mục lục'),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: currentIndex < chapters.length - 1
                ? () => _navigateToChapter(chapters[currentIndex + 1].id)
                : null,
          ),
        ],
      ),
    );
  }

  void _navigateToChapter(String chapterId) {
    context.pushReplacement('/book/${widget.bookId}/$chapterId');
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cài đặt đọc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                title: const Text('Chế độ tối'),
                trailing: Switch(
                  value: _isDarkTheme,
                  onChanged: (val) {
                    _toggleTheme();
                    setModalState(() {});
                  },
                ),
              ),
              ListTile(
                title: const Text('Cỡ chữ'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        _decreaseFontSize();
                        setModalState(() {});
                      },
                    ),
                    Text(
                      _fontSize.toInt().toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _increaseFontSize();
                        setModalState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
