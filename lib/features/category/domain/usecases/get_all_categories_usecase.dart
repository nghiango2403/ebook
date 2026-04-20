import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

/// Use Case lấy danh sách tất cả các danh mục giao dịch.
///
/// Dữ liệu trả về thường được sắp xếp theo [displayOrder]
/// để phục vụ việc hiển thị trên UI (Dropdown, Filter, Charts).
class GetAllCategoriesUseCase {
  final CategoryRepository _repository;

  GetAllCategoriesUseCase(this._repository);

  /// thực thi lấy danh sách danh mục.
  /// Trả về [List<CategoryEntity>] hoặc ném ra Exception nếu có lỗi.
  Future<List<CategoryEntity>> execute() async {
    try {
      return await _repository.getAllCategories();
    } catch (e) {
      throw Exception("Không thể tải danh sách danh mục: $e");
    }
  }
}