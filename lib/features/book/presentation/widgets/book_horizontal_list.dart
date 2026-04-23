import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/book_view_model.dart';
import 'book_card_item.dart';

class BookHorizontalList extends ConsumerWidget {
  final String title;
  final List<BookViewModel> books;
  final bool isLoading;

  const BookHorizontalList({
    super.key,
    required this.title,
    required this.books,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        SizedBox(height: 280, child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading && books.isEmpty) {
      return _buildSkeletonLoader();
    }

    if (books.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 24),
      itemCount: books.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (ctx, i) => BookCardItem(item: books[i]),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 24),
      itemCount: 3,
      itemBuilder: (ctx, i) => Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 15, width: 100, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Container(height: 12, width: 60, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
