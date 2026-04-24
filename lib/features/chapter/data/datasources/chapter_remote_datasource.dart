import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chapter_model.dart';
import '../models/reading_history_model.dart';

abstract class ChapterRemoteDataSource {
  Future<List<ChapterModel>> getListChapter(String bookId);

  Future<void> incrementViews(String id);

  Future<void> addChapter(
    String bookId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  );

  Future<void> deleteChapter(String bookId, String chapterId);

  Future<void> updateChapter(
    String bookId,
    String chapterId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  );

  Future<ChapterModel> getChapter(String bookId, String chapterId);

  Future<void> addReadingHistory(
    String bookId,
    String chapterId,
    String userId,
    DateTime lastReadAt,
  );

  Future<List<ReadingHistoryModel>> getListReadingHistory(
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

class ChapterRemoteDataSourceImpl implements ChapterRemoteDataSource {
  final FirebaseFirestore firestore;

  ChapterRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<ChapterModel>> getListChapter(String bookId) async {
    final snapshot = await firestore
        .collection('books')
        .doc(bookId)
        .collection('chapters')
        .orderBy('orderIndex', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => ChapterModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> incrementViews(String id) async {
    await firestore.collection('books').doc(id).update({
      'views': FieldValue.increment(1),
      'viewsDay': FieldValue.increment(1),
      'viewsWeek': FieldValue.increment(1),
    });
  }

  @override
  Future<void> addChapter(
    String bookId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  ) async {
    final chaptersRef = firestore
        .collection('books')
        .doc(bookId)
        .collection('chapters');

    await chaptersRef.add({
      'title': title,
      'content': content,
      'orderIndex': orderIndex,
      'isVip': isVip,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
      'bookId': bookId,
    });

    // Cập nhật số lượng chương của sách
    await firestore.collection('books').doc(bookId).update({
      'quantity': FieldValue.increment(1),
    });
  }

  @override
  Future<void> deleteChapter(String bookId, String chapterId) async {
    await firestore
        .collection('books')
        .doc(bookId)
        .collection('chapters')
        .doc(chapterId)
        .delete();
    await firestore.collection('books').doc(bookId).update({
      'quantity': FieldValue.increment(-1),
    });
  }

  @override
  Future<void> updateChapter(
    String bookId,
    String chapterId,
    String title,
    String content,
    int orderIndex,
    bool isVip,
    int price,
  ) async {
    await firestore
        .collection('books')
        .doc(bookId)
        .collection('chapters')
        .doc(chapterId)
        .update({
          'title': title,
          'content': content,
          'orderIndex': orderIndex,
          'isVip': isVip,
          'price': price,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<ChapterModel> getChapter(String bookId, String chapterId) async {
    final doc = await firestore
        .collection('books')
        .doc(bookId)
        .collection('chapters')
        .doc(chapterId)
        .get();
    if (!doc.exists) throw Exception("Chapter not found");
    return ChapterModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> addReadingHistory(
    String bookId,
    String chapterId,
    String userId,
    DateTime lastReadAt,
  ) async {
    // Lấy thông tin chương để có title và orderIndex
    final chapter = await getChapter(bookId, chapterId);

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
          'title': chapter.title,
          'orderIndex': chapter.orderIndex,
        });
  }

  @override
  Future<List<ReadingHistoryModel>> getListReadingHistory(
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
    return snapshot.docs
        .map((doc) => ReadingHistoryModel.fromMap(doc.data()))
        .toList();
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
