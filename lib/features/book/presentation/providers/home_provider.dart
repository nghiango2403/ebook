import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../category/domain/entities/category_entity.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/book_status.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/search_books_usecase.dart';
import '../model/book_view_model.dart';
import 'book_usecase_providers.dart';
import '../../../category/presentation/providers/category_provider.dart';

// 1. Trạng thái của Home (HomeState)
class HomeState {
  final bool isLoading;
  final List<BookViewModel> recentlyUpdated;
  final List<BookViewModel> newlyUploaded;
  final List<BookViewModel> newlyCompleted;
  final String? error;

  HomeState({
    this.isLoading = false,
    this.recentlyUpdated = const [],
    this.newlyUploaded = const [],
    this.newlyCompleted = const [],
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    List<BookViewModel>? recentlyUpdated,
    List<BookViewModel>? newlyUploaded,
    List<BookViewModel>? newlyCompleted,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      recentlyUpdated: recentlyUpdated ?? this.recentlyUpdated,
      newlyUploaded: newlyUploaded ?? this.newlyUploaded,
      newlyCompleted: newlyCompleted ?? this.newlyCompleted,
      error: error,
    );
  }
}

// 2. Notifier quản lý logic Home
class HomeNotifier extends StateNotifier<HomeState> {
  final SearchBooksUseCase _searchBooksUseCase;
  final Ref _ref;

  HomeNotifier({
    required SearchBooksUseCase searchBooksUseCase,
    required Ref ref,
  })  : _searchBooksUseCase = searchBooksUseCase,
        _ref = ref,
        super(HomeState());

  List<BookViewModel> _mapBooksWithCategory(List<CategoryEntity> categories, List<BookEntity> books) {
    return books.map((book) {
      final CategoryEntity? category = categories.cast<CategoryEntity?>().firstWhere(
            (cat) => cat?.id == book.categoryId,
        orElse: () => null,
      );
      return BookViewModel(book: book, category: category);
    }).toList();
  }

  Future<void> fetchHomeData() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _ref.read(categoriesListProvider.future);

      final results = await Future.wait([
        _searchBooksUseCase(SearchBooksParams(
          pageSize: 10,
          offset: 0,
          sortBy: BookSortType.recentlyUpdated,
        )),
        _searchBooksUseCase(SearchBooksParams(
          pageSize: 10,
          offset: 0,
          sortBy: BookSortType.newlyUploaded,
        )),
        _searchBooksUseCase(SearchBooksParams(
          pageSize: 10,
          offset: 0,
          status: BookStatus.completed,
          sortBy: BookSortType.newlyCompleted,
        )),
      ]);

      if (!mounted) return;

      final recentlyUpdated = results[0].fold((f) => <BookViewModel>[], (b) => _mapBooksWithCategory(categories, b));
      final newlyUploaded = results[1].fold((f) => <BookViewModel>[], (b) => _mapBooksWithCategory(categories, b));
      final newlyCompleted = results[2].fold((f) => <BookViewModel>[], (b) => _mapBooksWithCategory(categories, b));

      state = state.copyWith(
        isLoading: false,
        recentlyUpdated: recentlyUpdated,
        newlyUploaded: newlyUploaded,
        newlyCompleted: newlyCompleted,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 3. Provider chính để UI sử dụng
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final notifier = HomeNotifier(
    searchBooksUseCase: ref.watch(searchBooksUseCaseProvider),
    ref: ref,
  );
  // Tự động load dữ liệu khi khởi tạo
  Future.microtask(() => notifier.fetchHomeData());
  return notifier;
});
