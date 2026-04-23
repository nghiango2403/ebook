import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../book/presentation/providers/book_usecase_providers.dart';
import '../../domain/entities/chapter_entity.dart';
import '../../domain/entities/reading_history_entity.dart';
import '../../domain/usecases/add_chapter_usecase.dart';
import '../../domain/usecases/add_reading_history_usecase.dart';
import '../../domain/usecases/delete_chapter_usecase.dart';
import '../../domain/usecases/delete_reading_history_usecase.dart';
import '../../domain/usecases/get_chapter_usecase.dart';
import '../../domain/usecases/get_list_chapter_usecase.dart';
import '../../domain/usecases/get_reading_history_usecase.dart';
import '../../domain/usecases/increment_views_usecase.dart';
import '../../domain/usecases/update_chapter_usecase.dart';
import '../../domain/usecases/update_reading_history_usecase.dart';

// 1. Cung cấp Usecases thông qua Providers
final getListChaptersUseCaseProvider = Provider((ref) {
  return GetListBooksChaptersUseCase(ref.watch(chapterRepositoryProvider));
});

final getChapterUseCaseProvider = Provider((ref) {
  return GetChapterUseCase(ref.watch(chapterRepositoryProvider));
});

final addChapterUseCaseProvider = Provider((ref) {
  return AddChapterUseCase(ref.watch(chapterRepositoryProvider));
});

final deleteChapterUseCaseProvider = Provider((ref) {
  return DeleteChapterUseCase(ref.watch(chapterRepositoryProvider));
});

