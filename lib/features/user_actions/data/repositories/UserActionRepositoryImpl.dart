import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:next_locate/core/errors/failure.dart';
import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/user_actions/data/datasources/user_action_remote_data_source.dart';
import 'package:next_locate/features/user_actions/data/datasources/user_action_remote_data_source_impl.dart'; // For ActiveCheckInExistsException
import 'package:next_locate/features/user_actions/domain/repositories/user_action_repository.dart';

class UserActionRepositoryImpl implements UserActionRepository {
  final UserActionRemoteDataSource remoteDataSource;

  UserActionRepositoryImpl({required this.remoteDataSource});

  // Helper function to calculate distance between two lat/lon points using Haversine formula
  double _haversineDistance(double lat1, double lon1, double lat2,
      double lon2) {
    const R = 6371e3; // Earth radius in meters
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // in meters
  }

  @override
  Future<Either<Failure, String>> recordUserCheckIn(String userId,
      CheckInPoint point,
      DateTime timestamp,
      double userLatitude, // Added
      double userLongitude, // Added
      ) async {
    try {
      final distance = _haversineDistance(
        userLatitude,
        userLongitude,
        point.location.latitude,
        point.location.longitude,
      );

      if (distance > point.radius) {
        // User is outside the radius, attempt to check them out from any previous session
        try {
          await remoteDataSource.recordUserCheckOut(userId, timestamp);
          return Left(ServerFailure(
              message:
              "User is outside the check-in point radius. Checked out from any previous session."));
        } catch (checkoutError) {
          // If checkout fails, still report the primary issue (out of radius)
          // but you might want to log checkoutError or handle it more specifically
          return Left(ServerFailure(
              message:
              "User is outside the check-in point radius. Failed to ensure checkout from previous session: ${checkoutError
                  .toString()}"));
        }
      }

      // User is within radius, proceed with check-in
      final checkInPointModel = CheckInPointModel.fromEntity(point);
      final result = await remoteDataSource.recordUserCheckIn(
          userId, checkInPointModel, timestamp);
      return Right(result);
    } on ActiveCheckInExistsException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(
          message: "Failed to record user check-in: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, String>> recordUserCheckOut(String userId,
      DateTime timestamp) async {
    try {
      final result =
      await remoteDataSource.recordUserCheckOut(userId, timestamp);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(
          message: "Failed to record user check-out: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, CheckInPoint?>> getCurrentUserCheckInStatus(
      String userId) async {
    try {
      final checkInPointModel =
      await remoteDataSource.getCurrentUserCheckInStatus(userId);
      if (checkInPointModel != null) {
        return Right(checkInPointModel.toEntity());
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
          message: "Failed to get current user check-in status: ${e
              .toString()}"));
    }
  }
}