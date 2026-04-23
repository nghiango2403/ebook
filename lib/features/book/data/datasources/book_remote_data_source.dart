import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/book_status.dart';
import '../../domain/repositories/book_repository.dart';
import '../models/book_model.dart';
import '../models/comment_model.dart';

abstract class BookRemoteDataSource {
  Future<BookModel> getBookById(String id);

  Future<List<BookModel>> searchBooks({
    required int pageSize,
    required int offset,
    String? searchValues,
    String? searchDescription,
    int? minChapters,
    String? category,
    BookStatus? status,
    required BookSortType sortBy,
  });

  Future<List<CommentModel>> getComments(String bookId);

  Future<String> getBookDescription(String bookId);

  Future<List<BookModel>> getBooksByAuthor(
    String authorName,
    String excludedBookId,
  );

  Future<void> toggleBookmark(String bookId, String userId, DateTime createAt);

  Future<List<BookModel>> getReadingHistory(
    String userId,
    int pageSize,
    int offset,
  );

  Future<List<BookModel>> getFollowedBooks(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
    String searchValues,
  );

  Future<void> toggleFollow(String bookId, String userId, DateTime createAt);

  Future<List<BookModel>> getBookmarkedBooks(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
    String searchValues,
  );

  Future<bool> isBookmarked(String userId, String bookId);

  Future<bool> isFollowed(String userId, String bookId);

  Future<void> addBook(String bookId);

  Future<void> hiddenBook(String bookId);

  Future<void> updateBook(BookModel book);

  Future<void> updateBookStatus(String bookId, BookStatus status);

  Future<List<BookModel>> getMyBooks(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
  );

