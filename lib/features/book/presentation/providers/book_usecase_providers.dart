import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebook/features/book/domain/usecases/is_bookmarked_usecase.dart';
import 'package:ebook/features/book/domain/usecases/is_followed_book_usecase.dart';
import 'package:ebook/features/book/domain/usecases/toggle_follow_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chapter/data/datasources/chapter_remote_datasource.dart';
import '../../../chapter/data/repositories/chapter_repository_impl.dart';
import '../../../chapter/domain/repositories/chapter_repository.dart';
import '../../../chapter/domain/usecases/get_list_reading_history_usecase.dart';
import '../../data/datasources/book_remote_data_source.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/get_book_by_id_usecase.dart';
import '../../domain/usecases/get_bookmarked_books_usecase.dart';
import '../../domain/usecases/get_followed_books_usecase.dart';
import '../../domain/usecases/search_books_usecase.dart';
import '../../domain/usecases/toggle_bookmark_usecase.dart';

// 1. Tạo Provider cho Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// 2. Tầng Data Source
final bookRemoteDataSourceProvider = Provider<BookRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return BookRemoteDataSourceImpl(firestore);
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

// 3. Tầng Repository
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final remoteDataSource = ref.watch(bookRemoteDataSourceProvider);
  return BookRepositoryImpl(remoteDataSource: remoteDataSource);
});

// 4. Tầng Usecases (Nơi tập trung các logic nghiệp vụ)

final searchBooksUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return SearchBooksUseCase(repository);
});

final getBookByIdUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return GetBookByIdUseCase(repository);
});

// Usecase Nghĩa vừa yêu cầu
final getBookmarkedBooksUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return GetBookmarkedBooksUseCase(repository);
});

final getFollowedBooksUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return GetFollowedBooksUseCase(repository);
});

final getListReadingHistoryUseCaseProvider = Provider((ref) {
  final repository = ref.watch(chapterRepositoryProvider);
  return GetListReadingHistoryUseCase(repository);
});

final toggleBookmarkUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return ToggleBookmarkUseCase(repository);
});

final toggleFollowBooksUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return ToggleFollowUseCase(repository);
});

final isBookmarkUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return IsBookmarkedUsecase(repository);
});

final isFollowBookUseCaseProvider = Provider((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return IsFollowedBookUsecase(repository);
});
