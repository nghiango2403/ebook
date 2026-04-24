import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reading_history_entity.dart';
import '../repositories/reading_history_repository.dart';

class GetListReadingHistoryUseCase {
  final ReadingHistoryRepository repository;

  GetListReadingHistoryUseCase(this.repository);

  /// Lấy danh sách sách đã đọc
  Future<Either<Failure, (List<ReadingHistoryEntity>, DocumentSnapshot?)>> call(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocumentSnapshot,
  ) async {
    return await repository.getListReadingHistory(
      userId,
      pageSize,
      lastDocumentSnapshot,
    );
  }
}