final updateChapterUseCaseProvider = Provider((ref) {
  return UpdateChapterUseCase(ref.watch(chapterRepositoryProvider));
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

final deleteReadingHistoryUseCaseProvider = Provider((ref) {
  return DeleteReadingHistoryUseCase(ref.watch(chapterRepositoryProvider));
});

final updateReadingHistoryUseCaseProvider = Provider((ref) {
  return UpdateReadingHistoryUseCase(ref.watch(chapterRepositoryProvider));
});

// 2. Trạng thái của Chapter (ChapterState)
class ChapterState {
  final bool isLoading;
  final List<ChapterEntity> chapters;
  final ChapterEntity? currentChapter;
  final ReadingHistoryEntity? history;
  final String? error;

  ChapterState({
    this.isLoading = false,
    this.chapters = const [],
    this.currentChapter,
    this.history,
    this.error,
  });

  ChapterState copyWith({
    bool? isLoading,
    List<ChapterEntity>? chapters,
    ChapterEntity? currentChapter,
    ReadingHistoryEntity? history,
    String? error,
  }) {
    return ChapterState(
      isLoading: isLoading ?? this.isLoading,
      chapters: chapters ?? this.chapters,
      currentChapter: currentChapter ?? this.currentChapter,
      history: history ?? this.history,
      error: error,
    );
  }
}

// 3. Notifier quản lý logic Chapter
class ChapterNotifier extends StateNotifier<ChapterState> {
  final GetListBooksChaptersUseCase _getListChaptersUseCase;
  final GetChapterUseCase _getChapterUseCase;
  final IncrementViewsUseCase _incrementViewsUseCase;
  final AddReadingHistoryUseCase _addReadingHistoryUseCase;
  final GetReadingHistoryUseCase _getReadingHistoryUseCase;
  final AddChapterUseCase _addChapterUseCase;
  final UpdateChapterUseCase _updateChapterUseCase;
  final DeleteChapterUseCase _deleteChapterUseCase;
  final UpdateReadingHistoryUseCase _updateReadingHistoryUseCase;
  final DeleteReadingHistoryUseCase _deleteReadingHistoryUseCase;

  ChapterNotifier({
    required GetListBooksChaptersUseCase getListChaptersUseCase,
    required GetChapterUseCase getChapterUseCase,
    required IncrementViewsUseCase incrementViewsUseCase,
    required AddReadingHistoryUseCase addReadingHistoryUseCase,
    required GetReadingHistoryUseCase getReadingHistoryUseCase,
    required AddChapterUseCase addChapterUseCase,
    required UpdateChapterUseCase updateChapterUseCase,
    required DeleteChapterUseCase deleteChapterUseCase,
    required UpdateReadingHistoryUseCase updateReadingHistoryUseCase,
    required DeleteReadingHistoryUseCase deleteReadingHistoryUseCase,
  })  : _getListChaptersUseCase = getListChaptersUseCase,
        _getChapterUseCase = getChapterUseCase,
        _incrementViewsUseCase = incrementViewsUseCase,
        _addReadingHistoryUseCase = addReadingHistoryUseCase,
        _getReadingHistoryUseCase = getReadingHistoryUseCase,
        _addChapterUseCase = addChapterUseCase,
        _updateChapterUseCase = updateChapterUseCase,
        _deleteChapterUseCase = deleteChapterUseCase,
        _updateReadingHistoryUseCase = updateReadingHistoryUseCase,
        _deleteReadingHistoryUseCase = deleteReadingHistoryUseCase,
        super(ChapterState());

  // Lấy danh sách chương
  Future<void> fetchChapters(String bookId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getListChaptersUseCase.call(bookId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (chapters) =>
          state = state.copyWith(isLoading: false, chapters: chapters),
    );
  }

  // Lấy nội dung chương và cập nhật lịch sử
  Future<void> loadChapterDetail(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    // 1. Tăng view
    await _incrementViewsUseCase.call(bookId);

    // 2. Lấy chi tiết chương
    final result = await _getChapterUseCase.call(bookId, chapterId, userId);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        // 3. Lưu lịch sử đọc
        if (userId.isNotEmpty) {
          await _addReadingHistoryUseCase.call(
            bookId,
            chapterId,
            userId,
            DateTime.now(),
          );
        }

        // Tìm chương trong danh sách đã load để cập nhật currentChapter
        try {
          final chapter = state.chapters.firstWhere((c) => c.id == chapterId);
          state = state.copyWith(isLoading: false, currentChapter: chapter);
        } catch (e) {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }

  // Lấy lịch sử đọc của một truyện cụ thể
  Future<void> fetchReadingHistory(String bookId, String userId) async {
    if (userId.isEmpty) return;
    final result = await _getReadingHistoryUseCase.call(bookId, userId);
    result.fold(
      (failure) => null, // Không quan trọng nếu không có lịch sử
      (history) => state = state.copyWith(history: history),
    );
  }

  // --- Quản lý chương (Admin/Author) ---

  Future<void> addChapter(String bookId, String title, String content) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _addChapterUseCase.call(bookId, title, content);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false);
        fetchChapters(bookId); // Reload danh sách
      },
    );
  }

  Future<void> updateChapter(
    String bookId,
    String chapterId,
    String title,
    String content,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    final result =
        await _updateChapterUseCase.call(bookId, chapterId, title, content);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false);
        fetchChapters(bookId);
      },
    );
  }

  Future<void> deleteChapter(String bookId, String chapterId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _deleteChapterUseCase.call(bookId, chapterId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false);
        fetchChapters(bookId);
      },
    );
  }

  // --- Quản lý lịch sử đọc bổ sung ---

  Future<void> updateReadingHistory(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    final result = await _updateReadingHistoryUseCase.call(
      bookId,
      chapterId,
      userId,
      DateTime.now(),
    );
    if (result.isRight()) {
      fetchReadingHistory(bookId, userId);
    }
  }

  Future<void> deleteReadingHistory(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    final result =
        await _deleteReadingHistoryUseCase.call(bookId, chapterId, userId);
    if (result.isRight()) {
      state = state.copyWith(history: null);
    }
  }
}

// 4. Provider chính để UI sử dụng
final chapterProvider = StateNotifierProvider<ChapterNotifier, ChapterState>((
  ref,
) {
  return ChapterNotifier(
    getListChaptersUseCase: ref.watch(getListChaptersUseCaseProvider),
    getChapterUseCase: ref.watch(getChapterUseCaseProvider),
    incrementViewsUseCase: ref.watch(incrementChapterViewsUseCaseProvider),
    addReadingHistoryUseCase: ref.watch(addReadingHistoryUseCaseProvider),
    getReadingHistoryUseCase: ref.watch(getReadingHistoryUseCaseProvider),
    addChapterUseCase: ref.watch(addChapterUseCaseProvider),
    updateChapterUseCase: ref.watch(updateChapterUseCaseProvider),
    deleteChapterUseCase: ref.watch(deleteChapterUseCaseProvider),
    updateReadingHistoryUseCase: ref.watch(updateReadingHistoryUseCaseProvider),
    deleteReadingHistoryUseCase: ref.watch(deleteReadingHistoryUseCaseProvider),
  );
});
