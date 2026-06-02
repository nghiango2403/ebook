class ValidationUtils {
  /// Kiểm tra tính hợp lệ của Email.
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }

  /// Kiểm tra độ mạnh của mật khẩu (Ít nhất 6 ký tự).
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Kiểm tra một trường không được để trống.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Validate Email và trả về thông báo lỗi nếu không hợp lệ.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    if (!isValidEmail(value)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  /// Validate Password và trả về thông báo lỗi nếu không hợp lệ.
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (!isValidPassword(value)) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }
}
