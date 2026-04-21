import '../../domain/entities/book_entity.dart';
import '../../../category/domain/entities/category_entity.dart';

class BookViewModel {
  final BookEntity book;
  final CategoryEntity? category;
  final bool isBookmarked;
  final bool isFollowed;

  BookViewModel({required this.book, this.category, this.isBookmarked = false, this.isFollowed = false});
}