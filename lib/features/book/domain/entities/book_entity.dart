import 'package:equatable/equatable.dart';

import 'book_status.dart';

class BookEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String authorName;
  final String imageUrl;
  final String categoryId;
  final int views;
  final int quantity;
  final BookStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewsDay;
  final int viewsWeek;
  final int totalBookmarks;
  final int totalFollows;
  final bool isHidden;

  const BookEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.imageUrl,
    required this.categoryId,
    required this.views,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.viewsDay,
    required this.viewsWeek,
    required this.totalBookmarks,
    required this.totalFollows,
    this.isHidden = false,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    authorId,
    authorName,
    imageUrl,
    categoryId,
    views,
    quantity,
    status,
    createdAt,
    updatedAt,
    viewsDay,
    viewsWeek,
    totalBookmarks,
    totalFollows,
    isHidden,
  ];
}
