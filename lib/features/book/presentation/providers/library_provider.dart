import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/get_bookmarked_books_usecase.dart';
import '../../domain/usecases/get_followed_books_usecase.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';
import '../../domain/usecases/toggle_follow_usecase.dart';
import 'book_usecase_providers.dart';

class LibraryState {
  final bool isLoading;
  final bool isBookmarkedLoading;
  final bool isFollowedLoading;
  final List<BookEntity> bookmarked;
  final List<BookEntity> followed;
  final String? error;

  final DocumentSnapshot? lastBookmarkedDoc;
  final bool hasReachedMaxBookmarked;

  final DocumentSnapshot? lastFollowedDoc;
  final bool hasReachedMaxFollowed;

  LibraryState({
    this.isLoading = false,
    this.isBookmarkedLoading = false,
    this.isFollowedLoading = false,
    this.bookmarked = const [],
    this.followed = const [],
    this.error,
    this.lastBookmarkedDoc,
    this.hasReachedMaxBookmarked = false,
    this.lastFollowedDoc,
    this.hasReachedMaxFollowed = false,
  });

  LibraryState copyWith({
    bool? isLoading,
    bool? isBookmarkedLoading,
    bool? isFollowedLoading,
    List<BookEntity>? bookmarked,
    List<BookEntity>? followed,
    String? error,
    DocumentSnapshot? lastBookmarkedDoc,
    bool? hasReachedMaxBookmarked,
    DocumentSnapshot? lastFollowedDoc,
    bool? hasReachedMaxFollowed,
  }) {
    return LibraryState(
      isLoading: isLoading ?? this.isLoading,
      isBookmarkedLoading: isBookmarkedLoading ?? this.isBookmarkedLoading,
      isFollowedLoading: isFollowedLoading ?? this.isFollowedLoading,
      bookmarked: bookmarked ?? this.bookmarked,
      followed: followed ?? this.followed,
      error: error,
      lastBookmarkedDoc: lastBookmarkedDoc ?? this.lastBookmarkedDoc,
      hasReachedMaxBookmarked:
          hasReachedMaxBookmarked ?? this.hasReachedMaxBookmarked,
      lastFollowedDoc: lastFollowedDoc ?? this.lastFollowedDoc,
      hasReachedMaxFollowed:
          hasReachedMaxFollowed ?? this.hasReachedMaxFollowed,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final Ref _ref;
  final GetBookmarkedBooksUseCase _getBookmarkedUseCase;
  final GetFollowedBooksUseCase _getFollowedUseCase;
  final ToggleBookmarkUseCase _toggleBookmarkUseCase;
  final ToggleFollowUseCase _toggleFollowUseCase;

  LibraryNotifier({
    required Ref ref,
    required GetBookmarkedBooksUseCase getBookmarkedUseCase,
    required GetFollowedBooksUseCase getFollowedUseCase,
    required ToggleBookmarkUseCase toggleBookmarkUseCase,
    required ToggleFollowUseCase toggleFollowUseCase,
  }) : _ref = ref,
       _getBookmarkedUseCase = getBookmarkedUseCase,
       _getFollowedUseCase = getFollowedUseCase,
       _toggleBookmarkUseCase = toggleBookmarkUseCase,
       _toggleFollowUseCase = toggleFollowUseCase,
       super(LibraryState());

  final int _pageSize = 5;

  Future<void> initLibrary() async {
    if (!mounted) return;
    state = LibraryState(isLoading: true);
    final userId = _ref.read(authProvider).user?.uid ?? "";

    if (userId.isEmpty) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: "Vui lòng đăng nhập");
      return;
    }

    await Future.wait([fetchMoreBookmarked(), fetchMoreFollowed()]);
    if (!mounted) return;
    state = state.copyWith(isLoading: false);
  }

  Future<void> fetchMoreBookmarked() async {
    if (!mounted || state.isBookmarkedLoading || state.hasReachedMaxBookmarked) return;

    final userId = _ref.read(authProvider).user?.uid ?? "";
    if (userId.isEmpty) return;

    state = state.copyWith(isBookmarkedLoading: true);

    final result = await _getBookmarkedUseCase(
      GetBookmarkedBooksParams(
        userId: userId,
        pageSize: _pageSize,
        lastDocument: state.lastBookmarkedDoc,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isBookmarkedLoading: false,
        error: failure.message,
      ),
      (data) {
        final books = data.$1;
        final lastDoc = data.$2;
        state = state.copyWith(
          isBookmarkedLoading: false,
          bookmarked: [...state.bookmarked, ...books],
          lastBookmarkedDoc: lastDoc,
          hasReachedMaxBookmarked: books.length < _pageSize,
        );
      },
    );
  }

  Future<void> fetchMoreFollowed() async {
    if (!mounted || state.isFollowedLoading || state.hasReachedMaxFollowed) return;

    final userId = _ref.read(authProvider).user?.uid ?? "";
    if (userId.isEmpty) return;

    state = state.copyWith(isFollowedLoading: true);

    final result = await _getFollowedUseCase(
      GetFollowedBooksParams(
        userId: userId,
        pageSize: _pageSize,
        lastDocument: state.lastFollowedDoc,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) => state = state.copyWith(
        isFollowedLoading: false,
        error: failure.message,
      ),
      (data) {
        final books = data.$1;
        final lastDoc = data.$2;
        state = state.copyWith(
          isFollowedLoading: false,
          followed: [...state.followed, ...books],
          lastFollowedDoc: lastDoc,
          hasReachedMaxFollowed: books.length < _pageSize,
        );
      },
    );
  }

  Future<void> removeBookFromBookmarked(String bookId) async {
    final userId = _ref.read(authProvider).user?.uid;
    if (userId == null) return;

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
      state = state.copyWith(
        bookmarked: state.bookmarked.where((b) => b.id != bookId).toList(),
      );
    });
  }

  Future<void> removeBookFromFollowed(String bookId) async {
    final userId = _ref.read(authProvider).user?.uid;
    if (userId == null) return;

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
      state = state.copyWith(
        followed: state.followed.where((b) => b.id != bookId).toList(),
      );
    });
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((
  ref,
) {
  final notifier = LibraryNotifier(
    ref: ref,
    getBookmarkedUseCase: ref.watch(getBookmarkedBooksUseCaseProvider),
    getFollowedUseCase: ref.watch(getFollowedBooksUseCaseProvider),
    toggleBookmarkUseCase: ref.watch(toggleBookmarkUseCaseProvider),
    toggleFollowUseCase: ref.watch(toggleFollowBooksUseCaseProvider),
  );

  notifier.initLibrary();

  return notifier;
});