  Future<void> unHiddenBook(String bookId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final FirebaseFirestore firestore;

  BookRemoteDataSourceImpl(this.firestore);

  @override
  Future<BookModel> getBookById(String id) async {
    final doc = await firestore.collection('books').doc(id).get();
    return BookModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<List<BookModel>> searchBooks({
    required int pageSize,
    required int offset,
    String? searchValues,
    String? searchDescription,
    int? minChapters,
    String? category,
    BookStatus? status,
    required BookSortType sortBy,
  }) async {
    Query query = firestore.collection('books');

    if (category != null)
      query = query.where('categoryId', isEqualTo: category);
    if (status != null) query = query.where('status', isEqualTo: status.label);
    if (minChapters != null)
      query = query.where('quantity', isGreaterThan: minChapters);

    switch (sortBy) {
      case BookSortType.newlyUploaded:
        query = query.orderBy('createdAt', descending: true);
        break;
      case BookSortType.mostViewedDay:
        query = query.orderBy('viewsDay', descending: true);
        break;
      case BookSortType.mostViewedWeek:
        query = query.orderBy('viewsWeek', descending: true);
        break;
      case BookSortType.mostBookmarked:
        query = query.orderBy('totalBookmarks', descending: true);
        break;
      default:
        query = query.orderBy('views', descending: true);
    }

    final snapshot = await query.limit(pageSize).get();
    return snapshot.docs
        .map(
          (doc) =>
              BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  @override
  Future<List<CommentModel>> getComments(String bookId) async {
    final snapshot = await firestore
        .collection('books')
        .doc(bookId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<String> getBookDescription(String bookId) async {
    final doc = await firestore.collection('books').doc(bookId).get();
    return doc.data()?['description'] ?? '';
  }

  @override
  Future<List<BookModel>> getBooksByAuthor(
    String authorName,
    String excludedBookId,
  ) async {
    final snapshot = await firestore
        .collection('books')
        .where('authorName', isEqualTo: authorName)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => BookModel.fromMap(doc.data(), doc.id))
        .where((book) => book.id != excludedBookId)
        .toList();
  }

  @override
  Future<void> toggleBookmark(
    String bookId,
    String userId,
    DateTime createAt,
  ) async {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(bookId);
    final bookRef = firestore.collection('books').doc(bookId);

    return await firestore.runTransaction((transaction) async {
      final bookmarkDoc = await transaction.get(docRef);

      if (bookmarkDoc.exists) {
        transaction.delete(docRef);
        transaction.update(bookRef, {
          'totalBookmarks': FieldValue.increment(-1),
        });
      } else {
        transaction.set(docRef, {
          'bookId': bookId,
          'addedAt': Timestamp.fromDate(createAt),
        });
        transaction.update(bookRef, {
          'totalBookmarks': FieldValue.increment(1),
        });
      }
    });
  }

  @override
  Future<void> toggleFollow(
    String bookId,
    String userId,
    DateTime createAt,
  ) async {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .doc(bookId);
    final bookRef = firestore.collection('books').doc(bookId);

    return await firestore.runTransaction((transaction) async {
      final followDoc = await transaction.get(docRef);

      if (followDoc.exists) {
        transaction.delete(docRef);
        transaction.update(bookRef, {'totalFollows': FieldValue.increment(-1)});
      } else {
        transaction.set(docRef, {
          'bookId': bookId,
          'followedAt': Timestamp.fromDate(createAt),
        });
        transaction.update(bookRef, {'totalFollows': FieldValue.increment(1)});
      }
    });
  }

  @override
  Future<List<BookModel>> getBookmarkedBooks(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
    String searchValues,
  ) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('addedAt', descending: true)
        .limit(pageSize)
        .get();

    return _getBooksFromSubCollection(snapshot);
  }

  @override
  Future<List<BookModel>> getFollowedBooks(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
    String searchValues,
  ) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .orderBy('followedAt', descending: true)
        .limit(pageSize)
        .get();

    return _getBooksFromSubCollection(snapshot);
  }

  @override
  Future<List<BookModel>> getReadingHistory(
    String userId,
    int pageSize,
    int offset,
  ) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('lastReadAt', descending: true)
        .limit(pageSize)
        .get();

    return _getBooksFromSubCollection(snapshot);
  }

  Future<List<BookModel>> _getBooksFromSubCollection(
    QuerySnapshot snapshot,
  ) async {
    List<BookModel> books = [];
    for (var doc in snapshot.docs) {
      final bookId = doc.id;
      final bookDoc = await firestore.collection('books').doc(bookId).get();
      if (bookDoc.exists) {
        books.add(BookModel.fromMap(bookDoc.data()!, bookDoc.id));
      }
    }
    return books;
  }

  @override
  Future<bool> isBookmarked(String userId, String bookId) async {
    final docSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(bookId)
        .get();
    return docSnapshot.exists;
  }

  @override
  Future<bool> isFollowed(String userId, String bookId) async {
    final docSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .doc(bookId)
        .get();
    return docSnapshot.exists;
  }

  @override
  Future<void> addBook(String bookId) async {
    await firestore.collection('books').doc(bookId).set({
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isHidden': false,
      'status': BookStatus.ongoing.label,
      'views': 0,
      'viewsDay': 0,
      'viewsWeek': 0,
      'totalBookmarks': 0,
      'totalFollows': 0,
      'quantity': 0,
    }, SetOptions(merge: true));
  }

  @override
  Future<List<BookModel>> getMyBooks(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
  ) async {
    Query query = firestore
        .collection('books')
        .where('authorId', isEqualTo: userId)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map(
          (doc) =>
              BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  @override
  Future<void> hiddenBook(String bookId) async {
    await firestore.collection('books').doc(bookId).update({
      'isHidden': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unHiddenBook(String bookId) async {
    await firestore.collection('books').doc(bookId).update({
      'isHidden': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateBook(BookModel book) async {
    final bookMap = book.toMap();
    bookMap['updatedAt'] = FieldValue.serverTimestamp();

    await firestore.collection('books').doc(book.id).update(bookMap);
  }

  @override
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    await firestore.collection('books').doc(bookId).update({
      'status': status.label,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
