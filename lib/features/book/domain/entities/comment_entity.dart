import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String bookId;
  final String userId;      // ID người bình luận
  final String userName;    // Tên hiển thị (để tránh join bảng nhiều)
  final String userAvatar;
  final String content;
  final DateTime createdAt;
  final int likes;          // Lượt thích bình luận

  const CommentEntity({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
    required this.likes,
  });

  @override
  List<Object?> get props => [id, bookId, userId, content, createdAt];
}