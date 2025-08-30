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
      if (position == null) {
        return Left(SimpleFailure('Could not get current location.'));
      }
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
          final distance = Distance();

          for (var point in points) {
            final d = distance(userLocation, point.location);
            if (d <= (point.radius ?? 0)) { // Assuming radius is in meters
              targetPoint = point;
              break; 
            }
          }

          if (targetPoint == null) {
            return Left(SimpleFailure('You are not within range of any check-in point.'));
          }

          // 4. Record check-in
          return await repository.recordUserCheckIn(params.userId, targetPoint, DateTime.now());
        },
      );
    } catch (e) {
      return Left(SimpleFailure('Error during check-in: ${e.toString()}'));
    }
  }
}
