import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/reading_history_remote_datasource.dart';
import '../../data/repositories/reading_history_repository_impl.dart';
import '../../domain/entities/reading_history_entity.dart';
import '../../domain/repositories/reading_history_repository.dart';
import '../../domain/usecases/delete_reading_history_usecase.dart';
import '../../domain/usecases/get_list_reading_history_usecase.dart';
import '../../domain/usecases/get_reading_history_usecase.dart';

// =============================================================================
// 1. Tầng DOMAIN & DATA (Providers)
// =============================================================================

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final readingHistoryRemoteDataSourceProvider =
    Provider<ReadingHistoryRemoteDataSource>((ref) {
      final firestore = ref.watch(firestoreProvider);
      return ReadingHistoryRemoteDataSourceImpl(firestore);
    });

final readingHistoryRepositoryProvider = Provider<ReadingHistoryRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(readingHistoryRemoteDataSourceProvider);
  return ReadingHistoryRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getReadingHistoryUseCaseProvider = Provider((ref) {
  return GetReadingHistoryUseCase(ref.watch(readingHistoryRepositoryProvider));
});

final getListReadingHistoryUseCaseProvider = Provider((ref) {
  return GetListReadingHistoryUseCase(
    ref.watch(readingHistoryRepositoryProvider),
  );
});

final deleteReadingHistoryUseCaseProvider = Provider((ref) {
  return DeleteReadingHistoryUseCase(
    ref.watch(readingHistoryRepositoryProvider),
  );
});

// =============================================================================
// 2. Tầng PRESENTATION (State và Notifier)
// =============================================================================

class ReadingHistoryState {
  final bool isLoading;
  final List<ReadingHistoryEntity> histories;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final bool hasReachedMax;

  ReadingHistoryState({
    this.isLoading = false,
    this.histories = const [],
    this.error,
    this.lastDocument,
    this.hasReachedMax = false,
  });

  ReadingHistoryState copyWith({
    bool? isLoading,
    List<ReadingHistoryEntity>? histories,
    String? error,
    DocumentSnapshot? lastDocument,
    bool? hasReachedMax,
  }) {
    return ReadingHistoryState(
      isLoading: isLoading ?? this.isLoading,
      histories: histories ?? this.histories,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ReadingHistoryNotifier extends StateNotifier<ReadingHistoryState> {
  final GetListReadingHistoryUseCase _getListReadingHistoryUseCase;
  final DeleteReadingHistoryUseCase _deleteReadingHistoryUseCase;

  ReadingHistoryNotifier({
    required GetListReadingHistoryUseCase getListReadingHistoryUseCase,
    required DeleteReadingHistoryUseCase deleteReadingHistoryUseCase,
  }) : _getListReadingHistoryUseCase = getListReadingHistoryUseCase,
       _deleteReadingHistoryUseCase = deleteReadingHistoryUseCase,
       super(ReadingHistoryState());

  Future<void> fetchReadingHistories(
    String userId, {
    bool isRefresh = false,
  }) async {
    if (!mounted || state.isLoading || (state.hasReachedMax && !isRefresh)) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      histories: isRefresh ? [] : state.histories,
      hasReachedMax: isRefresh ? false : state.hasReachedMax,
      lastDocument: isRefresh ? null : state.lastDocument,
    );

    final int pageSize = 10;
    final result = await _getListReadingHistoryUseCase.call(
      userId,
      pageSize,
      isRefresh ? null : state.lastDocument,
    );

    if (!mounted) return;

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (data) {
        final histories = data.$1;
        final lastDoc = data.$2;
        state = state.copyWith(
          isLoading: false,
          histories: isRefresh ? histories : [...state.histories, ...histories],
          lastDocument: lastDoc,
          hasReachedMax: histories.length < pageSize,
        );
      },
    );
  }

  Future<void> deleteHistory(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    final result = await _deleteReadingHistoryUseCase.call(
      bookId,
      chapterId,
      userId,
    );
    if (!mounted) return;
    result.fold((failure) => state = state.copyWith(error: failure.message), (
      _,
    ) {
      state = state.copyWith(
        histories: state.histories.where((h) => h.bookId != bookId).toList(),
      );
    });
  }
}

final readingHistoryProvider =
    StateNotifierProvider<ReadingHistoryNotifier, ReadingHistoryState>((ref) {
      final notifier = ReadingHistoryNotifier(
        getListReadingHistoryUseCase: ref.watch(
          getListReadingHistoryUseCaseProvider,
        ),
        deleteReadingHistoryUseCase: ref.watch(
          deleteReadingHistoryUseCaseProvider,
        ),
      );

      final userId = ref.watch(authProvider).user?.uid;
      if (userId != null) {
        Future.microtask(() => notifier.fetchReadingHistories(userId));
      }

      return notifier;
    });
