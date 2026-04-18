import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  // Khai báo biến connection
  final InternetConnection connection;

  // Khởi tạo thông qua Constructor
  NetworkInfoImpl(this.connection);

  @override
  Future<bool> get isConnected => connection.hasInternetAccess;
}