import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/reading_history_entity.dart';

class ReadingHistoryModel extends ReadingHistoryEntity {
  const ReadingHistoryModel({
    required super.userId,
    required super.bookId,
    required super.chapterId,
    required super.updatedAt,
    super.orderIndex = 0,
    super.title = '',
  });

  factory ReadingHistoryModel.fromMap(Map<String, dynamic> map) {
    return ReadingHistoryModel(
      userId: map['userId'] ?? '',
      bookId: map['bookId'] ?? '',
      chapterId: map['chapterId'] ?? '',
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      orderIndex: (map['orderIndex'] as num?)?.toInt() ?? 0,
      title: map['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookId': bookId,
      'chapterId': chapterId,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'orderIndex': orderIndex,
      'title': title,
    };
  }
}