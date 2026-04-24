import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:ebook/features/history/domain/repositories/reading_history_repository.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/reading_history_entity.dart';
import '../datasources/reading_history_remote_datasource.dart';

class ReadingHistoryRepositoryImpl extends ReadingHistoryRepository {
  final ReadingHistoryRemoteDataSource remoteDataSource;

  ReadingHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addReadingHistory(
    String bookId,
    String chapterId,
    String userId,
    String chapterTitle,
    int orderIndex,
    DateTime lastReadAt,
  ) async {
    try {
      await remoteDataSource.addReadingHistory(
        bookId,
        chapterId,
        userId,
        chapterTitle,
        orderIndex,
        lastReadAt,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, (List<ReadingHistoryEntity>, DocumentSnapshot?)>> getListReadingHistory(
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
