import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';
import 'book_usecase_providers.dart';
import 'library_provider.dart';

final bookDetailProvider = FutureProvider.family<BookEntity, String>((ref, bookId) async {
  final useCase = ref.read(getBookByIdUseCaseProvider);
  final result = await useCase(bookId);
  return result.fold((f) => throw f.message, (book) => book);
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