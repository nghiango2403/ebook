import 'package:equatable/equatable.dart';

class ReadingHistoryEntity extends Equatable {
  final String userId; // ID người dùng
  final String bookId; // ID bộ truyện
  final String chapterId; // ID của chương hiện tại đang đọc
  final DateTime
  updatedAt; // Thời điểm cuối cùng đọc (để sắp xếp danh sách gần đây)
  final int orderIndex;
  final String title;

  const ReadingHistoryEntity({
    required this.userId,
    required this.bookId,
    required this.chapterId,
    required this.updatedAt,
    this.orderIndex = 0,
    this.title = '',
  });

  @override
  List<Object?> get props => [
    userId,
    bookId,
    chapterId,
    updatedAt,
    orderIndex,
    title,
  ];
}
