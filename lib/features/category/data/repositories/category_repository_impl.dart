import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../../../../core/network/network_info.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  CategoryRepositoryImpl({
    required CategoryRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    if (await _networkInfo.isConnected) {
      final models = await _remoteDataSource.getAllCategories();
      return models.map((model) => model as CategoryEntity).toList();
    } else {
      throw Exception("Không có kết nối internet");
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    if (await _networkInfo.isConnected) {
      final b = await _remoteDataSource.getCategoryById(id);
      return b;
    } else {
      throw Exception("Không có kết nối internet");
    }
  }
}