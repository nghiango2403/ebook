import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../entities/book_status.dart';
import '../repositories/book_repository.dart';

/// Class đóng gói toàn bộ các tiêu chí tìm kiếm và lọc
class SearchBooksParams {
  final int pageSize;
  final int offset;
  final String? searchValues;      // Tìm theo tiêu đề
  final String? searchDescription; // Tìm theo mô tả
  final int? minChapters;          // Số chương tối thiểu
  final String? category;          // Thể loại
  final BookStatus? status;        // Trạng thái (Hoàn thành,...)
  final BookSortType sortBy;       // Cách sắp xếp

  SearchBooksParams({
    required this.pageSize,
    required this.offset,
    this.searchValues,
    this.searchDescription,
    this.minChapters,
    this.category,
    this.status,
    required this.sortBy,
  });
}

class SearchBooksUseCase {
  final BookRepository repository;

  SearchBooksUseCase(this.repository);

  /// Thực thi tìm kiếm và lọc sách tổng hợp
  Future<Either<Failure, List<BookEntity>>> call(SearchBooksParams params) async {
    return await repository.searchBooks(
      pageSize: params.pageSize,
      offset: params.offset,
      searchValues: params.searchValues,
      searchDescription: params.searchDescription,
      minChapters: params.minChapters,
      category: params.category,
      status: params.status,
      sortBy: params.sortBy,
    );
  }
}