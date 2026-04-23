import 'package:flutter_riverpod/flutter_riverpod.dart';

// Layers
import '../../../auth/presentation/providers/auth_provider.dart'
    hide firestoreProvider;
import '../../../book/presentation/providers/book_usecase_providers.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';
import '../../domain/usecases/get_category_by_id_usecase.dart';

// --- 1. DataSources ---
final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  return CategoryRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

// --- 2. Repositories ---
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    remoteDataSource: ref.watch(categoryRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// --- 3. UseCases ---
final getAllCategoriesUseCaseProvider = Provider<GetAllCategoriesUseCase>((
  ref,
) {
  return GetAllCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final getCategoryByIdUseCaseProvider = Provider<GetCategoryByIdUseCase>((ref) {
  return GetCategoryByIdUseCase(ref.watch(categoryRepositoryProvider));
});

// --- 4. State ---
class CategoryState {
  final bool isLoading;
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final String? error;

  CategoryState({
    this.isLoading = false,
    this.categories = const [],
    this.selectedCategory,
    this.error,
  });

  CategoryState copyWith({
    bool? isLoading,
    List<CategoryEntity>? categories,
    CategoryEntity? selectedCategory,
    String? error,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      error: error,
    );
  }
}

// --- 5. Notifier ---
class CategoryNotifier extends StateNotifier<CategoryState> {
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final GetCategoryByIdUseCase _getCategoryByIdUseCase;

  CategoryNotifier({
    required GetAllCategoriesUseCase getAllCategoriesUseCase,
    required GetCategoryByIdUseCase getCategoryByIdUseCase,
  }) : _getAllCategoriesUseCase = getAllCategoriesUseCase,
       _getCategoryByIdUseCase = getCategoryByIdUseCase,
       super(CategoryState());

  Future<void> fetchAllCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _getAllCategoriesUseCase.execute();
      state = state.copyWith(isLoading: false, categories: categories);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchCategoryById(String categoryId) async {
    if (categoryId.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final category = await _getCategoryByIdUseCase.execute(categoryId);
      state = state.copyWith(isLoading: false, selectedCategory: category);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// --- 6. Main Provider ---
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) {
    return CategoryNotifier(
      getAllCategoriesUseCase: ref.watch(getAllCategoriesUseCaseProvider),
      getCategoryByIdUseCase: ref.watch(getCategoryByIdUseCaseProvider),
    );
  },
);

// --- 7. Backwards compatibility providers (Keep for now to avoid breaking UI) ---
final categoriesListProvider = FutureProvider<List<CategoryEntity>>((
  ref,
) async {
  final useCase = ref.watch(getAllCategoriesUseCaseProvider);
  return await useCase.execute();
});

final categoryDetailProvider = FutureProvider.family<CategoryEntity?, String>((
  ref,
  categoryId,
) async {
  if (categoryId.isEmpty) return null;
  final useCase = ref.watch(getCategoryByIdUseCaseProvider);
  return await useCase.execute(categoryId);
});
