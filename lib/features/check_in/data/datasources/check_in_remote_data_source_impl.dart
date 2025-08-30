import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source.dart';
import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';

class CheckInRemoteDataSourceImpl implements CheckInRemoteDataSource {
  final FirebaseFirestore firestore;

  CheckInRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createCheckInPoint(CheckInPointModel checkInPoint) async {
    await firestore
        .collection('check_in_points')
        .add(checkInPoint.toFirestore());
  }

  @override
  Future<List<CheckInPointModel>> getAllCheckInPoints() async {
    final snapshot = await firestore.collection('check_in_points').get();
    return snapshot.docs
        .map((doc) => CheckInPointModel.fromFirestore(doc))
        .toList();
  }
}
