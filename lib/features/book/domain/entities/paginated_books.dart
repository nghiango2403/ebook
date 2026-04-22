import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_entity.dart';

class BookListState {
  final List<BookEntity> books;
  final DocumentSnapshot? lastDoc;
  final bool isLoading;
  final bool hasReachedMax;

  BookListState({
    this.books = const [],
    this.lastDoc,
    this.isLoading = false,
    this.hasReachedMax = false,
  });

  BookListState copyWith({
    List<BookEntity>? books,
    DocumentSnapshot? lastDoc,
    bool? isLoading,
    bool? hasReachedMax,
  }) {
    return BookListState(
      books: books ?? this.books,
      lastDoc: lastDoc ?? this.lastDoc,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  factory BookListState.initial() => BookListState();
}