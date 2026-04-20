import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/book_status.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    required super.description,
    required super.authorId,
    required super.authorName,
    required super.imageUrl,
    required super.categoryId,
    required super.views,
    required super.quantity,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.viewsDay,
    required super.viewsWeek,
    required super.totalBookmarks,
    required super.totalFollows,
  });

  /// **Chuyển đổi từ Map (Firestore) sang Model**
  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      authorId: map['authorId'] ?? 'Ẩn danh',
      authorName: map['authorName'] ?? 'Ẩn danh',
      imageUrl: map['imageUrl'] ?? '',
      categoryId: map['categoryId'] ?? 'Chưa phân loại',
      views: (map['views'] as num?)?.toInt() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      status: BookStatus.fromString(map['status'] ?? ''),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Bổ sung các trường chỉ số mới
      viewsDay: (map['viewsDay'] as num?)?.toInt() ?? 0,
      viewsWeek: (map['viewsWeek'] as num?)?.toInt() ?? 0,
      totalBookmarks: (map['totalBookmarks'] as num?)?.toInt() ?? 0,
      totalFollows: (map['totalFollows'] as num?)?.toInt() ?? 0,
    );
  }

  /// **Chuyển đổi từ Model sang Map để đẩy lên Firestore**
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'views': views,
      'quantity': quantity,
      'status': status.label,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'viewsDay': viewsDay,
      'viewsWeek': viewsWeek,
      'totalBookmarks': totalBookmarks,
      'totalFollows': totalFollows,
    };
  }

  /// **Hỗ trợ tạo Model từ Entity (Tiện dụng khi làm tầng Repository)**
  factory BookModel.fromEntity(BookEntity entity) {
    return BookModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      authorId: entity.authorId,
      authorName: entity.authorName,
      imageUrl: entity.imageUrl,
      categoryId: entity.categoryId,
      views: entity.views,
      quantity: entity.quantity,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      viewsDay: entity.viewsDay,
      viewsWeek: entity.viewsWeek,
      totalBookmarks: entity.totalBookmarks,
      totalFollows: entity.totalFollows,
    );
  }
}