import 'dart:async';

import 'package:ebook/features/auth/presentation/providers/auth_provider.dart';
import 'package:ebook/features/book/domain/usecases/toggle_follow_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../category/domain/entities/category_entity.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';
import '../model/book_view_model.dart';
import 'book_usecase_providers.dart';
import 'library_provider.dart';

final bookDetailProvider = FutureProvider.family<BookViewModel, String>((ref, bookId) async {
  final getBookByIdUseCase = ref.watch(getBookByIdUseCaseProvider);
  final getCategoryByIdUseCase = ref.watch(getCategoryByIdUseCaseProvider);
  final isBookmarkedUseCase = ref.watch(isBookmarkUseCaseProvider);
  final isFollowedBookUseCase = ref.watch(isFollowBookUseCaseProvider);

  final userId = ref.watch(authProvider).user?.uid;

  final result = await getBookByIdUseCase.call(bookId);
  final bookEntity = result.fold(
        (failure) => throw failure,
        (book) => book,
  );
  CategoryEntity? category;
  if (bookEntity.categoryId.isNotEmpty) {
    category = await getCategoryByIdUseCase.execute(bookEntity.categoryId);
  }

  bool isBookmarked = false;
  if (userId != null) {
    final result = await isBookmarkedUseCase.execute(userId, bookId);
    isBookmarked = result.fold((failure)=>false, (success) => success);
  }

  bool isFollowed = false;
  if (userId != null) {
    final result = await isFollowedBookUseCase.execute(userId, bookId);
    isFollowed = result.fold((failure) => false, (success) => success);
  }

  return BookViewModel(
    book: bookEntity,
    category: category,
    isBookmarked: isBookmarked,
    isFollowed: isFollowed
  );
});

final bookInteractionProvider = AsyncNotifierProvider<BookInteractionNotifier, void>(() {
  return BookInteractionNotifier();
});

class BookInteractionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggleBookmark(String bookId) async {
    DateTime createAt = DateTime.now();
    String? userId = ref.watch(authProvider).user?.uid;
    if(userId == null){
      state = AsyncError("Người dùng chưa đăng nhập", StackTrace.current);
      return;
    }
    final useCase = ref.read(toggleBookmarkUseCaseProvider);
    final result = await useCase(ToggleBookmarkParams(bookId: bookId, userId: userId, createdAt: createAt));

    if (result.isLeft()) {
      // Xử lý lỗi nếu cần
    } else {
      ref.invalidate(libraryProvider);
      ref.invalidate(bookDetailProvider(bookId));
    }
  }
  Future<void> toggleFollowBook(String bookId) async{
    DateTime createAt = DateTime.now();
    String? userId = ref.watch(authProvider).user?.uid;
    if(userId == null){
      state = AsyncError("Người dùng chưa đăng nhập", StackTrace.current);
      return;
    }
    final useCase = ref.read(toggleFollowBooksUseCaseProvider);
    final result = await useCase(ToggleFollowParams(bookId: bookId, userId: userId, createAt: createAt));
    if (result.isLeft()) {
      // Xử lý lỗi nếu cần
    } else {
      ref.invalidate(libraryProvider);
      ref.invalidate(bookDetailProvider(bookId));
    }
  }
}