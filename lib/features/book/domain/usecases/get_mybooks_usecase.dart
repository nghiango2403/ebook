import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:ebook/features/book/domain/repositories/book_repository.dart';

import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';

class GetMyBooksUseCase {
  final BookRepository repository;

  GetMyBooksUseCase(this.repository);

  Future<Either<Failure, List<BookEntity>>> call(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
  ) async {
    return await repository.getMyBooks(userId, pageSize, lastDocument);
  }
}
