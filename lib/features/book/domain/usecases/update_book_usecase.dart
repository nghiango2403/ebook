import 'package:dartz/dartz.dart';
import 'package:ebook/features/book/domain/repositories/book_repository.dart';

import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';

class UpdateBookUseCase {
  final BookRepository repository;

  UpdateBookUseCase(this.repository);

  Future<Either<Failure, bool>> call(BookEntity book) async {
    return await repository.updateBook(book);
  }
}
