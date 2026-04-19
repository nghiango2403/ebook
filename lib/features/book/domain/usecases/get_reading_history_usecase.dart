import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

/// Tham số để lấy lịch sử đọc của người dùng
class GetReadingHistoryParams {
  final String userId;
  final int pageSize;
  final int offset;

  GetReadingHistoryParams({
    required this.userId,
    this.pageSize = 20,
    this.offset = 0,
  });
}

class GetReadingHistoryUseCase {
  final BookRepository repository;

  GetReadingHistoryUseCase(this.repository);

  /// Lấy danh sách các truyện người dùng đã từng đọc
  /// Dữ liệu thường được sắp xếp theo thời gian đọc gần nhất (lastReadAt)
  Future<Either<Failure, List<BookEntity>>> call(GetReadingHistoryParams params) async {
    return await repository.getReadingHistory(
      userId: params.userId,
      pageSize: params.pageSize,
      offset: params.offset,
    );
  }
}