import 'package:dartz/dartz.dart';
import 'package:next_locate/core/errors/failure.dart';
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source.dart';
// Import the new exception
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source_impl.dart' show ActiveCheckInPointExistsException;
import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';
import 'package:next_locate/features/check_in/domain/repositories/check_in_repository.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDataSource remoteDataSource;

  CheckInRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createCheckInPoint(
      CheckInPoint checkInPoint) async {
    try {
      final checkInPointModel = CheckInPointModel.fromEntity(checkInPoint);
      await remoteDataSource.createCheckInPoint(checkInPointModel);
      return const Right(null);
    } on ActiveCheckInPointExistsException catch (e) { // Catch specific exception
      return Left(ServerFailure(message: e.message));
    } catch (e) { // Catch all other exceptions
      return Left(ServerFailure(message: "An unexpected error occurred."));
    }
  }

  @override
  Future<Either<Failure, List<CheckInPoint>>> getAllCheckInPoints() async {
    try {
      final checkInPointModels = await remoteDataSource.getAllCheckInPoints();
      final checkInPoints = checkInPointModels
          .map((model) => model.toEntity())
          .toList();
      return Right(checkInPoints);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to fetch check-in points."));
    }
  }

  // TODO: Implement getActiveCheckInPoint and deactivateCurrentCheckInPoint if needed
  // These would call the corresponding methods in remoteDataSource and handle potential errors.
  /*
  @override
  Future<Either<Failure, CheckInPoint?>> getActiveCheckInPoint() async {
    try {
      final model = await remoteDataSource.getActiveCheckInPoint();
      return Right(model?.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: "Failed to get active check-in point."));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateCurrentCheckInPoint() async {
    try {
      await remoteDataSource.deactivateCurrentCheckInPoint();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to deactivate check-in point."));
    }
  }
  */
}
