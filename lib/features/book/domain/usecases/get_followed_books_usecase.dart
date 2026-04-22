import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../repositories/book_repository.dart';

/// Tham số để lấy danh sách sách đang theo dõi
class GetFollowedBooksParams {
  final String userId;
  final int pageSize;
  final DocumentSnapshot? lastDocument;
  final String searchValues;

  GetFollowedBooksParams({
    required this.userId,
    this.pageSize = 20,
    this.lastDocument,
    this.searchValues = "",
  });
}

class GetFollowedBooksUseCase {
  final BookRepository repository;

  GetFollowedBooksUseCase(this.repository);

  /// Lấy danh sách truyện mà người dùng đã nhấn "Theo dõi"
  Future<Either<Failure, List<BookEntity>>> call(GetFollowedBooksParams params) async {
    return await repository.getFollowedBooks(
      userId: params.userId,
      pageSize: params.pageSize,
      lastDocument: params.lastDocument,
      searchValues: params.searchValues,
    );
  }
}