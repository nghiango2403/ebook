import 'dart:ui';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    required super.color,
    required super.displayOrder,
  });

  /// Chuyển đổi từ JSON (Firestore) sang Model
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(int.parse(json['color'] as String, radix: 16)),
      displayOrder: json['displayOrder'] as int,
    );
  }

  /// Chuyển đổi từ Model sang JSON để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32().toString(),
      'display_order': displayOrder,
    };
  }

  /// Chuyển đổi nhanh sang Entity
  CategoryEntity toEntity() => this;
}