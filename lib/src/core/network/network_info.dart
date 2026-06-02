import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Interface để kiểm tra kết nối Internet.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Thực thi của NetworkInfo sử dụng gói [InternetConnectionChecker].
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
