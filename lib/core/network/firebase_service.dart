import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Quản lý tập trung các Instance của Firebase.
///
/// Giúp việc cấu hình và truy cập Firebase dễ dàng hơn thông qua một điểm duy nhất.
class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

// Bạn có thể thêm các hàm bổ trợ như cấu hình Persistence tại đây
}