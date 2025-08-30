import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class CreateCheckInPointState extends Equatable {
  const CreateCheckInPointState();

  @override
  List<Object?> get props => [];
}

class CreateCheckInPointInitial extends CreateCheckInPointState {}

class CreateCheckInPointLoading extends CreateCheckInPointState {}

class CreateCheckInPointLoaded extends CreateCheckInPointState {
  final LatLng currentLocation;
  final LatLng? selectedLocation;
  final double radius;

  const CreateCheckInPointLoaded({
    required this.currentLocation,
    this.selectedLocation,
    required this.radius,
  });

  @override
  List<Object?> get props => [currentLocation, selectedLocation, radius];

  CreateCheckInPointLoaded copyWith({
    LatLng? currentLocation,
    LatLng? selectedLocation,
    double? radius,
  }) {
    return CreateCheckInPointLoaded(
      currentLocation: currentLocation ?? this.currentLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      radius: radius ?? this.radius,
    );
  }
}

class CreateCheckInPointSuccess extends CreateCheckInPointState {
  final String message;

  const CreateCheckInPointSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CreateCheckInPointFailure extends CreateCheckInPointState {
  final String message;

  const CreateCheckInPointFailure(this.message);

  @override
  List<Object> get props => [message];
}
