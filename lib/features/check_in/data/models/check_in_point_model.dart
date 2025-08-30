import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:next_locate/features/check_in/domain/entities/check_in_point.dart';

class CheckInPointModel extends CheckInPoint {
  const CheckInPointModel({
    required super.id,
    required super.location,
    required super.radius,
    required super.createdBy,
    required super.createdAt,
  });

  factory CheckInPointModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CheckInPointModel(
      id: doc.id,
      location: LatLng(data['location'].latitude, data['location'].longitude),
      radius: (data['radius'] as num).toDouble(),
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'location': GeoPoint(location.latitude, location.longitude),
      'radius': radius,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      // Note: 'id' is typically not stored as a field in the document itself,
      // as the document ID serves this purpose.
    };
  }

  CheckInPointModel copyWith({
    String? id,
    LatLng? location,
    double? radius,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CheckInPointModel(
      id: id ?? this.id,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CheckInPointModel.fromEntity(CheckInPoint entity) {
    return CheckInPointModel(
      id: entity.id,
      location: entity.location,
      radius: entity.radius,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
  }

  CheckInPoint toEntity() {
    return CheckInPoint(
      id: id,
      location: location,
      radius: radius,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
