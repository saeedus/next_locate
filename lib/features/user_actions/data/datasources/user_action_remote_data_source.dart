import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';

abstract class UserActionRemoteDataSource {
  Future<String> recordUserCheckIn(String userId, CheckInPointModel checkInPoint, DateTime timestamp);
  Future<String> recordUserCheckOut(String userId, DateTime timestamp);
  Future<CheckInPointModel?> getCurrentUserCheckInStatus(String userId);
}
