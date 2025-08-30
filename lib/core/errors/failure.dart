import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  final List properties;

  const Failure({this.message, this.properties = const <dynamic>[]});

  @override
  List<Object?> get props => [message, ...properties];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message, super.properties});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message, super.properties});
}

class SimpleFailure extends Failure {
  const SimpleFailure(String message) : super(message: message);
}
