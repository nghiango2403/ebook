import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/book_status.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/search_books_usecase.dart';
import '../model/book_view_model.dart';
import 'book_usecase_providers.dart';
import '../../../category/presentation/providers/category_provider.dart';

/// Hàm bổ trợ để map Book sang BookViewModel (kèm thông tin Category)
List<BookViewModel> _mapBooksWithCategory(List<CategoryEntity> categories, List<BookEntity> books) {
  return books.map((book) {
    final CategoryEntity? category = categories.cast<CategoryEntity?>().firstWhere(
          (cat) => cat?.id == book.categoryId,
      orElse: () => categories.isNotEmpty ? categories.first : null,
    );

    return BookViewModel(book: book, category: category);
  }).toList();
}

/// Provider: Sách mới cập nhật
final recentlyUpdatedProvider = FutureProvider<List<BookViewModel>>((ref) async {
  final categories = await ref.watch(categoriesListProvider.future);
  final useCase = ref.watch(searchBooksUseCaseProvider);
  final result = await useCase(SearchBooksParams(
    pageSize: 10,
    offset: 0,
    sortBy: BookSortType.recentlyUpdated,
  ));

  return result.fold(
        (failure) => throw failure.message,
        (books) => _mapBooksWithCategory(categories, books),
  );
});

/// Provider: Sách mới đăng
final newlyUploadedProvider = FutureProvider<List<BookViewModel>>((ref) async {
  final categories = await ref.watch(categoriesListProvider.future);
  final useCase = ref.watch(searchBooksUseCaseProvider);
  final result = await useCase(SearchBooksParams(
    pageSize: 10,
    offset: 0,
    sortBy: BookSortType.newlyUploaded,
  ));

  return result.fold(
        (failure) => throw failure.message,
        (books) => _mapBooksWithCategory(categories, books),
  );
});

/// Provider: Sách mới hoàn thành
final newlyCompletedProvider = FutureProvider<List<BookViewModel>>((ref) async {
  final categories = await ref.watch(categoriesListProvider.future);
  final useCase = ref.watch(searchBooksUseCaseProvider);
  final result = await useCase(SearchBooksParams(
    pageSize: 10,
    offset: 0,
    status: BookStatus.completed,
    sortBy: BookSortType.newlyCompleted,
  ));

  return result.fold(
        (failure) => throw failure.message,
        (books) => _mapBooksWithCategory(categories, books),
  );
});