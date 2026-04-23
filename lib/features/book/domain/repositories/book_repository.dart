import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../entities/book_status.dart';
import '../entities/comment_entity.dart';

abstract class BookRepository {
  /// 1. Lấy thông tin chi tiết một cuốn sách
  Future<Either<Failure, BookEntity>> getBookById(String id);

  /// 3. Quản lý tương tác người dùng
  /// Toggle (bật/tắt) trạng thái đánh dấu hoặc theo dõi của người dùng đối với một cuốn sách
  Future<Either<Failure, void>> toggleBookmark(
    String bookId,
    String userId,
    DateTime createAt,
  );

  Future<Either<Failure, void>> toggleFollow(
    String bookId,
    String userId,
    DateTime createAt,
  );

  /// Lấy thông tin mô tả chi tiết (nếu description quá dài cần load riêng)
  Future<Either<Failure, String>> getBookDescription(String bookId);

  /// Lấy danh sách bình luận của truyện
  Future<Either<Failure, List<CommentEntity>>> getComments(String bookId);

  /// Lấy danh sách các truyện khác của cùng một tác giả
  Future<Either<Failure, List<BookEntity>>> getBooksByAuthor({
    required String authorId,
    required String excludedBookId, // Loại trừ cuốn hiện tại đang đọc
  });

  /// 4. Hàm tìm kiếm và lọc tổng hợp (Search & Filter)
  Future<Either<Failure, List<BookEntity>>> searchBooks({
    required int pageSize,
    required int offset,
    String? searchValues, // Tìm theo tiêu đề
    String? searchDescription, // Tìm theo mô tả
    int? minChapters, // Số chương > bao nhiêu (trường 'quantity')
    String? category, // Thể loại
    BookStatus? status, // Trạng thái (Hoàn thành, Còn tiếp...)
    required BookSortType sortBy, // Cách sắp xếp (Xem nhiều tuần, đánh dấu...)
  });

  /// 5. Lấy danh sách sách đã đánh dấu (Bookmarks) của người dùng
  Future<Either<Failure, List<BookEntity>>> getBookmarkedBooks({
    required String userId,
    required int pageSize,
    DocumentSnapshot? lastDocument,
    String searchValues = "",
  });

  /// 6. Lấy danh sách sách đang theo dõi (Following)
  Future<Either<Failure, List<BookEntity>>> getFollowedBooks({
    required String userId,
    required int pageSize,
    DocumentSnapshot? lastDocument,
    String searchValues = "",
  });

  /// 7. Lấy lịch sử đọc sách (Reading History)
  Future<Either<Failure, List<BookEntity>>> getReadingHistory({
    required String userId,
    required int pageSize,
    required int offset,
  });

  /// 8. Kiểm tra người dùng đã đánh dấu chưa
  Future<Either<Failure, bool>> isBookmarked({
    required String userId,
    required String bookId,
  });

  /// 9. Kiểm tra người dùng đã theo dõi chưa
  Future<Either<Failure, bool>> isFollowed({
    required String userId,
    required String bookId,
  });

  /// 10. Thêm sách
  Future<Either<Failure, bool>> addBook(String bookId);

  /// 11. Xóa sách
  Future<Either<Failure, bool>> hiddenBook(String bookId);

  /// 12. Sửa sách
  Future<Either<Failure, bool>> updateBook(BookEntity book);

  /// 13. Cập nhật trạng thái (Hoàn thành, Còn tiếp...)
  Future<Either<Failure, bool>> updateBookStatus(
    String bookId,
    BookStatus status,
  );

  /// 14. Lấy danh sách sách đã tải lên
  Future<Either<Failure, (List<BookEntity>, DocumentSnapshot?)>> getMyBooks(
    String userId,
    int pageSize,
    DocumentSnapshot? lastDocument,
  );

  /// 15. Hiển thị sách đã ẩn
  Future<Either<Failure, bool>> unHiddenBook(String bookId);
}

/// Định nghĩa các kiểu sắp xếp dữ liệu mở rộng theo các chỉ số mới
enum BookSortType {
  newlyUploaded, // Mới đăng
  recentlyUpdated, // Mới cập nhật
  mostViewedTotal, // Xem nhiều nhất (Tổng)
  mostViewedDay, // HOT trong ngày
  mostViewedWeek, // HOT trong tuần
  mostBookmarked, // Được yêu thích nhất (đánh dấu)
  mostFollowed, // Được theo dõi nhiều nhất
  newlyCompleted, // Mới hoàn thành
}
