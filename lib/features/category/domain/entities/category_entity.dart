import 'package:flutter/material.dart';

/// Thực thể đại diện cho thể loại.
class CategoryEntity {
  final String id;
  final String name;
  final Color color;
  final int displayOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.displayOrder,
  });
}