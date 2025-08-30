import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source.dart';
import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';

class ActiveCheckInPointExistsException implements Exception {
  final String message;
  ActiveCheckInPointExistsException({this.message = "An active check-in point already exists. Cannot create a new one."});
}

class CheckInRemoteDataSourceImpl implements CheckInRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _appConfigCollection = 'app_config';
  static const String _activeStatusDoc = 'active_check_in_point_status';
  static const String _activePointIdField = 'activePointId';
  static const String _checkInPointsCollection = 'check_in_points';

  CheckInRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> createCheckInPoint(CheckInPointModel checkInPoint) async {
    final activeStatusRef = firestore.collection(_appConfigCollection).doc(_activeStatusDoc);
    final newCheckInPointRef = firestore.collection(_checkInPointsCollection).doc(); // Prepare a new doc ref to get ID

    return firestore.runTransaction((transaction) async {
      final activeStatusSnapshot = await transaction.get(activeStatusRef);

      if (activeStatusSnapshot.exists && activeStatusSnapshot.data()?[_activePointIdField] != null) {
        // Optionally, you could fetch the actual active point to verify it still exists
        // For now, just checking if the ID is set is enough to prevent a new active point.
        throw ActiveCheckInPointExistsException();
      }

      // If no active point, proceed to create the new one and set it as active
      transaction.set(newCheckInPointRef, checkInPoint.copyWith(id: newCheckInPointRef.id).toFirestore());
      
      // Set the new check-in point as active
      if (activeStatusSnapshot.exists) {
        transaction.update(activeStatusRef, {_activePointIdField: newCheckInPointRef.id});
      } else {
        transaction.set(activeStatusRef, {_activePointIdField: newCheckInPointRef.id});
      }
    });
  }

  @override
  Future<List<CheckInPointModel>> getAllCheckInPoints() async {
    final snapshot = await firestore.collection(_checkInPointsCollection).get();
    return snapshot.docs
        .map((doc) => CheckInPointModel.fromFirestore(doc))
        .toList();
  }

  // You'll likely need a method to get the currently active check-in point
  Future<CheckInPointModel?> getActiveCheckInPoint() async {
    final activeStatusDoc = await firestore.collection(_appConfigCollection).doc(_activeStatusDoc).get();
    if (activeStatusDoc.exists && activeStatusDoc.data()?[_activePointIdField] != null) {
      final activePointId = activeStatusDoc.data()![_activePointIdField] as String;
      final checkInPointDoc = await firestore.collection(_checkInPointsCollection).doc(activePointId).get();
      if (checkInPointDoc.exists) {
        return CheckInPointModel.fromFirestore(checkInPointDoc);
      }
    }
    return null;
  }

  // And a method to deactivate a check-in point (e.g., set activePointId to null)
  Future<void> deactivateCurrentCheckInPoint() async {
     final activeStatusRef = firestore.collection(_appConfigCollection).doc(_activeStatusDoc);
     final activeStatusSnapshot = await activeStatusRef.get();
     if (activeStatusSnapshot.exists) {
        await activeStatusRef.update({_activePointIdField: null});
     }
     // If the document doesn't exist, there's nothing to deactivate, or you could create it with null.
     // For simplicity, we only update if it exists.
  }
}

// Ensure your CheckInPointModel has `copyWith` and includes `id` if it wasn't already.
// Example:
// CheckInPointModel copyWith({String? id, ...}) {
//   return CheckInPointModel(id: id ?? this.id, ...);
// }
// And that `toFirestore()` includes the id if you want it stored in the document,
// and `fromFirestore` can read it.
// If your model's ID is the Firestore document ID, `newCheckInPointRef.id` gives it to you.
