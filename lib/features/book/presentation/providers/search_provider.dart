import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/search_books_usecase.dart';
import 'book_usecase_providers.dart';

final searchProvider = AsyncNotifierProvider<SearchNotifier, List<BookEntity>>(() {
  return SearchNotifier();
});

class SearchNotifier extends AsyncNotifier<List<BookEntity>> {
  @override
  Future<List<BookEntity>> build() async => [];

  Future<void> search(SearchBooksParams params) async {
    state = const AsyncLoading();
    final useCase = ref.read(searchBooksUseCaseProvider);
    final result = await useCase(params);

    state = result.fold(
          (failure) => AsyncError(failure.message, StackTrace.current),
          (books) => AsyncData(books),
    );
  }
}