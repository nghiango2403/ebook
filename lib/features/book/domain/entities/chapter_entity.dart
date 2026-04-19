import 'package:equatable/equatable.dart';

class ChapterEntity extends Equatable {
  final String id;
  final String bookId;    // Link tới truyện
  final String title;     // Tên chương (Vd: Chương 1:...)
  final int orderIndex;   // Số thứ tự để sắp xếp
  final String content;   // Nội dung chữ (chỉ load khi vào màn hình đọc)
  final DateTime createdAt;

  const ChapterEntity({
    required this.id,
    required this.bookId,
    required this.title,
    required this.orderIndex,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, bookId, title, orderIndex, content, createdAt];
}