part of 'check_in_points_list_cubit.dart';

abstract class CheckInPointsListState extends Equatable {
  const CheckInPointsListState();

  @override
  List<Object> get props => [];
}

class CheckInPointsListInitial extends CheckInPointsListState {}

class CheckInPointsListLoading extends CheckInPointsListState {}

class CheckInPointsListLoaded extends CheckInPointsListState {
  final List<CheckInPoint> checkInPoints;

  const CheckInPointsListLoaded(this.checkInPoints);

  @override
  List<Object> get props => [checkInPoints];
}

class CheckInPointsListFailure extends CheckInPointsListState {
  final String message;

  const CheckInPointsListFailure(this.message);

  @override
  List<Object> get props => [message];
}
