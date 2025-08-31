
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

// States for check-in count
class UserActionCheckInCountLoading extends UserActionState {
  final String checkInPointId;
  const UserActionCheckInCountLoading(this.checkInPointId);

  @override
  List<Object?> get props => [checkInPointId];
}

class UserActionCheckInCountLoaded extends UserActionState {
  final String checkInPointId;
  final int count;

  const UserActionCheckInCountLoaded(this.checkInPointId, this.count);

  @override
  List<Object?> get props => [checkInPointId, count];
}

class UserActionCheckInCountError extends UserActionState {
  final String checkInPointId;
  final String error;

  const UserActionCheckInCountError(this.checkInPointId, this.error);

  @override
  List<Object?> get props => [checkInPointId, error];
}
