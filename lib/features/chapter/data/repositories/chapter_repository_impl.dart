import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:ebook/features/chapter/domain/repositories/chapter_repository.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/chapter_entity.dart';
import '../../domain/entities/reading_history_entity.dart';
import '../datasources/chapter_remote_datasource.dart';

class ChapterRepositoryImpl implements ChapterRepository {
  final ChapterRemoteDataSource remoteDataSource;

  ChapterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ChapterEntity>>> getListChapter(
    String bookId,
  ) async {
    try {
      final result = await remoteDataSource.getListChapter(bookId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementViews(String id) async {
    try {
      await remoteDataSource.incrementViews(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addChapter(
    String bookId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  ) async {
    try {
      await remoteDataSource.addChapter(
        bookId,
        title,
        content,
        orderIndex,
        isVip,
        price,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChapter(
    String bookId,
    String chapterId,
  ) async {
    try {
      await remoteDataSource.deleteChapter(bookId, chapterId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChapter(
    String bookId,
    String chapterId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  ) async {
    try {
      await remoteDataSource.updateChapter(
        bookId,
        chapterId,
        title,
        content,
        orderIndex,
        isVip,
        price,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChapterEntity>> getChapter(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.getChapter(bookId, chapterId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addReadingHistory(
    String bookId,
    String chapterId,
    String userId,
    DateTime lastReadAt,
  ) async {
    try {
      await remoteDataSource.addReadingHistory(
        bookId,
        chapterId,
        userId,
        lastReadAt,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReadingHistoryEntity>>> getListReadingHistory(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocumentSnapshot,
  ) async {
    try {
      final result = await remoteDataSource.getListReadingHistory(
        userId,
        pageSize,
        lastDocumentSnapshot,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReadingHistory(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    try {
      await remoteDataSource.deleteReadingHistory(bookId, chapterId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReadingHistoryEntity>> getReadingHistory(
    String bookId,
    String userId,
  ) async {
    try {
      final result = await remoteDataSource.getReadingHistory(bookId, userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
