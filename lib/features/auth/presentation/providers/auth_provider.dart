import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// Core
import '../../../../core/network/network_info.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// 1. Cung cấp External Instances
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final internetConnectionProvider = Provider((ref) => InternetConnection());

// 2. Cung cấp Network Info
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(internetConnectionProvider));
});

// 3. Cung cấp DataSources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// 4. Cung cấp Repository (Hợp đồng thực tế)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// 5. Cung cấp Usecases
final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);
final registerUseCaseProvider = Provider(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

/// Trạng thái của quá trình Auth
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, UserEntity? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error, // Nếu không truyền thì reset về null
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _auth = auth,
       _firestore = firestore,
       super(AuthState()) {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!mounted) return;

        if (doc.exists) {
          final userData = doc.data()!;
          final user = UserEntity(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: userData['username'] ?? '',
            imageUrl: userData['imageUrl'] ?? '',
            role: _parseRole(userData['role']),
            level: _parseLevel(userData['level']),
            gender: userData['gender'] ?? '',
            createdAt: (userData['createdAt'] as Timestamp).toDate(),
            tokens: userData['tokens'] ?? 0,
            totalDeposited: userData['totalDeposited'] ?? 0,
          );
          state = state.copyWith(user: user);
        }
      } else {
        state = AuthState();
      }
    });
  }

  UserRole _parseRole(String? role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => UserRole.reader,
    );
  }

  AccountLevel _parseLevel(String? level) {
    return AccountLevel.values.firstWhere(
      (e) => e.name == level,
      orElse: () => AccountLevel.normal,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String gender,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _registerUseCase(
      email: email,
      password: password,
      username: username,
      gender: gender,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  /// Logic Đăng nhập
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  /// Logic Đăng xuất
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _logoutUseCase();
    state = AuthState();
  }
}

// 6. Provider chính để UI sử dụng
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});
