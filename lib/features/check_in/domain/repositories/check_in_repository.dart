import 'package:dartz/dartz.dart';
import 'package:next_locate/core/errors/failure.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';

abstract class CheckInRepository {
  Future<Either<Failure, void>> createCheckInPoint(CheckInPoint checkInPoint);
}
