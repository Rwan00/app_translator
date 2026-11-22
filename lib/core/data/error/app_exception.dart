import 'package:equatable/equatable.dart';

/// Base Failure class mirroring customer_new_app architecture.
abstract class Failure extends Equatable {
  const Failure(this.errorMessage);
  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class ServerFailure extends Failure {
  const ServerFailure(super.errorMessage);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure(super.errorMessage);
}
