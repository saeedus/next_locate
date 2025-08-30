import 'package:dartz/dartz.dart';
import 'package:next_locate/core/errors/failure.dart';
import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/user_actions/data/datasources/user_action_remote_data_source.dart'; // Assuming this exists
import 'package:next_locate/features/user_actions/domain/repositories/user_action_repository.dart';

class UserActionRepositoryImpl implements UserActionRepository {
  final UserActionRemoteDataSource remoteDataSource;

  UserActionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> recordUserCheckIn(
      String userId, CheckInPoint point, DateTime timestamp) async {
    try {
      final checkInPointModel = CheckInPointModel.fromEntity(point);
      final result = await remoteDataSource.recordUserCheckIn(userId, checkInPointModel, timestamp);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> recordUserCheckOut(
      String userId, DateTime timestamp) async {
    try {
      final result = await remoteDataSource.recordUserCheckOut(userId, timestamp);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CheckInPoint?>> getCurrentUserCheckInStatus(
      String userId) async {
    try {
      final checkInPointModel = await remoteDataSource.getCurrentUserCheckInStatus(userId);
      if (checkInPointModel != null) {
        return Right(checkInPointModel.toEntity());
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
