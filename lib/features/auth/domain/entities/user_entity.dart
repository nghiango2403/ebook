import 'package:equatable/equatable.dart';

/// Định nghĩa các quyền hạn của người dùng trong hệ thống (Role-Based Access Control).
enum UserRole { admin, editor, reader }

/// Phân cấp tài khoản để xử lý các logic về ưu đãi hoặc giới hạn tính năng.
enum AccountLevel {
  normal,   // Dân thường: Đọc truyện có quảng cáo
  wealthy,  // Phú hộ: Đọc không quảng cáo, mở khóa chương VIP
  tycoon    // Tài phiệt: Đặc quyền tối thượng, đọc trước chương mới
}

/// [UserEntity] là lớp đại diện cho thông tin người dùng ở tầng Domain.
///
/// Lớp này tuân thủ nguyên tắc Immutability (bất biến) và hỗ trợ so sánh
/// giá trị thông qua [Equatable].
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String username;
  final String imageUrl;
  final UserRole role;
  final AccountLevel level;
  final String gender;
  final DateTime createdAt;
  /// Số dư Token hiện tại của người dùng (tiền đã nạp).
  final int tokens;
  /// Tổng số Token đã từng nạp (dùng để tính toán cấp độ thân thiết/thăng hạng).
  final int totalDeposited;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.username,
    required this.imageUrl,
    required this.role,
    required this.level,
    required this.gender,
    required this.createdAt,
    required this.tokens,
    required this.totalDeposited
  });

  // --- Utility Getters (Giúp UI code sạch hơn) ---

  /// Kiểm tra người dùng còn tiền để thực hiện giao dịch hay không.
  bool hasTokens(int amount) => tokens >= amount;

  /// Hiển thị định dạng số dư (Ví dụ: 1.000 Token).
  String get formattedTokens => "${tokens.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Token";

  /// Kiểm tra xem người dùng có quyền quản trị hoặc biên tập hay không.
  bool get canManageContent => role == UserRole.admin || role == UserRole.editor;

  /// Kiểm tra xem người dùng có phải Admin tối cao không.
  bool get isAdmin => role == UserRole.admin;

  /// Kiểm tra xem người dùng có được hưởng đặc quyền VIP không (Phú hộ hoặc Tài phiệt).
  bool get isVip => level != AccountLevel.normal;

  /// Kiểm tra xem người dùng có phải là Tài phiệt không.
  bool get isTycoon => level == AccountLevel.tycoon;

  // --- End Utility Getters ---

  UserEntity copyWith({
    String? username,
    String? imageUrl,
    UserRole? role,
    AccountLevel? level,
    String? gender,
    int? tokens,
    int? totalDeposited,
  }) {
    return UserEntity(
      uid: uid,
      email: email,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      level: level ?? this.level,
      gender: gender ?? this.gender,
      createdAt: createdAt,
      tokens: tokens ?? this.tokens,
      totalDeposited: totalDeposited ?? this.totalDeposited,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    username,
    imageUrl,
    role,
    level,
    gender,
    createdAt,
    tokens,
    totalDeposited,
  ];
}