import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/check_in/domain/usecases/create_check_in_point.dart';
import 'package:next_locate/features/check_in/presentation/cubit/create_check_in_point_state.dart';

class CreateCheckInPointCubit extends Cubit<CreateCheckInPointState> {
  final CreateCheckInPointUseCase _createCheckInPointUseCase;
  final GeolocatorPlatform _geolocatorPlatform;

  CreateCheckInPointCubit({
    required CreateCheckInPointUseCase createCheckInPointUseCase,
    required GeolocatorPlatform geolocatorPlatform,
  }) : _createCheckInPointUseCase = createCheckInPointUseCase,
       _geolocatorPlatform = geolocatorPlatform,
       super(CreateCheckInPointInitial()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    emit(CreateCheckInPointLoading());
    try {
      final position = await _determinePosition();
      emit(
        CreateCheckInPointLoaded(
          currentLocation: LatLng(position.latitude, position.longitude),
          radius: 200,
        ),
      );
    } catch (e) {
      emit(CreateCheckInPointFailure(e.toString()));
    }
  }

  void selectLocation(LatLng location) {
    if (state is CreateCheckInPointLoaded) {
      final currentState = state as CreateCheckInPointLoaded;
      emit(currentState.copyWith(selectedLocation: location));
    }
  }

  void updateRadius(double radius) {
    if (state is CreateCheckInPointLoaded) {
      final currentState = state as CreateCheckInPointLoaded;
      emit(currentState.copyWith(radius: radius));
    }
  }

  Future<void> saveCheckInPoint() async {
    if (state is CreateCheckInPointLoaded) {
      final currentState = state as CreateCheckInPointLoaded;
      if (currentState.selectedLocation == null) return;

      final point = CheckInPoint(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        location: currentState.selectedLocation!,
        radius: currentState.radius,
        createdBy: "SYSTEM_USER",
        createdAt: DateTime.now(),
      );

      final result = await _createCheckInPointUseCase(point);
      result.fold(
        (failure) => emit(CreateCheckInPointFailure(failure.toString())),
        (_) {
          emit(
            const CreateCheckInPointSuccess(
              'Check-in point saved successfully',
            ),
          );
        },
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await _geolocatorPlatform.getCurrentPosition();
  }
}
