import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class CheckInPoint extends Equatable {
  final String id;
  final LatLng location;
  final double radius;
  final String createdBy;
  final DateTime createdAt;

  const CheckInPoint({
    required this.id,
    required this.location,
    required this.radius,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, location, radius, createdBy, createdAt];
}
