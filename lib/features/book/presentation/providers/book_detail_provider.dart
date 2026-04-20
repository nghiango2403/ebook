import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';
import '../model/book_view_model.dart';
import 'book_usecase_providers.dart';
import 'library_provider.dart';

final bookDetailProvider = FutureProvider.family<BookViewModel, String>((ref, bookId) async {
  final getBookByIdUseCase = ref.watch(getBookByIdUseCaseProvider);
  final getCategoryByIdUseCase = ref.watch(getCategoryByIdUseCaseProvider);
  final result = await getBookByIdUseCase.call(bookId);
  final bookEntity = result.fold(
        (failure) => throw failure,
        (book) => book,
  );
  CategoryEntity? category;
  if (bookEntity.categoryId.isNotEmpty) {
    category = await getCategoryByIdUseCase.execute(bookEntity.categoryId);
  }
  return BookViewModel(
    book: bookEntity,
    category: category,
  );
});

final bookInteractionProvider = AsyncNotifierProvider<BookInteractionNotifier, void>(() {
  return BookInteractionNotifier();
});

class BookInteractionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggleBookmark(String bookId, String userId) async {
    final useCase = ref.read(toggleBookmarkUseCaseProvider);
    final result = await useCase(ToggleBookmarkParams(bookId: bookId, userId: userId));

    if (result.isLeft()) {
      // Xử lý lỗi nếu cần
    } else {
      ref.invalidate(libraryProvider);
    }
  }
}