import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';

/// Service quản lý việc khởi tạo Firebase.
class FirebaseService {
  /// Khởi tạo Firebase App.
  /// 
  /// Phương thức này nên được gọi trong hàm main() trước khi runApp().
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
