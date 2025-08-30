import 'package:dartz/dartz.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../check_in/domain/entities/check_in_point.dart';
import '../../../check_in/domain/usecases/get_check_in_points_use_case.dart';
import '../repositories/user_action_repository.dart';

class CheckInUserUseCaseParams {
  final String userId;

  CheckInUserUseCaseParams({required this.userId});
}

class CheckInUserUseCase implements UseCase<String, CheckInUserUseCaseParams> {
  final UserActionRepository repository;
  final GetCheckInPointsUseCase getCheckInPointsUseCase;
  final GeolocatorPlatform geolocatorPlatform;

  CheckInUserUseCase({
    required this.repository,
    required this.getCheckInPointsUseCase,
    required this.geolocatorPlatform,
  });

  @override
  Future<Either<Failure, String>> call(CheckInUserUseCaseParams params) async {
    try {
      // 1. Get current location
      final position = await geolocatorPlatform.getCurrentPosition();
      // No explicit null check needed as getCurrentPosition is non-nullable
      // but platform exceptions will be caught by the outer try-catch.
      // If it *could* return null in some path, a check would be wise:
      // if (position == null) {
      //   return Left(SimpleFailure('Could not get current location.'));
      // }
      final userLocation = LatLng(position.latitude, position.longitude);

      // 2. Get available check-in points
      final pointsResult = await getCheckInPointsUseCase(NoParams());
      return pointsResult.fold(
        (failure) => Left(failure),
        (points) async {
          if (points.isEmpty) {
            return Left(SimpleFailure('No check-in points available.'));
          }

          // 3. Find the closest suitable check-in point
          CheckInPoint? targetPoint;
          final distance = Distance(); // Using latlong2's Distance calculator

          for (var point in points) {
            // Ensure point.location is LatLng if using latlong2's Distance
            // Assuming point.location is already a LatLng compatible object
            // or we extract latitude and longitude from it.
            // For now, let's assume point.latitude and point.longitude exist
            // and point.location might be a different type.
            // If point.location IS LatLng: final d = distance(userLocation, point.location);

            // Using Haversine directly if point.location is not LatLng but has lat/lon props
            // This is more aligned with what UserActionRepositoryImpl does.
            // For consistency, let's use the raw latitude/longitude from point.
            // Note: The `distance` object (from latlong2) calculates in meters by default.
            final d = distance(
                userLocation,
                LatLng(point.location.latitude, point.location.longitude) // Assuming point has latitude/longitude
            );

            if (d <= (point.radius ?? 0)) { // Assuming radius is in meters
              targetPoint = point;
              break; 
            }
          }

          if (targetPoint == null) {
            // Before failing, let's try to check out the user from any active session
            // if they are not in range of ANY point. This is a business rule decision.
            // The UserActionRepositoryImpl already does this if a specific point is targeted
            // but the user is out of *its* range.
            // Here, the user is out of *all* available points' ranges.
            try {
              // Attempt to check out from any previous session
              // We need a timestamp, using DateTime.now()
              // This part of the logic might be better placed or handled differently
              // depending on desired UX.
              // For now, if no point is in range, we just fail.
              // If auto-checkout from *any* session is desired here, it would be:
              // await repository.recordUserCheckOut(params.userId, DateTime.now());
              // And the message might be different.
            } catch (checkoutError) {
              // Log or handle checkout error if necessary
            }
            return Left(SimpleFailure('You are not within range of any check-in point.'));
          }

          // 4. Record check-in
          // Pass the user's actual latitude and longitude
          return await repository.recordUserCheckIn(
            params.userId,
            targetPoint,
            DateTime.now(),
            userLocation.latitude,  // Pass user's latitude
            userLocation.longitude, // Pass user's longitude
          );
        },
      );
    } catch (e) {
      // Catching potential exceptions from geolocatorPlatform.getCurrentPosition()
      // or other synchronous errors.
      return Left(SimpleFailure('Error during check-in process: ${e.toString()}'));
    }
  }
}
