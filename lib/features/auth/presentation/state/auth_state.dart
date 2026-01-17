import 'package:equatable/equatable.dart';
import 'package:gamezone_flutter/features/auth/domain/entities/user_entity.dart';


enum AuthStatus { initial, loading, authenticated, unauthenticated, registered, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.authEntity,
    this.errorMessage,
  });

  // Initial State Factory
  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
      authEntity: null,
      errorMessage: null,
    );
  }

  // CopyWith Method
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? authEntity,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      // If we pass null specifically for authEntity, we keep the old one 
      // unless you implement a more complex null-handling logic.
      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, authEntity, errorMessage];
}