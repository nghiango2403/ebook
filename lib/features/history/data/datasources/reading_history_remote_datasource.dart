import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/reading_history_model.dart';

abstract class ReadingHistoryRemoteDataSource {
  Future<void> addReadingHistory(
    String bookId,
    String chapterId,
    String userId,
    String chapterTitle,
    int orderIndex,
    DateTime lastReadAt,
  );

  Future<(List<ReadingHistoryModel>, DocumentSnapshot?)> getListReadingHistory(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
  );

  Future<void> deleteReadingHistory(
    String bookId,
    String chapterId,
    String userId,
  );

  Future<ReadingHistoryModel> getReadingHistory(String bookId, String userId);
}

class ReadingHistoryRemoteDataSourceImpl
    implements ReadingHistoryRemoteDataSource {
  final FirebaseFirestore firestore;

  ReadingHistoryRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> addReadingHistory(
    String bookId,
    String chapterId,
    String userId,
    String title,
    int orderIndex,
    DateTime lastReadAt,
  ) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(bookId)
        .set({
          'bookId': bookId,
          'chapterId': chapterId,
          'userId': userId,
          'lastReadAt': Timestamp.fromDate(lastReadAt),
          'title': title,
          'orderIndex': orderIndex,
        });
  }

  @override
  Future<(List<ReadingHistoryModel>, DocumentSnapshot?)> getListReadingHistory(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
  ) async {
    var query = firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('lastReadAt', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final histories = snapshot.docs
        .map((doc) => ReadingHistoryModel.fromMap(doc.data()))
        .toList();
    
    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    return (histories, lastDoc);
  }

  @override
  Future<void> deleteReadingHistory(
    String bookId,
    String chapterId,
    String userId,
  ) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(bookId)
        .delete();
  }

  @override
  Future<ReadingHistoryModel> getReadingHistory(
    String bookId,
    String userId,
  ) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(bookId)
        .get();
    if (!doc.exists) throw Exception("History not found");
    return ReadingHistoryModel.fromMap(doc.data()!);
  }
}
