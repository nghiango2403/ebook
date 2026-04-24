import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebook/features/book/domain/usecases/get_book_by_id_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/book_status.dart';
import '../../domain/usecases/add_book_usecase.dart';
import '../../domain/usecases/get_mybooks_usecase.dart';
import '../../domain/usecases/hidden_book_usecase.dart';
import '../../domain/usecases/unhidden_book_usecase.dart';
import '../../domain/usecases/update_book_status_usecase.dart';
import '../../domain/usecases/update_book_usecase.dart';
import 'book_usecase_providers.dart';

// --- 1. Trạng thái của Book Management (BookState) ---
class BookState {
  final bool isLoading;
  final List<BookEntity> myBooks;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final bool hasReachedMax;
  final BookEntity? selectedBook;

  BookState({
    this.isLoading = false,
    this.myBooks = const [],
    this.error,
    this.lastDocument,
    this.hasReachedMax = false,
    this.selectedBook,
  });

  BookState copyWith({
    bool? isLoading,
    List<BookEntity>? myBooks,
    String? error,
    DocumentSnapshot? lastDocument,
    bool? hasReachedMax,
    BookEntity? selectedBook,
  }) {
    return BookState(
      isLoading: isLoading ?? this.isLoading,
      myBooks: myBooks ?? this.myBooks,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      selectedBook: selectedBook ?? this.selectedBook,
    );
  }
}

// --- 2. Notifier quản lý logic Book Management ---
class BookNotifier extends StateNotifier<BookState> {
  final Ref _ref;
  final AddBookUseCase _addBookUseCase;
  final HiddenBookUseCase _hiddenBookUseCase;
  final UnHiddenBookUseCase _unHiddenBookUseCase;
  final GetMyBooksUseCase _getMyBooksUseCase;
  final GetBookByIdUseCase _getBookByIdUseCase;
  final UpdateBookUseCase _updateBookUseCase;
  final UpdateBookStatusUseCase _updateBookStatusUseCase;

  static const int _pageSize = 10;

  BookNotifier({
    required Ref ref,
    required AddBookUseCase addBookUseCase,
    required HiddenBookUseCase hiddenBookUseCase,
    required UnHiddenBookUseCase unHiddenBookUseCase,
    required GetMyBooksUseCase getMyBooksUseCase,
    required GetBookByIdUseCase getBookByIdUseCase,
    required UpdateBookUseCase updateBookUseCase,
    required UpdateBookStatusUseCase updateBookStatusUseCase,
  }) : _ref = ref,
       _addBookUseCase = addBookUseCase,
       _hiddenBookUseCase = hiddenBookUseCase,
       _unHiddenBookUseCase = unHiddenBookUseCase,
       _getMyBooksUseCase = getMyBooksUseCase,
       _getBookByIdUseCase = getBookByIdUseCase,
       _updateBookUseCase = updateBookUseCase,
       _updateBookStatusUseCase = updateBookStatusUseCase,
       super(BookState());

  String? get _userId => _ref.read(authProvider).user?.uid;

  Future<void> fetchMyBooks({bool isRefresh = false}) async {
    final userId = _userId;
    if (userId == null) {
      if (!mounted) return;
      state = state.copyWith(error: "Người dùng chưa đăng nhập");
      return;
    }

    if (!mounted || state.isLoading || (state.hasReachedMax && !isRefresh)) return;

    state = state.copyWith(isLoading: true, error: null);

    final lastDoc = isRefresh ? null : state.lastDocument;
    final result = await _getMyBooksUseCase(userId, _pageSize, lastDoc);

    if (!mounted) return;

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (data) {
        final books = data.$1;
        final lastDoc = data.$2;

        final List<BookEntity> currentBooks =
            isRefresh ? [] : List.from(state.myBooks);
        currentBooks.addAll(books);

        state = state.copyWith(
          isLoading: false,
          myBooks: currentBooks,
          lastDocument: lastDoc,
          hasReachedMax: books.length < _pageSize,
        );
      },
    );
  }

  Future<void> fetchMyBookById(String bookId) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getBookByIdUseCase(bookId);
    if (!mounted) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (book) {
        state = state.copyWith(isLoading: false, selectedBook: book);
      },
    );
  }

  // Hàm helper để reset và load lại từ đầu
  Future<void> refreshMyBooks() async {
    state = BookState();
    await fetchMyBooks(isRefresh: true);
  }

  Future<void> addBook({
    required String title,
    required String description,
    required String imageUrl,
    required String categoryId,
    required String authorName,
  }) async {
    final userId = _userId;
    if (userId == null || !mounted) return;

    state = state.copyWith(isLoading: true, error: null);

    // Tạo một id ngẫu nhiên cho book nếu cần, hoặc để Firestore tự tạo.
    // Ở đây AddBookUseCase hiện tại đang nhận String bookId, tôi sẽ sửa logic này hoặc tạo id trước.
    final String bookId = FirebaseFirestore.instance
        .collection('books')
        .doc()
        .id;

    final book = BookEntity(
      id: bookId,
      title: title,
      description: description,
      authorId: userId,
      authorName: authorName,
      imageUrl: imageUrl,
      categoryId: categoryId,
      views: 0,
      quantity: 0,
      status: BookStatus.ongoing,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      viewsDay: 0,
      viewsWeek: 0,
      totalBookmarks: 0,
      totalFollows: 0,
      isHidden: false,
    );

    final result = await _addBookUseCase(bookId); // Theo code hiện tại của bạn

    if (!mounted) return;

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) async {
        // Sau khi tạo document với ID, cập nhật dữ liệu chi tiết
        await _updateBookUseCase(book);
        if (!mounted) return;
        state = state.copyWith(isLoading: false);
        fetchMyBooks(isRefresh: true);
      },
    );
  }

  Future<void> hideBook(String bookId) async {
    if (_userId == null || !mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _hiddenBookUseCase(bookId);
    if (!mounted) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false);
        fetchMyBooks(isRefresh: true);
      },
    );
  }

  Future<void> unHideBook(String bookId) async {
    if (_userId == null || !mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _unHiddenBookUseCase(bookId);
    if (!mounted) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false);
        fetchMyBooks(isRefresh: true);
      },
    );
  }

  Future<void> updateBook(BookEntity book) async {
    if (_userId == null || !mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _updateBookUseCase(book);
    if (!mounted) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false);
        fetchMyBooks(isRefresh: true);
      },
    );
  }

  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    if (_userId == null || !mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _updateBookStatusUseCase(bookId, status);
    if (!mounted) return;
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false);
        fetchMyBooks(isRefresh: true);
      },
    );
  }
}

// --- 3. Provider chính để UI sử dụng ---
final bookProvider = StateNotifierProvider<BookNotifier, BookState>((ref) {
  return BookNotifier(
    ref: ref,
    addBookUseCase: ref.watch(addBookUseCaseProvider),
    hiddenBookUseCase: ref.watch(hiddenBookUseCaseProvider),
    unHiddenBookUseCase: ref.watch(unHiddenBookUseCaseProvider),
    getMyBooksUseCase: ref.watch(getMyBooksUseCaseProvider),
    getBookByIdUseCase: ref.watch(getBookByIdUseCaseProvider),
    updateBookUseCase: ref.watch(updateBookUseCaseProvider),
    updateBookStatusUseCase: ref.watch(updateBookStatusUseCaseProvider),
  );
});
