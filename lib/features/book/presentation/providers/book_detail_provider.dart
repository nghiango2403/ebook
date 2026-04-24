import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../../category/domain/usecases/get_category_by_id_usecase.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../domain/usecases/get_book_by_id_usecase.dart';
import '../../domain/usecases/is_bookmarked_usecase.dart';
import '../../domain/usecases/is_followed_book_usecase.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';
import '../../domain/usecases/toggle_follow_usecase.dart';
import '../model/book_view_model.dart';
import 'book_usecase_providers.dart';
import 'library_provider.dart';

// --- 1. Trạng thái của Book Detail (BookDetailState) ---
class BookDetailState {
  final bool isLoading;
  final BookViewModel? bookViewModel;
  final String? error;

  BookDetailState({this.isLoading = false, this.bookViewModel, this.error});

  BookDetailState copyWith({
    bool? isLoading,
    BookViewModel? bookViewModel,
    String? error,
  }) {
    return BookDetailState(
      isLoading: isLoading ?? this.isLoading,
      bookViewModel: bookViewModel ?? this.bookViewModel,
      error: error,
    );
  }
}

// --- 2. Notifier quản lý logic Book Detail ---
class BookDetailNotifier extends StateNotifier<BookDetailState> {
  final GetBookByIdUseCase _getBookByIdUseCase;
  final GetCategoryByIdUseCase _getCategoryByIdUseCase;
  final IsBookmarkedUsecase _isBookmarkedUseCase;
  final IsFollowedBookUsecase _isFollowedBookUseCase;
  final ToggleBookmarkUseCase _toggleBookmarkUseCase;
  final ToggleFollowUseCase _toggleFollowUseCase;
  final Ref _ref;

  BookDetailNotifier({
    required GetBookByIdUseCase getBookByIdUseCase,
    required GetCategoryByIdUseCase getCategoryByIdUseCase,
    required IsBookmarkedUsecase isBookmarkedUseCase,
    required IsFollowedBookUsecase isFollowedBookUseCase,
    required ToggleBookmarkUseCase toggleBookmarkUseCase,
    required ToggleFollowUseCase toggleFollowUseCase,
    required Ref ref,
  }) : _getBookByIdUseCase = getBookByIdUseCase,
       _getCategoryByIdUseCase = getCategoryByIdUseCase,
       _isBookmarkedUseCase = isBookmarkedUseCase,
       _isFollowedBookUseCase = isFollowedBookUseCase,
       _toggleBookmarkUseCase = toggleBookmarkUseCase,
       _toggleFollowUseCase = toggleFollowUseCase,
       _ref = ref,
       super(BookDetailState());

  Future<void> loadBookDetail(String bookId) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    final userId = _ref.read(authProvider).user?.uid;

    final bookResult = await _getBookByIdUseCase.call(bookId);

    if (!mounted) return;

    await bookResult.fold(
      (failure) async {
        if (!mounted) return;
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (bookEntity) async {
        CategoryEntity? category;
        if (bookEntity.categoryId.isNotEmpty) {
          category = await _getCategoryByIdUseCase.execute(
            bookEntity.categoryId,
          );
        }

        bool isBookmarked = false;
        if (userId != null) {
          final res = await _isBookmarkedUseCase.execute(userId, bookId);
          isBookmarked = res.getOrElse(() => false);
        }

        bool isFollowed = false;
        if (userId != null) {
          final res = await _isFollowedBookUseCase.execute(userId, bookId);
          isFollowed = res.getOrElse(() => false);
        }

        if (!mounted) return;

        state = state.copyWith(
          isLoading: false,
          bookViewModel: BookViewModel(
            book: bookEntity,
            category: category,
            isBookmarked: isBookmarked,
            isFollowed: isFollowed,
          ),
        );
      },
    );
  }

  Future<void> toggleBookmark(String bookId) async {
    final userId = _ref.read(authProvider).user?.uid;
    if (userId == null) {
      if (!mounted) return;
      state = state.copyWith(error: "Người dùng chưa đăng nhập");
      return;
    }

    final result = await _toggleBookmarkUseCase(
      ToggleBookmarkParams(
        bookId: bookId,
        userId: userId,
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) return;

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      _,
    ) {
      // Cập nhật lại library để đồng bộ UI
      _ref.invalidate(libraryProvider);
      // Reload lại detail để cập nhật icon
      loadBookDetail(bookId);
    });
  }

  Future<void> toggleFollowBook(String bookId) async {
    final userId = _ref.read(authProvider).user?.uid;
    if (userId == null) {
      if (!mounted) return;
      state = state.copyWith(error: "Người dùng chưa đăng nhập");
      return;
    }

    final result = await _toggleFollowUseCase(
      ToggleFollowParams(
        bookId: bookId,
        userId: userId,
        createAt: DateTime.now(),
      ),
    );

    if (!mounted) return;

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      _,
    ) {
      _ref.invalidate(libraryProvider);
      loadBookDetail(bookId);
    });
  }
}

// --- 3. Provider chính để UI sử dụng ---
final bookDetailProvider =
    StateNotifierProvider.family<BookDetailNotifier, BookDetailState, String>((
      ref,
      bookId,
    ) {
      final notifier = BookDetailNotifier(
        getBookByIdUseCase: ref.watch(getBookByIdUseCaseProvider),
        getCategoryByIdUseCase: ref.watch(getCategoryByIdUseCaseProvider),
        isBookmarkedUseCase: ref.watch(isBookmarkUseCaseProvider),
        isFollowedBookUseCase: ref.watch(isFollowBookUseCaseProvider),
        toggleBookmarkUseCase: ref.watch(toggleBookmarkUseCaseProvider),
        toggleFollowUseCase: ref.watch(toggleFollowBooksUseCaseProvider),
        ref: ref,
      );

      // Tự động load khi khởi tạo
      Future.microtask(() => notifier.loadBookDetail(bookId));

      return notifier;
    });
