import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';
import '../entities/book_status.dart';
import '../entities/chapter_entity.dart';
import '../entities/comment_entity.dart';

abstract class BookRepository {
  /// 1. Lấy thông tin chi tiết một cuốn sách
  Future<Either<Failure, BookEntity>> getBookById(String id);

  /// 2. Tăng số lượt xem (Xử lý tăng cả viewsDay, viewsWeek và views tổng)
  Future<Either<Failure, void>> incrementViews(String id);

  /// 3. Quản lý tương tác người dùng
  /// Toggle (bật/tắt) trạng thái đánh dấu hoặc theo dõi của người dùng đối với một cuốn sách
  Future<Either<Failure, void>> toggleBookmark(String bookId, String userId, DateTime createAt);
  Future<Either<Failure, void>> toggleFollow(String bookId, String userId, DateTime createAt);
  /// Lấy thông tin mô tả chi tiết (nếu description quá dài cần load riêng)
  Future<Either<Failure, String>> getBookDescription(String bookId);

  /// Lấy danh sách chương của truyện (Sắp xếp theo số thứ tự)
  Future<Either<Failure, List<ChapterEntity>>> getChapters(String bookId);

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
    String? searchValues,      // Tìm theo tiêu đề
    String? searchDescription, // Tìm theo mô tả
    int? minChapters,          // Số chương > bao nhiêu (trường 'quantity')
    String? category,          // Thể loại
    BookStatus? status,        // Trạng thái (Hoàn thành, Còn tiếp...)
    required BookSortType sortBy, // Cách sắp xếp (Xem nhiều tuần, đánh dấu...)
  });
  /// 5. Lấy danh sách sách đã đánh dấu (Bookmarks) của người dùng
  Future<Either<Failure, List<BookEntity>>> getBookmarkedBooks({
    required String userId,
    required int pageSize,
    required int offset,
  });
  /// 6. Lấy danh sách sách đang theo dõi (Following)
  Future<Either<Failure, List<BookEntity>>> getFollowedBooks({
    required String userId,
    required int pageSize,
    required int offset,
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
}

/// Định nghĩa các kiểu sắp xếp dữ liệu mở rộng theo các chỉ số mới
enum BookSortType {
  newlyUploaded,      // Mới đăng
  recentlyUpdated,    // Mới cập nhật
  mostViewedTotal,    // Xem nhiều nhất (Tổng)
  mostViewedDay,      // HOT trong ngày
  mostViewedWeek,     // HOT trong tuần
  mostBookmarked,     // Được yêu thích nhất (đánh dấu)
  mostFollowed,       // Được theo dõi nhiều nhất
  newlyCompleted,     // Mới hoàn thành
}