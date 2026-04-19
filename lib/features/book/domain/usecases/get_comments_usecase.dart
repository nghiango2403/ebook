import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/comment_entity.dart';
import '../repositories/book_repository.dart';

class GetCommentsUseCase {
  final BookRepository repository;

  GetCommentsUseCase(this.repository);

  /// Lấy danh sách bình luận của một cuốn sách
  /// Dữ liệu thường được sắp xếp theo thời gian mới nhất (createdAt) từ Repository
  Future<Either<Failure, List<CommentEntity>>> call(String bookId) async {
    return await repository.getComments(bookId);
  }
}