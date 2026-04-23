import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chapter_entity.dart';

class ChapterModel extends ChapterEntity {
  const ChapterModel({
    required super.id,
    required super.bookId,
    required super.title,
    required super.orderIndex,
    required super.content,
    required super.createdAt,
    super.isVip=false,
    super.price=0,
    super.isPurchased=false
  });

  /// **Chuyển đổi từ Map (Firestore) sang Model**
  factory ChapterModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ChapterModel(
      id: documentId,
      bookId: map['bookId'] ?? '',
      title: map['title'] ?? 'Chương không tiêu đề',
      orderIndex: (map['orderIndex'] as num?)?.toInt() ?? 0,
      // Nếu map không có content (khi query mục lục), trả về chuỗi rỗng
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVip: map['isVip'] ?? false,
      price: (map['price'] as num?)?.toInt() ?? 0,
      isPurchased: false,
    );
  }

  /// **Chuyển đổi sang Map để lưu trữ**
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'orderIndex': orderIndex,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVip': isVip,
      'price': price,
    };
  }
}