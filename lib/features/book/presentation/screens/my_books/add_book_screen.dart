import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../category/presentation/providers/category_provider.dart';
import '../../providers/book_provider.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _imgUrlController = TextEditingController();

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Fetch categories when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).fetchAllCategories();
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
          'Đăng sách mới',
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
              'Đăng',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  const SizedBox(height: 100), // Khoảng trống cho nút submit
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
        onTap: () {
          // Hiện dialog nhập URL ảnh (tạm thời) hoặc chọn từ gallery
          _showImageUrlDialog();
        },
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
    if (_formKey.currentState!.validate()) {
      ref
          .read(bookProvider.notifier)
          .addBook(
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            imageUrl: _imgUrlController.text.trim(),
            categoryId: _selectedCategoryId!,
            authorName: _authorNameController.text.trim(),
          )
          .then((_) {
            if (ref.read(bookProvider).error == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm sách thành công!')),
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
