import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';

abstract class CheckInRemoteDataSource {
  Future<void> createCheckInPoint(CheckInPointModel checkInPoint);
  Future<List<CheckInPointModel>> getAllCheckInPoints();
}
