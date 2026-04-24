import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../book/domain/usecases/get_book_by_id_usecase.dart';
import '../../../book/domain/usecases/update_book_usecase.dart';
import '../../../book/presentation/providers/book_usecase_providers.dart';
import '../../domain/entities/chapter_entity.dart';
import '../../domain/entities/reading_history_entity.dart';
import '../../domain/usecases/add_chapter_usecase.dart';
import '../../domain/usecases/add_reading_history_usecase.dart';
import '../../domain/usecases/delete_chapter_usecase.dart';
import '../../domain/usecases/delete_reading_history_usecase.dart';
import '../../domain/usecases/get_chapter_usecase.dart';
import '../../domain/usecases/get_list_chapter_usecase.dart';
import '../../domain/usecases/get_list_reading_history_usecase.dart';
import '../../domain/usecases/get_reading_history_usecase.dart';
import '../../domain/usecases/increment_views_usecase.dart';
import '../../domain/usecases/update_chapter_usecase.dart';

// =============================================================================
// 1. Tầng DOMAIN (Providers cho các UseCases của Chapter)
// =============================================================================

final getListChaptersUseCaseProvider = Provider((ref) {
  return GetListBooksChaptersUseCase(ref.watch(chapterRepositoryProvider));
});

final getChapterUseCaseProvider = Provider((ref) {
  return GetChapterUseCase(ref.watch(chapterRepositoryProvider));
});

final addChapterUseCaseProvider = Provider((ref) {
  return AddChapterUseCase(ref.watch(chapterRepositoryProvider));
});

final updateChapterUseCaseProvider = Provider((ref) {
  return UpdateChapterUseCase(ref.watch(chapterRepositoryProvider));
});

final deleteChapterUseCaseProvider = Provider((ref) {
  return DeleteChapterUseCase(ref.watch(chapterRepositoryProvider));
});

final incrementChapterViewsUseCaseProvider = Provider((ref) {
  return IncrementViewsUseCase(ref.watch(chapterRepositoryProvider));
});

final addReadingHistoryUseCaseProvider = Provider((ref) {
  return AddReadingHistoryUseCase(ref.watch(chapterRepositoryProvider));
});

final getReadingHistoryUseCaseProvider = Provider((ref) {
  return GetReadingHistoryUseCase(ref.watch(chapterRepositoryProvider));
});

final getListReadingHistoryUseCaseProvider = Provider((ref) {
  return GetListReadingHistoryUseCase(ref.watch(chapterRepositoryProvider));
});

final deleteReadingHistoryUseCaseProvider = Provider((ref) {
  return DeleteReadingHistoryUseCase(ref.watch(chapterRepositoryProvider));
});

// =============================================================================
// 2. Tầng PRESENTATION (State và Notifier)
// =============================================================================

class ChapterState {
  final bool isLoading;
  final List<ChapterEntity> chapters;
  final ChapterEntity? currentChapter;
  final ReadingHistoryEntity? history;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final bool hasReachedMax;

  ChapterState({
    this.isLoading = false,
    this.chapters = const [],
    this.currentChapter,
    this.history,
    this.error,
    this.lastDocument,
    this.hasReachedMax = false,
  });

