import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:next_locate/features/check_in/data/models/check_in_point_model.dart';
import 'package:next_locate/features/user_actions/data/datasources/user_action_remote_data_source.dart';

class UserActionRemoteDataSourceImpl implements UserActionRemoteDataSource {
  final FirebaseFirestore firestore;

  UserActionRemoteDataSourceImpl({required this.firestore});

  @override
  Future<String> recordUserCheckIn(String userId, CheckInPointModel checkInPoint, DateTime timestamp) async {
    // Assuming 'user_check_ins' collection stores documents with a 'userId' field
    // and other check-in details.
    final docRef = await firestore.collection('user_check_ins').add({
      ...checkInPoint.toFirestore(), // Spread the model's data
      'userId': userId,
      'check_in_timestamp': Timestamp.fromDate(timestamp), // Use the provided timestamp
      'check_out_timestamp': null, // Explicitly set check_out_timestamp to null on check-in
    });
    return docRef.id;
  }

  @override
  Future<String> recordUserCheckOut(String userId, DateTime timestamp) async {
    // Find the active check-in for the user (no check_out_timestamp)
    final querySnapshot = await firestore
        .collection('user_check_ins')
        .where('userId', isEqualTo: userId)
        .where('check_out_timestamp', isNull: true)
        .orderBy('check_in_timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await firestore.collection('user_check_ins').doc(docId).update({
        'check_out_timestamp': Timestamp.fromDate(timestamp),
      });
      return docId; // Return the ID of the updated check-in document
    } else {
      // Potentially throw an error or return a specific status if no active check-in is found
      throw Exception('No active check-in found for user $userId to check-out.');
    }
  }

  @override
  Future<CheckInPointModel?> getCurrentUserCheckInStatus(String userId) async {
    final querySnapshot = await firestore
        .collection('user_check_ins')
        .where('userId', isEqualTo: userId)
        .where('check_out_timestamp', isNull: true) // Check for active check-in
        .orderBy('check_in_timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Assuming CheckInPointModel has a factory constructor fromFirestore
      // and the document data matches what CheckInPointModel expects.
      return CheckInPointModel.fromFirestore(querySnapshot.docs.first);
    } else {
      return null;
    }
  }
}
