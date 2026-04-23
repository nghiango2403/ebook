import 'package:ebook/features/book/domain/entities/book_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../category/presentation/providers/category_provider.dart';
import '../../providers/book_provider.dart';

class EditBookScreen extends ConsumerStatefulWidget {
  final String bookId;

  const EditBookScreen({super.key, required this.bookId});

  @override
  ConsumerState<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends ConsumerState<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _authorNameController;
  late TextEditingController _imgUrlController;

  String? _selectedCategoryId;
  BookEntity? _originalBook;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _authorNameController = TextEditingController();
    _imgUrlController = TextEditingController();

    Future.microtask(() async {
      await ref.read(categoryProvider.notifier).fetchAllCategories();
      await ref.read(bookProvider.notifier).fetchMyBookById(widget.bookId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _authorNameController.dispose();
    _imgUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookProvider);
    final categoryState = ref.watch(categoryProvider);

    // Lắng nghe để cập nhật dữ liệu khi load xong
    ref.listen(bookProvider, (previous, next) {
      if (next.selectedBook != null && next.selectedBook!.id == widget.bookId) {
        if (_originalBook == null) {
          _populateData(next.selectedBook!);
        }
      }
    });

    // Lắng nghe categories để đảm bảo dropdown có dữ liệu
    ref.listen(categoryProvider, (previous, next) {
      if (next.categories.isNotEmpty &&
          _selectedCategoryId == null &&
          _originalBook != null) {
        setState(() {
          _selectedCategoryId = _originalBook!.categoryId;
        });
      }
    });

    final bool isInitialLoading =
        (bookState.isLoading || categoryState.isLoading) &&
        _originalBook == null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chỉnh sửa sách',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: bookState.isLoading ? null : _submitForm,
            child: Text(
              'Lưu',
              style: TextStyle(
                color: Colors.indigo[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: true,
      ),
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagePicker(),
                        const SizedBox(height: 32),
                        _buildLabel('Tên sách'),
                        _buildTextField(
                          _titleController,
                          'Ví dụ: Đắc Nhân Tâm',
                          Icons.book_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Tác giả'),
                        _buildTextField(
                          _authorNameController,
                          'Tên tác giả',
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Thể loại'),
                        _buildCategoryDropdown(categoryState),
                        const SizedBox(height: 20),
                        _buildLabel('Mô tả'),
                        _buildTextField(
                          _descController,
                          'Viết một chút về cuốn sách của bạn...',
                          Icons.notes,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: _buildSubmitButton(bookState.isLoading),
                ),
              ],
            ),
    );
  }

  void _populateData(BookEntity book) {
    setState(() {
      _originalBook = book;
      _titleController.text = book.title;
      _descController.text = book.description;
      _authorNameController.text = book.authorName;
      _imgUrlController.text = book.imageUrl;
      _selectedCategoryId = book.categoryId;
    });
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: () => _showImageUrlDialog(),
        child: Container(
          height: 220,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            image: _imgUrlController.text.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(_imgUrlController.text),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _imgUrlController.text.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Thêm ảnh bìa',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.indigo[400], size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Trường này là bắt buộc' : null,
        onChanged: (v) {
          if (controller == _imgUrlController) setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(CategoryState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategoryId,
        hint: Text('Chọn thể loại', style: TextStyle(color: Colors.grey[400])),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.category_outlined, color: Colors.indigo),
        ),
        items: state.categories.map((cat) {
          return DropdownMenuItem(value: cat.id, child: Text(cat.name));
        }).toList(),
        onChanged: (val) => setState(() => _selectedCategoryId = val),
        validator: (val) => val == null ? 'Vui lòng chọn thể loại' : null,
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Cập nhật thay đổi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _showImageUrlDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Link ảnh bìa'),
        content: TextField(
          controller: _imgUrlController,
          decoration: const InputDecoration(hintText: 'Nhập URL hình ảnh'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Xong'),
          ),
        ],
      ),
    ).then((_) => setState(() {}));
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _originalBook != null) {
      final updatedBook = BookEntity(
        id: _originalBook!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: _imgUrlController.text.trim(),
        categoryId: _selectedCategoryId!,
        authorName: _authorNameController.text.trim(),
        authorId: _originalBook!.authorId,
        views: _originalBook!.views,
        quantity: _originalBook!.quantity,
        status: _originalBook!.status,
        createdAt: _originalBook!.createdAt,
        updatedAt: DateTime.now(),
        viewsDay: _originalBook!.viewsDay,
        viewsWeek: _originalBook!.viewsWeek,
        totalBookmarks: _originalBook!.totalBookmarks,
        totalFollows: _originalBook!.totalFollows,
        isHidden: _originalBook!.isHidden,
      );

      ref.read(bookProvider.notifier).updateBook(updatedBook).then((_) {
        if (ref.read(bookProvider).error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật sách thành công!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ref.read(bookProvider).error!)),
          );
        }
      });
    }
  }
}
