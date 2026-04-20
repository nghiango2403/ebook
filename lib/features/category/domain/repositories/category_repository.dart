import '../entities/category_entity.dart';

abstract class CategoryRepository {
  /// Lấy tất cả danh mục, sắp xếp theo [displayOrder]
  Future<List<CategoryEntity>> getAllCategories();

  /// Lấy chi tiết một danh mục dựa trên ID
  Future<CategoryEntity?> getCategoryById(String id);
}