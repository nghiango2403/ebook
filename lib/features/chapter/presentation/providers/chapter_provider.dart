import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../book/domain/usecases/get_book_by_id_usecase.dart';
import '../../../book/domain/usecases/update_book_usecase.dart';
import '../../../book/presentation/providers/book_usecase_providers.dart';
import '../../../history/domain/entities/reading_history_entity.dart';
import '../../../history/domain/usecases/add_reading_history_usecase.dart';
import '../../../history/presentation/providers/reading_history_provider.dart';
import '../../data/datasources/chapter_remote_datasource.dart';
import '../../data/repositories/chapter_repository_impl.dart';
import '../../domain/entities/chapter_entity.dart';
import '../../domain/repositories/chapter_repository.dart';
import '../../domain/usecases/add_chapter_usecase.dart';
import '../../domain/usecases/delete_chapter_usecase.dart';
import '../../domain/usecases/get_chapter_usecase.dart';
import '../../domain/usecases/get_list_chapter_usecase.dart';
import '../../domain/usecases/increment_views_usecase.dart';
import '../../domain/usecases/update_chapter_usecase.dart';

// =============================================================================
// 1. Tầng DOMAIN (Providers cho các UseCases của Chapter)
// =============================================================================
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final chapterRemoteDataSourceProvider = Provider<ChapterRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return ChapterRemoteDataSourceImpl(firestore);
});

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  final remoteDataSource = ref.watch(chapterRemoteDataSourceProvider);
  return ChapterRepositoryImpl(remoteDataSource: remoteDataSource);
});

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
  return AddReadingHistoryUseCase(ref.watch(readingHistoryRepositoryProvider));
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
    required AddChapterUseCase addChapterUseCase,
    required UpdateChapterUseCase updateChapterUseCase,
    required DeleteChapterUseCase deleteChapterUseCase,
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
    if (!mounted || state.isLoading || (state.hasReachedMax && !isRefresh)) return;
    state = state.copyWith(
      isLoading: true,
      error: null,
      chapters: isRefresh ? [] : state.chapters,
      hasReachedMax: isRefresh ? false : state.hasReachedMax,
    );
    final result = await _getListChaptersUseCase.call(bookId);
    if (!mounted) return;
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
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    final user = _ref.read(authProvider).user;
    if (user == null) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Vui lòng đăng nhập để tiếp tục đọc.',
      );
      return;
    }
    await _incrementViewsUseCase.call(bookId);
    final result = await _getChapterUseCase.call(bookId, chapterId, user.uid);
    if (!mounted) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (chapter) async {
        await _addReadingHistoryUseCase.call(
          bookId,
          chapterId,
          user.uid,
          chapter.title,
          chapter.orderIndex,
          DateTime.now(),
        );

        if (!mounted) return;

        // Làm mới danh sách lịch sử ở LibraryScreen
        _ref.invalidate(readingHistoryProvider);

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
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _addChapterUseCase.call(
      bookId,
      title,
      content,
      orderIndex,
      isVip,
      price,
    );
    if (!mounted) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        final bookResult = await _getBookByIdUseCase.call(bookId);
        if (!mounted) return;
        bookResult.fold((_) => null, (book) async {
          await _updateBookUseCase.call(
            book.copyWith(quantity: book.quantity + 1),
          );
        });
        if (!mounted) return;
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
    if (!mounted) return;
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
    if (!mounted) return;
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
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _deleteChapterUseCase.call(bookId, chapterId);
    if (!mounted) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        final bookResult = await _getBookByIdUseCase.call(bookId);
        if (!mounted) return;
        bookResult.fold((_) => null, (book) async {
          await _updateBookUseCase.call(
            book.copyWith(quantity: book.quantity - 1),
          );
        });
        if (!mounted) return;
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
    addChapterUseCase: ref.watch(addChapterUseCaseProvider),
    updateChapterUseCase: ref.watch(updateChapterUseCaseProvider),
    deleteChapterUseCase: ref.watch(deleteChapterUseCaseProvider),
    getBookByIdUseCase: ref.watch(getBookByIdUseCaseProvider),
    updateBookUseCase: ref.watch(updateBookUseCaseProvider),
  );
});

/// Provider cung cấp thông tin chương sẽ đọc tiếp theo (lịch sử hoặc chương 1)
final bookReadingProgressProvider =
    FutureProvider.family<({String? chapterId, bool isHistory}), String>((
      ref,
      bookId,
    ) async {
      final user = ref.watch(authProvider).user;
      // Theo dõi toàn bộ lịch sử để cập nhật khi user đọc chương mới
      ref.watch(readingHistoryProvider);

      String? targetId;
      bool isHistory = false;

      if (user != null) {
        final history = await ref
            .read(readingHistoryProvider.notifier)
            .getReadingHistory(bookId, user.uid);
        if (history != null) {
          targetId = history.chapterId;
          isHistory = true;
        }
      }

      if (targetId == null) {
        final result = await ref
            .read(getListChaptersUseCaseProvider)
            .call(bookId);
        targetId = result.fold(
          (failure) => null,
          (chapters) {
            if (chapters.isEmpty) return null;
            final sorted = [...chapters]
              ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
            return sorted.first.id;
          },
        );
      }

      return (chapterId: targetId, isHistory: isHistory);
    });
