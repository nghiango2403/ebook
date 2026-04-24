import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reading_history_entity.dart';

abstract class ReadingHistoryRepository {
  /// Thêm lịch sử đọc
  Future<Either<Failure, void>> addReadingHistory(
    String bookId,
    String chapterId,
    String userId,
    String chapterTitle,
    int orderIndex,
    DateTime lastReadAt,
  );

  /// Lấy danh sách sách đã đọc
  Future<Either<Failure, (List<ReadingHistoryEntity>, DocumentSnapshot?)>> getListReadingHistory(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocumentSnapshot,
  );

  /// Xóa lịch sử đọc
  Future<Either<Failure, void>> deleteReadingHistory(
    String bookId,
    String chapterId,
    String userId,
  );

  /// Lấy lịch sử đọc
  Future<Either<Failure, ReadingHistoryEntity>> getReadingHistory(
    String bookId,
    String userId,
  );
}
