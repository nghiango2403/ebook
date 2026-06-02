class AppStrings {
  // Success Strings
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String registerSuccess = 'Đăng ký tài khoản thành công!';
  static const String updateSuccess = 'Cập nhật thông tin thành công!';
  static const String logoutSuccess = 'Đăng xuất thành công!';

  // Error Strings
  static const String unexpectedError = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.';
  static const String networkError = 'Không có kết nối internet. Vui lòng kiểm tra lại.';
  static const String serverError = 'Lỗi máy chủ. Vui lòng thử lại sau.';
  static const String cacheError = 'Lỗi lưu trữ dữ liệu.';
  
  // Auth Error Strings
  static const String invalidEmail = 'Email không hợp lệ.';
  static const String weakPassword = 'Mật khẩu quá yếu.';
  static const String emailAlreadyInUse = 'Email này đã được sử dụng.';
  static const String userNotFound = 'Không tìm thấy người dùng với email này.';
  static const String wrongPassword = 'Mật khẩu không chính xác.';
  static const String operationNotAllowed = 'Thao tác không được phép.';
  static const String userDisabled = 'Tài khoản người dùng đã bị vô hiệu hóa.';

  // Validation Strings
  static const String fieldRequired = 'Trường này là bắt buộc.';
  static const String passwordTooShort = 'Mật khẩu phải có ít nhất 6 ký tự.';
  static const String emailNotMatch = 'Email không đúng định dạng.';
}
