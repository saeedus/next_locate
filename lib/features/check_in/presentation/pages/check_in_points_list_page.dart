import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_locate/features/check_in/presentation/cubit/check_in_points_list_cubit.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../../../../core/di/injection_container.dart';

class CheckInPointsListPage extends StatelessWidget {
  const CheckInPointsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CheckInPointsListCubit>()..loadCheckInPoints(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Check-in Points Map'),
        ),
        body: BlocBuilder<CheckInPointsListCubit, CheckInPointsListState>(
          builder: (context, state) {
            if (state is CheckInPointsListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CheckInPointsListLoaded) {
              if (state.checkInPoints.isEmpty) {
                return const Center(child: Text('No check-in points found to display on map.'));
              }

              final markers = state.checkInPoints.map((point) {
                return Marker(
                  width: 80.0,
                  height: 80.0,
                  point: point.location,
                  child: Tooltip(
                    message: 'ID: ${point.id}\nRadius: ${point.radius}m',
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40.0),
                  )
                );
              }).toList();

              // Determine initial camera position
              ll.LatLng initialCenter;
              double initialZoom = 5.0; // Default zoom
              if (state.checkInPoints.isNotEmpty) {
                initialCenter = state.checkInPoints.first.location;
                initialZoom = 13.0; // Zoom in a bit if there's at least one point
              } else {
                initialCenter = ll.LatLng(0,0); // Default center if no points
              }


              return FlutterMap(
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: initialZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.saeedussalehin.next_locate',
                  ),
                  MarkerLayer(markers: markers),
                  // Optionally, you can add CircleLayer to show the radius
                  CircleLayer(
                    circles: state.checkInPoints.map((point) {
                      return CircleMarker(
                        point: point.location,
                        color: Colors.blue.withOpacity(0.3),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                        radius: point.radius, // in meters
                      );
                    }).toList(),
                  ),
                ],
              );
            } else if (state is CheckInPointsListFailure) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is CheckInPointsListInitial) {
              return const Center(child: Text('Initializing map...'));
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }
}