import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/chapter_entity.dart';
import '../entities/reading_history_entity.dart';

abstract class ChapterRepository {
  /// Lấy danh sách chương của truyện (Sắp xếp theo số thứ tự)
  Future<Either<Failure, List<ChapterEntity>>> getListChapter(String bookId);

  /// Tăng số lượt xem (Xử lý tăng cả viewsDay, viewsWeek và views tổng)
  Future<Either<Failure, void>> incrementViews(String id);

  /// Thêm chương mới
  Future<Either<Failure, void>> addChapter(
    String bookId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  );

  /// Xóa chương
  Future<Either<Failure, void>> deleteChapter(String bookId, String chapterId);

  /// Sửa chương
  Future<Either<Failure, void>> updateChapter(
    String bookId,
    String chapterId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  );

  /// Lấy nội dung chương
  Future<Either<Failure, ChapterEntity>> getChapter(
    String bookId,
    String chapterId,
    String userId,
  );

  /// Thêm lịch sử đọc
  Future<Either<Failure, void>> addReadingHistory(
    String bookId,
    String chapterId,
    String userId,
    DateTime lastReadAt,
  );

  /// Lấy danh sách sách đã đọc
  Future<Either<Failure, List<ReadingHistoryEntity>>> getListReadingHistory(
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
