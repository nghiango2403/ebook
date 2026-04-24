import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/chapter_provider.dart';

class AddEditChapterScreen extends ConsumerStatefulWidget {
  final String bookId;
  final String? chapterId;

  const AddEditChapterScreen({super.key, required this.bookId, this.chapterId});

  @override
  ConsumerState<AddEditChapterScreen> createState() =>
      _AddEditChapterScreenState();
}

class _AddEditChapterScreenState extends ConsumerState<AddEditChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _orderIndexController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    if (widget.chapterId != null) {
      Future.microtask(() {
        final state = ref.read(chapterProvider);
        try {
          final chapter = state.chapters.firstWhere(
            (c) => c.id == widget.chapterId,
          );
          _titleController.text = chapter.title;
          _contentController.text = chapter.content;
          _orderIndexController.text = chapter.orderIndex.toString();
          _priceController.text = chapter.price.toString();
          setState(() {
            _isVip = chapter.isVip;
          });
        } catch (e) {
          // Xử lý lỗi
        }
      });
    } else {
      // Tự động gợi ý orderIndex cho chương mới
      Future.microtask(() {
        final state = ref.read(chapterProvider);
        if (state.chapters.isNotEmpty) {
          final maxIndex = state.chapters
              .map((e) => e.orderIndex)
              .reduce((a, b) => a > b ? a : b);
          _orderIndexController.text = (maxIndex + 1).toString();
        } else {
          _orderIndexController.text = '1';
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _orderIndexController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(chapterProvider.notifier);
    final orderIndex = int.tryParse(_orderIndexController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (widget.chapterId == null) {
      await notifier.addChapter(
        widget.bookId,
        _titleController.text.trim(),
        _contentController.text.trim(),
        orderIndex,
        _isVip,
        price,
      );
    } else {
      await notifier.updateChapter(
        widget.bookId,
        widget.chapterId!,
        _titleController.text.trim(),
        _contentController.text.trim(),
        orderIndex,
        _isVip,
        price,
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(chapterProvider).isLoading;
    final isEdit = widget.chapterId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa chương' : 'Thêm chương mới'),
        actions: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              style: TextButton.styleFrom(
                // Màu nền nhẹ giúp nút nổi bật hơn chữ bình thường
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                foregroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Bo tròn dạng Stadium
                ),
              ),
              child: const Text(
                'LƯU',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _orderIndexController,
                    decoration: const InputDecoration(
                      labelText: 'STT',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Bắt buộc' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề chương',
                      hintText: 'Ví dụ: Sự khởi đầu',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Vui lòng nhập tiêu đề'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Chương VIP (Cần mua)'),
              value: _isVip,
              onChanged: (val) => setState(() => _isVip = val),
              contentPadding: EdgeInsets.zero,
            ),
            if (_isVip)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Giá bán (Xu)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      (_isVip && (value == null || value.isEmpty))
                      ? 'Vui lòng nhập giá'
                      : null,
                ),
              ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              maxLines: 20,
              minLines: 10,
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Vui lòng nhập nội dung'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
