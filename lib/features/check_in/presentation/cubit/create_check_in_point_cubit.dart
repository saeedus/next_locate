import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/check_in/domain/usecases/create_check_in_point.dart';
import 'package:next_locate/features/check_in/presentation/cubit/create_check_in_point_state.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateCheckInPointCubit extends Cubit<CreateCheckInPointState> {
  final CreateCheckInPoint createCheckInPoint;

  CreateCheckInPointCubit({required this.createCheckInPoint}) : super(CreateCheckInPointInitial());

  Future<void> getCurrentLocation() async {
    emit(CreateCheckInPointLoading());
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        emit(CreateCheckInPointLoaded(
          currentLocation: LatLng(position.latitude, position.longitude),
          radius: 100,
        ));
      } catch (e) {
        emit(const CreateCheckInPointFailure('Failed to get current location.'));
      }
    } else {
      emit(const CreateCheckInPointFailure('Location permission denied.'));
    }
  }

  void selectLocation(LatLng location) {
    if (state is CreateCheckInPointLoaded) {
      final loadedState = state as CreateCheckInPointLoaded;
      emit(loadedState.copyWith(selectedLocation: location));
    }
  }

  void updateRadius(double radius) {
    if (state is CreateCheckInPointLoaded) {
      final loadedState = state as CreateCheckInPointLoaded;
      emit(loadedState.copyWith(radius: radius));
    }
  }

  Future<void> saveCheckInPoint() async {
    if (state is CreateCheckInPointLoaded) {
      final loadedState = state as CreateCheckInPointLoaded;
      if (loadedState.selectedLocation != null) {
        final checkInPoint = CheckInPoint(
          id: '', // Firestore will generate the ID
          location: loadedState.selectedLocation!,
          radius: loadedState.radius,
          createdBy: '', // TODO: Get the current user ID
          createdAt: DateTime.now(),
        );
        final result = await createCheckInPoint(checkInPoint);
        result.fold(
          (failure) => emit(const CreateCheckInPointFailure('Failed to save check-in point.')),
          (_) => emit(loadedState), // Or a success state
        );
      }
    }
  }
}
