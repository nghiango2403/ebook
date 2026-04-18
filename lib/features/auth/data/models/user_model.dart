import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// [UserModel] là lớp dữ liệu (Data Transfer Object - DTO).
///
/// Chịu trách nhiệm chuyển đổi (Mapping) dữ liệu từ các nguồn bên ngoài
/// (như Firestore) sang [UserEntity] của tầng Domain.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.username,
    required super.imageUrl,
    required super.role,
    required super.level,
    required super.gender,
    required super.createdAt,
    required super.tokens,
    required super.totalDeposited,
  });

  /// Chuyển đổi dữ liệu từ Map (Firestore Document) sang [UserModel].
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // Chuyển đổi String từ DB sang Enum UserRole
      role: UserRole.values.firstWhere(
            (e) => e.name == (map['role'] ?? 'reader'),
        orElse: () => UserRole.reader,
      ),
      // Chuyển đổi String từ DB sang Enum AccountLevel
      level: AccountLevel.values.firstWhere(
            (e) => e.name == (map['level'] ?? 'normal'),
        orElse: () => AccountLevel.normal,
      ),
      gender: map['gender'] ?? 'Khác',
      // Xử lý Firebase Timestamp sang DateTime của Dart
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      tokens: map['tokens']?.toInt() ?? 0,
      totalDeposited: map['totalDeposited']?.toInt() ?? 0,
    );
  }

  /// Chuyển đổi [UserModel] sang Map để lưu trữ lên Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'imageUrl': imageUrl,
      'role': role.name,    // Lưu tên enum dưới dạng String
      'level': level.name,  // Lưu tên enum dưới dạng String
      'gender': gender,
      'createdAt': Timestamp.fromDate(createdAt), // Chuyển ngược lại Timestamp
      'tokens': tokens,
      'totalDeposited': totalDeposited,
    };
  }

  /// Phương thức chuyển đổi nhanh từ Entity sang Model (Nếu cần ném dữ liệu lên lại).
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      username: entity.username,
      imageUrl: entity.imageUrl,
      role: entity.role,
      level: entity.level,
      gender: entity.gender,
      createdAt: entity.createdAt,
      tokens: entity.tokens,
      totalDeposited: entity.totalDeposited,
    );
  }
}