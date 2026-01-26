import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/features/auth/domain/use_case/get_current_usecase.dart';
import 'package:gamezone_flutter/features/auth/domain/use_case/login_usecase.dart';
import 'package:gamezone_flutter/features/auth/domain/use_case/logout_usecase.dart';
import 'package:gamezone_flutter/features/auth/domain/use_case/register_usecase.dart';
import 'package:gamezone_flutter/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;

  @override
  AuthState build() {
    // Initialize all usecases
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    
    return AuthState.initial(); 
  }

  /// Register User
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password, 
      confirmPassword: confirmPassword
    );

    final result = await _registerUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (isRegistered) => state = state.copyWith(status: AuthStatus.registered),
    );
  }

  /// Login User
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = LoginUsecaseParams(email: email, password: password);

    final result = await _loginUsecase(params);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }

  /// Logout User
  /// This handles clearing the Hive boxes and SharedPreferences via the Usecase
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = AuthState.initial(), // Reset to unauthenticated/initial state
    );
  }

  /// Get Current User (Used for Session Persistence)
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated, 
        authEntity: user,
      ),
    );
  }

  /// Reset State
  void resetState() {
    state = AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}