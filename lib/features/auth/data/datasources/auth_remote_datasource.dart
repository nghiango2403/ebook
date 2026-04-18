import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Giao diện nguồn dữ liệu từ xa (Interface).
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String gender,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUserData();
}

/// Thực thi chi tiết bằng Firebase SDK.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.auth,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      // 1. Đăng nhập vào Firebase Auth
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) throw ServerException("Không tìm thấy người dùng");

      // 2. Lấy dữ liệu phân quyền & token từ Firestore
      return await _getUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseAuthError(e.code));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String gender,
  }) async {
    try {
      // 1. Tạo user trên Firebase Auth
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) throw ServerException("Tạo tài khoản thất bại");

      // 2. Khởi tạo dữ liệu mặc định cho "Dân thường" trên Firestore
      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email,
        username: username,
        imageUrl: '',
        role: UserRole.reader,
        level: AccountLevel.normal,
        gender: gender,
        createdAt: DateTime.now(),
        tokens: 0, // Mới đăng ký thì trắng túi nhé!
        totalDeposited: 0,
      );

      await firestore.collection('users').doc(newUser.uid).set(newUser.toMap());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseAuthError(e.code));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return null;
    return await _getUserFromFirestore(currentUser.uid);
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
  }

  // --- Hàm bổ trợ (Private Helpers) ---

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw AuthException("Dữ liệu người dùng không tồn tại trên hệ thống.");
    }
    return UserModel.fromMap(doc.data()!);
  }

  String _handleFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found': return "Email này chưa được đăng ký.";
      case 'wrong-password': return "Mật khẩu không chính xác.";
      case 'email-already-in-use': return "Email này đã được sử dụng bởi tài khoản khác.";
      case 'weak-password': return "Mật khẩu quá yếu.";
      default: return "Lỗi xác thực: $code";
    }
  }
}