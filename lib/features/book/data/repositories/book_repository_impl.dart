import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/chapter_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/book_status.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_data_source.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl({required this.remoteDataSource});

  // --- NHÓM TRUY VẤN THÔNG TIN ---

  @override
  Future<Either<Failure, BookEntity>> getBookById(String id) async {
    try {
      final result = await remoteDataSource.getBookById(id);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure(message: "Không thể lấy thông tin sách"));
    }
  }

  @override
  Future<Either<Failure, String>> getBookDescription(String bookId) async {
    try {
      final result = await remoteDataSource.getBookDescription(bookId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getBooksByAuthor({
    required String authorId,
    required String excludedBookId,
  }) async {
    try {
      final result = await remoteDataSource.getBooksByAuthor(authorId, excludedBookId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  // --- NHÓM TƯƠNG TÁC & CHỈ SỐ ---

  @override
  Future<Either<Failure, void>> incrementViews(String id) async {
    try {
      await remoteDataSource.incrementViews(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: "Lỗi cập nhật lượt xem"));
    }
  }

  @override
  Future<Either<Failure, void>> toggleBookmark(String bookId, String userId) async {
    try {
      await remoteDataSource.toggleBookmark(bookId, userId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleFollow(String bookId, String userId) async {
    try {
      await remoteDataSource.toggleFollow(bookId, userId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  // --- NHÓM NỘI DUNG & CỘNG ĐỒNG ---

  @override
  Future<Either<Failure, List<ChapterEntity>>> getChapters(String bookId) async {
    try {
      final result = await remoteDataSource.getChapters(bookId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(String bookId) async {
    try {
      final result = await remoteDataSource.getComments(bookId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  // --- NHÓM TÌM KIẾM & CÁ NHÂN HÓA (PHÂN TRANG) ---

  @override
  Future<Either<Failure, List<BookEntity>>> searchBooks({
    required int pageSize,
    required int offset,
    String? searchValues,
    String? searchDescription,
    int? minChapters,
    String? category,
    BookStatus? status,
    required BookSortType sortBy,
  }) async {
    try {
      final result = await remoteDataSource.searchBooks(
        pageSize: pageSize,
        offset: offset,
        searchValues: searchValues,
        searchDescription: searchDescription,
        minChapters: minChapters,
        category: category,
        status: status,
        sortBy: sortBy,
      );
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getBookmarkedBooks({
    required String userId,
    required int pageSize,
    required int offset,
  }) async {
    try {
      final result = await remoteDataSource.getBookmarkedBooks(userId, pageSize, offset);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getFollowedBooks({
    required String userId,
    required int pageSize,
    required int offset,
  }) async {
    try {
      final result = await remoteDataSource.getFollowedBooks(userId, pageSize, offset);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getReadingHistory({
    required String userId,
    required int pageSize,
    required int offset,
  }) async {
    try {
      final result = await remoteDataSource.getReadingHistory(userId, pageSize, offset);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}