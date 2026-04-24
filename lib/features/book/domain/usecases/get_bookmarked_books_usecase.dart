import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

/// Tham số để lấy danh sách sách đã đánh dấu, hỗ trợ phân trang
class GetBookmarkedBooksParams {
  final String userId;
  final int pageSize;
  final DocumentSnapshot? lastDocument;
  final String searchValues;

  GetBookmarkedBooksParams({
    required this.userId,
    this.pageSize = 10,
    this.lastDocument,
    this.searchValues = "",
  });
}

class GetBookmarkedBooksUseCase {
  final BookRepository repository;

  GetBookmarkedBooksUseCase(this.repository);

  /// Lấy danh sách sách mà người dùng đã nhấn Bookmark
  Future<Either<Failure, (List<BookEntity>, DocumentSnapshot?)>> call(GetBookmarkedBooksParams params) async {
    return await repository.getBookmarkedBooks(
      userId: params.userId,
      pageSize: params.pageSize,
      lastDocument: params.lastDocument,
      searchValues: params.searchValues,
    );
  }
}