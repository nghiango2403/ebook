import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/book_status.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_data_source.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl({required this.remoteDataSource});

  // --- NHÓM TRUY VẤN THÔNG TIN ---

  @override
  Future<Either<Failure, BookEntity>> getBookById(String id) async {
    try {
      final result = await remoteDataSource.getBookById(id);
      return Right(result);
    } catch (e) {
      dev.log("Firestore Error (getBookById): $e");
      return Left(ServerFailure(message: "Không thể lấy thông tin sách"));
    }
  }

  @override
  Future<Either<Failure, String>> getBookDescription(String bookId) async {
    try {
      final result = await remoteDataSource.getBookDescription(bookId);
      return Right(result);
    } catch (e) {
      dev.log("Firestore Error (getBookDescription): $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getBooksByAuthor({
    required String authorId,
    required String excludedBookId,
  }) async {
    try {
      final result = await remoteDataSource.getBooksByAuthor(
        authorId,
        excludedBookId,
      );
      return Right(result);
    } catch (e) {
      dev.log("Firestore Error (getBooksByAuthor): $e");
      return Left(ServerFailure());
    }
  }

  // --- NHÓM TƯƠNG TÁC & CHỈ SỐ ---

  @override
  Future<Either<Failure, void>> toggleBookmark(
    String bookId,
    String userId,
    DateTime createAt,
  ) async {
    try {
      await remoteDataSource.toggleBookmark(bookId, userId, createAt);
      return const Right(null);
    } catch (e) {
      dev.log("Firestore Error (toggleBookmark): $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleFollow(
    String bookId,
    String userId,
    DateTime createAt,
  ) async {
    try {
      await remoteDataSource.toggleFollow(bookId, userId, createAt);
      return const Right(null);
    } catch (e) {
      dev.log("Firestore Error (toggleFollow): $e");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // --- NHÓM NỘI DUNG & CỘNG ĐỒNG ---

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments(
    String bookId,
  ) async {
    try {
      final result = await remoteDataSource.getComments(bookId);
      return Right(result);
    } catch (e) {
      dev.log("Firestore Error (getComments): $e");
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
    } catch (e) {
      dev.log("Firestore Error (searchBooks): $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, (List<BookEntity>, DocumentSnapshot?)>> getBookmarkedBooks({
    required String userId,
    required int pageSize,
    DocumentSnapshot? lastDocument,
    String searchValues = "",
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .orderBy('addedAt', descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      
      List<BookEntity> books = [];
      for (var doc in snapshot.docs) {
        final bookId = doc.id;
        final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
        if (bookDoc.exists) {
          books.add(BookModel.fromMap(bookDoc.data()!, bookDoc.id));
        }
      }

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      return Right((books, lastDoc));
    } catch (e) {
      dev.log("Firestore Error (getBookmarkedBooks): $e");
      return Left(ServerFailure(message: "Không thể lấy danh sách đánh dấu"));
    }
  }

  @override
  Future<Either<Failure, (List<BookEntity>, DocumentSnapshot?)>> getFollowedBooks({
    required String userId,
    required int pageSize,
    DocumentSnapshot? lastDocument,
    String searchValues = "",
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('following')
          .orderBy('followedAt', descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      
      List<BookEntity> books = [];
      for (var doc in snapshot.docs) {
        final bookId = doc.id;
        final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
        if (bookDoc.exists) {
          books.add(BookModel.fromMap(bookDoc.data()!, bookDoc.id));
        }
      }

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      return Right((books, lastDoc));
    } catch (e) {
      dev.log("Firestore Error (getFollowedBooks): $e");
      return Left(ServerFailure(message: "Không thể lấy danh sách theo dõi"));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getReadingHistory({
    required String userId,
    required int pageSize,
    required int offset,
  }) async {
    try {
      final result = await remoteDataSource.getReadingHistory(
        userId,
        pageSize,
        offset,
      );
      return Right(result);
    } catch (e) {
      dev.log("Firestore Error (getReadingHistory): $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isBookmarked({
    required String userId,
    required String bookId,
  }) async {
    try {
      final result = await remoteDataSource.isBookmarked(userId, bookId);
      return Right(result);
    } catch (e) {
      dev.log("Firestore Error (isBookmarked): $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isFollowed({
    required String userId,
    required String bookId,
  }) async {
    try {
      final result = await remoteDataSource.isFollowed(userId, bookId);
      return Right(result);
    } catch (e) {
      dev.log("Firestore Error (isFollowed): $e");
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addBook(String bookId) async {
    try {
      await remoteDataSource.addBook(bookId);
      return const Right(true);
    } catch (e) {
      dev.log("Firestore Error (addBook): $e");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, (List<BookEntity>, DocumentSnapshot?)>> getMyBooks(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
  ) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('books')
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final books = snapshot.docs
          .map((doc) =>
              BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return Right((books, lastDoc));
    } catch (e) {
      dev.log("Firestore Error (getMyBooks): $e");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hiddenBook(String bookId) async {
    try {
      await remoteDataSource.hiddenBook(bookId);
      return const Right(true);
    } catch (e) {
      dev.log("Firestore Error (hiddenBook): $e");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unHiddenBook(String bookId) async {
    try {
      await remoteDataSource.unHiddenBook(bookId);
      return const Right(true);
    } catch (e) {
      dev.log("Firestore Error (unHiddenBook): $e");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBook(BookEntity book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      await remoteDataSource.updateBook(bookModel);
      return const Right(true);
    } catch (e) {
      dev.log("Firestore Error (updateBook): $e");
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBookStatus(
    String bookId,
    BookStatus status,
  ) async {
    try {
      await remoteDataSource.updateBookStatus(bookId, status);
      return const Right(true);
    } catch (e) {
      dev.log("Firestore Error (updateBookStatus): $e");
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
