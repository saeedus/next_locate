import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';
import 'package:next_locate/features/check_in/data/datasources/check_in_remote_data_source.dart'; // Added import for the interface

// Exception for when an active check-in point already exists (though not used in current create logic)
class ActiveCheckInPointExistsException implements Exception {
  final String message;
  ActiveCheckInPointExistsException(this.message);
}

// The duplicate abstract class CheckInRemoteDataSource has been removed from here.

class CheckInRemoteDataSourceImpl implements CheckInRemoteDataSource {
  final FirebaseFirestore _firestore;

  CheckInRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> createCheckInPoint(CheckInPointModel checkInPoint) async {
    // Get a new document reference for the new check-in point *outside* the transaction.
    final newCheckInPointRef = _firestore.collection('check_in_points').doc();
    // Ensure the model has the ID that will be used for the document.
    final pointWithId = checkInPoint.copyWith(id: newCheckInPointRef.id);

    final activePointStatusRef =
        _firestore.collection('app_config').doc('active_check_in_point_status');

    // Run the transaction
    return _firestore.runTransaction((transaction) async {
      // READ PHASE: Get the current active check-in point status.
      final activePointStatusSnapshot = await transaction.get(activePointStatusRef);

      // WRITE PHASE
      // 1. Delete the old active check-in point, if one exists.
      if (activePointStatusSnapshot.exists &&
          activePointStatusSnapshot.data() != null &&
          activePointStatusSnapshot.data()!['activePointId'] != null) {
        final oldActivePointId =
            activePointStatusSnapshot.data()!['activePointId'] as String;
        if (oldActivePointId.isNotEmpty) { // Ensure ID is not empty
          final oldCheckInPointRef =
              _firestore.collection('check_in_points').doc(oldActivePointId);
          transaction.delete(oldCheckInPointRef);
        }
      }

      // 2. Create the new check-in point document.
      // Assuming CheckInPointModel has a toFirestore() method
      transaction.set(newCheckInPointRef, pointWithId.toFirestore()); 

      // 3. Update the active_check_in_point_status document to point to the new ID.
      transaction.set(
        activePointStatusRef,
        {'activePointId': newCheckInPointRef.id},
        SetOptions(merge: true), // Use merge to handle creation or update.
      );
    });
  }

  @override
  Future<List<CheckInPointModel>> getAllCheckInPoints() async {
    final snapshot = await _firestore.collection('check_in_points').get();
    return snapshot.docs
        .map((doc) => CheckInPointModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<CheckInPointModel?> getActiveCheckInPoint() async {
    final activePointStatusDoc = await _firestore
        .collection('app_config')
        .doc('active_check_in_point_status')
        .get();

    if (activePointStatusDoc.exists &&
        activePointStatusDoc.data() != null &&
        activePointStatusDoc.data()!['activePointId'] != null) {
      final activePointId = activePointStatusDoc.data()!['activePointId'] as String;
      if (activePointId.isEmpty) return null; // Guard against empty ID

      final checkInPointDoc =
          await _firestore.collection('check_in_points').doc(activePointId).get();
      if (checkInPointDoc.exists) {
        return CheckInPointModel.fromFirestore(checkInPointDoc);
      }
    }
    return null;
  }

  @override
  Future<void> deactivateCurrentCheckInPoint() async {
    final activePointStatusRef =
        _firestore.collection('app_config').doc('active_check_in_point_status');
    // Set activePointId to null or delete the field to indicate no active point
    await activePointStatusRef.set({'activePointId': null}, SetOptions(merge: true));
  }
}
