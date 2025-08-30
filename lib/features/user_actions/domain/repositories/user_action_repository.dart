import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../check_in/domain/entities/check_in_point.dart';

abstract class UserActionRepository {
  Future<Either<Failure, String>> recordUserCheckIn(
    String userId, 
    CheckInPoint point, 
    DateTime timestamp,
    double userLatitude,
    double userLongitude,
  );
  Future<Either<Failure, String>> recordUserCheckOut(String userId, DateTime timestamp);
  Future<Either<Failure, CheckInPoint?>> getCurrentUserCheckInStatus(String userId);
}
