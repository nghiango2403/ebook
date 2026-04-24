import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chapter_model.dart';

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
}
