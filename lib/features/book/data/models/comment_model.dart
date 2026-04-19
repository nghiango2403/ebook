import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.bookId,
    required super.userId,
    required super.userName,
    required super.userAvatar,
    required super.content,
    required super.createdAt,
    required super.likes,
  });

  /// **Chuyển đổi từ Map (Firestore) sang Model**
  factory CommentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CommentModel(
      id: documentId,
      bookId: map['bookId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Người dùng ẩn danh',
      userAvatar: map['userAvatar'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: (map['likes'] as num?)?.toInt() ?? 0,
    );
  }

  /// **Chuyển đổi từ Model sang Map để lưu lên Firestore**
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }

  /// **Hỗ trợ tạo Model từ Entity (Dùng khi người dùng bấm gửi bình luận)**
  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      bookId: entity.bookId,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      content: entity.content,
      createdAt: entity.createdAt,
      likes: entity.likes,
    );
  }
}