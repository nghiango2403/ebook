import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  /// Lấy tất cả danh mục từ Firestore
  Future<List<CategoryModel>> getAllCategories();

  /// Lấy một danh mục cụ thể theo ID
  Future<CategoryModel?> getCategoryById(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  CategoryRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('displayOrder')
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Lỗi DataSource (GetAll): $e");
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection('categories').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return CategoryModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Lỗi DataSource (GetById): $e");
    }
  }
}