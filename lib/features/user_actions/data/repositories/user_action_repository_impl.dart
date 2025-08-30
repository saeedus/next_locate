import 'dart:math' show cos, sqrt, asin, pi, sin, pow;
import 'package:dartz/dartz.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/user_actions/data/datasources/user_action_remote_data_source.dart';
import 'package:next_locate/features/user_actions/domain/repositories/user_action_repository.dart';
import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';
import 'package:next_locate/features/user_actions/data/datasources/user_action_remote_data_source_impl.dart'; // Import the exception

import '../../../../core/errors/failure.dart'; 

class UserActionRepositoryImpl implements UserActionRepository {
  final UserActionRemoteDataSource remoteDataSource;

  UserActionRepositoryImpl({required this.remoteDataSource});

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radius of Earth in meters
    final dLat = (lat2 - lat1) * (pi / 180.0);
    final dLon = (lon2 - lon1) * (pi / 180.0);
    lat1 = lat1 * (pi / 180.0);
    lat2 = lat2 * (pi / 180.0);

    final a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(lat1) *
            cos(lat2);
    final c = 2 * asin(sqrt(a));
    return R * c; // Distance in meters
  }

  @override
  Future<Either<Failure, String>> recordUserCheckIn(
    String userId, 
    CheckInPoint checkInPoint, 
    DateTime timestamp,
    double userLatitude,
    double userLongitude,
  ) async {
    try {
      final distance = _haversineDistance(
        userLatitude,
        userLongitude,
        checkInPoint.location.latitude,
        checkInPoint.location.longitude,
      );

      if (distance > checkInPoint.radius) {
        // User is outside the radius, attempt to check them out from any previous session
        await remoteDataSource.recordUserCheckOut(userId, timestamp); 
        return Left(ServerFailure(message: "User is outside the check-in point radius. Checked out from any previous session."));
      }

      // User is within radius, proceed with check-in
      final checkInPointModel = CheckInPointModel.fromEntity(checkInPoint); 
      final result = await remoteDataSource.recordUserCheckIn(userId, checkInPointModel, timestamp);
      return Right(result);
    } on ActiveCheckInExistsException catch (e) { 
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: "Failed to record user check-in: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, String>> recordUserCheckOut(String userId, DateTime timestamp) async {
    try {
      final result = await remoteDataSource.recordUserCheckOut(userId, timestamp);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to record user check-out: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, CheckInPoint?>> getCurrentUserCheckInStatus(String userId) async {
    try {
      final checkInPointModel = await remoteDataSource.getCurrentUserCheckInStatus(userId);
      if (checkInPointModel != null) {
        return Right(checkInPointModel.toEntity()); 
      } else {
        return Right(null);
      }
    } catch (e) {
      return Left(ServerFailure(message: "Failed to get current user check-in status: ${e.toString()}"));
    }
  }
}
