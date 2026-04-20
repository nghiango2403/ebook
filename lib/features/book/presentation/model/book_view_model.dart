import '../../domain/entities/book_entity.dart';
import '../../../category/domain/entities/category_entity.dart';

class BookViewModel {
  final BookEntity book;
  final CategoryEntity? category;

  BookViewModel({required this.book, this.category});
}