import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// Use Case lấy thông tin chi tiết của một danh mục theo ID.
///
/// Thường dùng để ánh xạ thông tin từ Transaction sang Category
/// nhằm hiển thị tên và màu sắc danh mục trên UI.
class GetCategoryByIdUseCase {
  final CategoryRepository _repository;

  GetCategoryByIdUseCase(this._repository);

  /// Thực thi tìm kiếm danh mục.
  /// Trả về [CategoryEntity] nếu tìm thấy, hoặc [null] nếu không tồn tại.
  Future<CategoryEntity?> execute(String id) async {
    try {;
      if (id.isEmpty) return null;
      return await _repository.getCategoryById(id);
    } catch (e) {
      throw Exception("Lỗi khi truy vấn danh mục $id: $e");
    }
  }
}