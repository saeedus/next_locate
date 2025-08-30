
import 'package:equatable/equatable.dart';

import '../../../check_in/domain/entities/check_in_point.dart';

abstract class UserActionState extends Equatable {
  const UserActionState();

  @override
  List<Object?> get props => [];
}

class UserActionInitial extends UserActionState {}

class UserActionInProgress extends UserActionState {}

class UserActionSuccess extends UserActionState {
  final String message;

  const UserActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class UserActionFailure extends UserActionState {
  final String error;

  const UserActionFailure(this.error);

  @override
  List<Object> get props => [error];
}

// States for displaying current check-in status
class UserActionStatusLoading extends UserActionState {}

class UserActionStatusLoaded extends UserActionState {
  final CheckInPoint? currentCheckInPoint; // null if not checked in

  const UserActionStatusLoaded(this.currentCheckInPoint);

  @override
  List<Object?> get props => [currentCheckInPoint];
}
