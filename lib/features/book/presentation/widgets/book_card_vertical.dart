import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/book_status.dart';

class BookCardVertical extends StatelessWidget {
  final BookEntity book;
  final VoidCallback? onTap;

  const BookCardVertical({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: (){
          context.push('/book/${book.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.imageUrl,
                  width: 80,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 110,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tác giả: ${book.authorName}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if(book.status == BookStatus.ongoing)
                          const Icon(Icons.update, color: Colors.green, size: 16),
                        if(book.status == BookStatus.completed)
                          const Icon(Icons.check_circle, color: Colors.orange, size: 16),
                        if(book.status == BookStatus.onHold)
                          const Icon(Icons.pause_circle_filled, color: Colors.red, size: 16),

                        const SizedBox(width: 4),
                        Text(
                          book.status.label,
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.remove_red_eye, color: Colors.blue, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${book.views}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  // Xử lý logic khi người dùng chọn
                  switch (value) {
                    case 'delete':
                      onTap?.call();
                      break;
                    case 'download':
                      onTap?.call();//TODO Làm logic tải xuống
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download_rounded, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Tải truyện'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Xóa khỏi tủ truyện', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}