  ChapterState copyWith({
    bool? isLoading,
    List<ChapterEntity>? chapters,
    ChapterEntity? currentChapter,
    ReadingHistoryEntity? history,
    String? error,
    DocumentSnapshot? lastDocument,
    bool? hasReachedMax,
  }) {
    return ChapterState(
      isLoading: isLoading ?? this.isLoading,
      chapters: chapters ?? this.chapters,
      currentChapter: currentChapter ?? this.currentChapter,
      history: history ?? this.history,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ChapterNotifier extends StateNotifier<ChapterState> {
  final Ref _ref;
  final GetListBooksChaptersUseCase _getListChaptersUseCase;
  final GetChapterUseCase _getChapterUseCase;
  final IncrementViewsUseCase _incrementViewsUseCase;
  final AddReadingHistoryUseCase _addReadingHistoryUseCase;
  final AddChapterUseCase _addChapterUseCase;
  final UpdateChapterUseCase _updateChapterUseCase;
  final DeleteChapterUseCase _deleteChapterUseCase;
  final GetBookByIdUseCase _getBookByIdUseCase;
  final UpdateBookUseCase _updateBookUseCase;

  ChapterNotifier({
    required Ref ref,
    required GetListBooksChaptersUseCase getListChaptersUseCase,
    required GetChapterUseCase getChapterUseCase,
    required IncrementViewsUseCase incrementViewsUseCase,
    required AddReadingHistoryUseCase addReadingHistoryUseCase,
    required GetReadingHistoryUseCase getReadingHistoryUseCase,
    required AddChapterUseCase addChapterUseCase,
    required UpdateChapterUseCase updateChapterUseCase,
    required DeleteChapterUseCase deleteChapterUseCase,
    required DeleteReadingHistoryUseCase deleteReadingHistoryUseCase,
    required GetBookByIdUseCase getBookByIdUseCase,
    required UpdateBookUseCase updateBookUseCase,
  }) : _ref = ref,
       _getListChaptersUseCase = getListChaptersUseCase,
       _getChapterUseCase = getChapterUseCase,
       _incrementViewsUseCase = incrementViewsUseCase,
       _addReadingHistoryUseCase = addReadingHistoryUseCase,
       _addChapterUseCase = addChapterUseCase,
       _updateChapterUseCase = updateChapterUseCase,
       _deleteChapterUseCase = deleteChapterUseCase,
       _getBookByIdUseCase = getBookByIdUseCase,
       _updateBookUseCase = updateBookUseCase,
       super(ChapterState());

  Future<void> fetchChapters(String bookId, {bool isRefresh = false}) async {
    if (state.isLoading || (state.hasReachedMax && !isRefresh)) return;
    state = state.copyWith(
      isLoading: true,
      error: null,
      chapters: isRefresh ? [] : state.chapters,
      hasReachedMax: isRefresh ? false : state.hasReachedMax,
    );
    final result = await _getListChaptersUseCase.call(bookId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (chapters) => state = state.copyWith(
        isLoading: false,
        chapters: chapters,
        hasReachedMax: true, // Vì hiện tại Repo trả về toàn bộ danh sách
      ),
    );
  }

  Future<void> refreshChapters(String bookId) async {
    state = ChapterState();
    await fetchChapters(bookId, isRefresh: true);
  }

  Future<void> loadChapterDetail(String bookId, String chapterId) async {
    state = state.copyWith(isLoading: true, error: null);
    final user = _ref.read(authProvider).user;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Vui lòng đăng nhập để tiếp tục đọc.',
      );
      return;
    }
    await _incrementViewsUseCase.call(bookId);
    final result = await _getChapterUseCase.call(bookId, chapterId, user.uid);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (chapter) async {
        await _addReadingHistoryUseCase.call(
          bookId,
          chapterId,
          user.uid,
          DateTime.now(),
        );

        state = state.copyWith(isLoading: false, currentChapter: chapter);
      },
    );
  }

  Future<void> addChapter(
    String bookId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _addChapterUseCase.call(
      bookId,
      title,
      content,
      orderIndex,
      isVip,
      price,
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        final bookResult = await _getBookByIdUseCase.call(bookId);
        bookResult.fold((_) => null, (book) async {
          await _updateBookUseCase.call(
            book.copyWith(quantity: book.quantity + 1),
          );
        });
        state = state.copyWith(isLoading: false);
        fetchChapters(bookId, isRefresh: true);
      },
    );
  }

  Future<void> updateChapter(
    String bookId,
    String chapterId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _updateChapterUseCase.call(
      bookId,
      chapterId,
      title,
      content,
      orderIndex,
      isVip,
      price,
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false);
        fetchChapters(bookId, isRefresh: true);
      },
    );
  }

  Future<void> deleteChapter(String bookId, String chapterId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _deleteChapterUseCase.call(bookId, chapterId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        final bookResult = await _getBookByIdUseCase.call(bookId);
        bookResult.fold((_) => null, (book) async {
          await _updateBookUseCase.call(
            book.copyWith(quantity: book.quantity - 1),
          );
        });
        state = state.copyWith(isLoading: false);
        fetchChapters(bookId, isRefresh: true);
      },
    );
  }
}

// 4. Provider chính để UI sử dụng
final chapterProvider = StateNotifierProvider<ChapterNotifier, ChapterState>((
  ref,
) {
  return ChapterNotifier(
    ref: ref,
    getListChaptersUseCase: ref.watch(getListChaptersUseCaseProvider),
    getChapterUseCase: ref.watch(getChapterUseCaseProvider),
    incrementViewsUseCase: ref.watch(incrementChapterViewsUseCaseProvider),
    addReadingHistoryUseCase: ref.watch(addReadingHistoryUseCaseProvider),
    getReadingHistoryUseCase: ref.watch(getReadingHistoryUseCaseProvider),
    addChapterUseCase: ref.watch(addChapterUseCaseProvider),
    updateChapterUseCase: ref.watch(updateChapterUseCaseProvider),
    deleteChapterUseCase: ref.watch(deleteChapterUseCaseProvider),
    deleteReadingHistoryUseCase: ref.watch(deleteReadingHistoryUseCaseProvider),
    getBookByIdUseCase: ref.watch(getBookByIdUseCaseProvider),
    updateBookUseCase: ref.watch(updateBookUseCaseProvider),
  );
});
