import 'package:flutter_riverpod/flutter_riverpod.dart';

// Layers
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';
import '../../domain/usecases/get_category_by_id_usecase.dart';

// --- 1. DataSources ---
final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
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
final getAllCategoriesUseCaseProvider = Provider<GetAllCategoriesUseCase>((ref) {
  return GetAllCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final getCategoryByIdUseCaseProvider = Provider<GetCategoryByIdUseCase>((ref) {
  return GetCategoryByIdUseCase(ref.watch(categoryRepositoryProvider));
});

// --- 4. UI Providers (Thành phần UI trực tiếp lắng nghe) ---

/// Provider lấy danh sách tất cả các danh mục.
/// Sử dụng FutureProvider để tự động xử lý trạng thái Loading/Error trên UI.
final categoriesListProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final useCase = ref.watch(getAllCategoriesUseCaseProvider);
  return await useCase.execute();
});

/// Provider lấy chi tiết danh mục dựa trên ID.
/// Sử dụng .family để truyền tham số [categoryId] từ UI.
final categoryDetailProvider = FutureProvider.family<CategoryEntity?, String>((ref, categoryId) async {
  if (categoryId.isEmpty) return null;

  final useCase = ref.watch(getCategoryByIdUseCaseProvider);
  return await useCase.execute(categoryId);
});