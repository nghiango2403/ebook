import 'package:ebook/features/book/domain/entities/paginated_books.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/get_bookmarked_books_usecase.dart';
import '../../domain/usecases/get_followed_books_usecase.dart';
import 'book_usecase_providers.dart';

class LibraryState {
  final BookListState bookmarked;
  final BookListState followed;
  final BookListState history;

  LibraryState({
    required this.bookmarked,
    required this.followed,
    required this.history,
  });

  LibraryState copyWith({
    BookListState? bookmarked,
    BookListState? followed,
    BookListState? history,
  }) {
    return LibraryState(
      bookmarked: bookmarked ?? this.bookmarked,
      followed: followed ?? this.followed,
      history: history ?? this.history,
    );
  }
}

final libraryProvider = AsyncNotifierProvider<LibraryNotifier, LibraryState>(
  () {
    return LibraryNotifier();
  },
);

class LibraryNotifier extends AsyncNotifier<LibraryState> {
  @override
  Future<LibraryState> build() async {
    return LibraryState(
      bookmarked: BookListState(books: await _fetchBookmarked()),
      followed: BookListState(books: await _fetchFollowed()),
      history: BookListState(books: await _fetchHistory()),
    );
  }

  Future<List<BookEntity>> _fetchBookmarked() async {
    final useCase = ref.read(getBookmarkedBooksUseCaseProvider);
    final userId = ref.read(authProvider).user?.uid ?? "";
    if (userId.isEmpty) return [];
    final result = await useCase(GetBookmarkedBooksParams(userId: userId));
    return result.getOrElse(() => []);
  }

  Future<List<BookEntity>> _fetchFollowed() async {
    final useCase = ref.read(getFollowedBooksUseCaseProvider);
    final userId = ref.read(authProvider).user?.uid ?? "";
    if (userId.isEmpty) return [];

    final result = await useCase(
      GetFollowedBooksParams(userId: userId, pageSize: 20, searchValues: ""),
    );

    return result.fold((failure) => [], (books) => books);
  }

  Future<List<BookEntity>> _fetchHistory() async {
    final useCase = ref.read(getListReadingHistoryUseCaseProvider);
    final getBookByIdUseCase = ref.read(getBookByIdUseCaseProvider);
    final userId = ref.read(authProvider).user?.uid ?? "";
    if (userId.isEmpty) return [];

    final result = await useCase.call(userId, 20, null);

    return result.fold((failure) => [], (historyItems) async {
      List<BookEntity> books = [];
      for (var item in historyItems) {
        final bookResult = await getBookByIdUseCase(item.bookId);
        bookResult.fold((_) => null, (book) => books.add(book));
      }
      return books;
    });
  }

  void removeBookFromBookmarked(String bookId) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    final updatedBooks = currentState.bookmarked.books
        .where((b) => b.id != bookId)
        .toList();
    state = AsyncData(
      currentState.copyWith(
        bookmarked: currentState.bookmarked.copyWith(books: updatedBooks),
      ),
    );
  }

  void removeBookFromFollowed(String bookId) {
    if (!state.hasValue) return;
    final currentState = state.value!;
    final updatedBooks = currentState.followed.books
        .where((b) => b.id != bookId)
        .toList();
    state = AsyncData(
      currentState.copyWith(
        followed: currentState.followed.copyWith(books: updatedBooks),
      ),
    );
  }
}
