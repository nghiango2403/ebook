import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/get_bookmarked_books_usecase.dart';
import '../../domain/usecases/get_followed_books_usecase.dart';
import '../../domain/usecases/get_reading_history_usecase.dart';
import 'book_usecase_providers.dart';

final libraryProvider = AsyncNotifierProvider<LibraryNotifier, Map<String, List<BookEntity>>>(() {
  return LibraryNotifier();
});

class LibraryNotifier extends AsyncNotifier<Map<String, List<BookEntity>>> {
  @override
  Future<Map<String, List<BookEntity>>> build() async {
    // Mặc định load trang đầu tiên của cả 3 loại khi vào Library
    return {
      'bookmarked': await _fetchBookmarked(),
      'followed': await _fetchFollowed(),
      'history': await _fetchHistory(),
    };
  }

  Future<List<BookEntity>> _fetchBookmarked() async {
    final useCase = ref.read(getBookmarkedBooksUseCaseProvider);
    final userId = ref.read(authProvider).user?.uid ?? "";
    final result = await useCase(GetBookmarkedBooksParams(userId: userId));
    return result.getOrElse(() => []);
  }
  // Lấy danh sách truyện đang theo dõi
  Future<List<BookEntity>> _fetchFollowed() async {
    final useCase = ref.read(getFollowedBooksUseCaseProvider);
    final userId = ref.read(authProvider).user?.uid ?? "";

    if (userId.isEmpty) return [];

    final result = await useCase(GetFollowedBooksParams(
      userId: userId,
      pageSize: 20,
      offset: 0,
    ));

    return result.fold(
          (failure) => [], // Nếu lỗi trả về list rỗng
          (books) => books,
    );
  }

  // Lấy lịch sử truyện đã đọc
  Future<List<BookEntity>> _fetchHistory() async {
    final useCase = ref.read(getReadingHistoryUseCaseProvider);
    final userId = ref.read(authProvider).user?.uid ?? "";

    if (userId.isEmpty) return [];

    final result = await useCase(GetReadingHistoryParams(
      userId: userId,
      pageSize: 20,
      offset: 0,
    ));

    return result.fold(
          (failure) => [],
          (books) => books,
    );
  }
}