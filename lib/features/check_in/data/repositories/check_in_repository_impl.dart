import 'package:dartz/dartz.dart';
import 'package:next_locate/core/errors/failure.dart';
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source.dart';
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
      final checkInPointModel = CheckInPointModel(
        id: checkInPoint.id,
        location: checkInPoint.location,
        radius: checkInPoint.radius,
        createdBy: checkInPoint.createdBy,
        createdAt: checkInPoint.createdAt,
      );
      await remoteDataSource.createCheckInPoint(checkInPointModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
