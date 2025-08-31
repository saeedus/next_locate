
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import '../../../check_in/domain/entities/check_in_point.dart';
import '../cubit/user_action_cubit.dart';
import '../cubit/user_action_state.dart';

class UserActionsPage extends StatefulWidget {
  const UserActionsPage({super.key});

  @override
  State<UserActionsPage> createState() => _UserActionsPageState();
}

class _UserActionsPageState extends State<UserActionsPage> {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    context.read<UserActionCubit>().fetchCurrentUserStatus();
    _determinePositionAndSubscribe();
  }

  Future<void> _determinePositionAndSubscribe() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      }
      return;
    }

    try {
      Position initialPosition = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = initialPosition;
        });
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          14.0, 
        );
      }

      _positionStreamSubscription = Geolocator.getPositionStream().listen(
        (Position? position) {
          if (mounted && position != null) {
            setState(() {
              _currentPosition = position;
            });
            // Optionally, move map to new position if user hasn't interacted
            // For now, marker updates, map stays unless moved by user or _mapController.move
          }
        }, onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error in location stream: $e')));
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting initial location: $e')));
      }
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Actions'),
      ),
      body: BlocConsumer<UserActionCubit, UserActionState>(
        listener: (context, state) {
          if (state is UserActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is UserActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is UserActionInProgress ||
              state is UserActionStatusLoading;
          CheckInPoint? currentCheckIn;
          if (state is UserActionStatusLoaded) {
            currentCheckIn = state.currentCheckInPoint;
          }

          List<Marker> markers = [];
          List<CircleMarker> circles = [];

          if (_currentPosition != null) {
            markers.add(
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
              ),
            );
          }

          if (currentCheckIn != null) {
            final checkInLatLng = LatLng(currentCheckIn.location.latitude,
                currentCheckIn.location.longitude);
            markers.add(
              Marker(
                width: 80.0,
                height: 80.0,
                point: checkInLatLng,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            );
            if (currentCheckIn.radius > 0) {
              circles.add(
                CircleMarker(
                  point: checkInLatLng,
                  color: Colors.red.withOpacity(0.2),
                  borderColor: Colors.red.withOpacity(0.5),
                  borderStrokeWidth: 1.5,
                  useRadiusInMeter: true,
                  radius: currentCheckIn.radius.toDouble(),
                ),
              );
            }
          }

          return Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : const LatLng(23.8103, 90.4125), // Default: Dhaka
                    initialZoom: _currentPosition != null ? 14.0 : 6.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.saeedussalehin.next_locate',
                    ),
                    CircleLayer(circles: circles),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (state is UserActionStatusLoading && _currentPosition == null)
                          const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: CircularProgressIndicator(),
                          )),
                        if (state is UserActionStatusLoaded)
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                currentCheckIn != null
                                    ? 'Checked In: ${currentCheckIn.location.latitude.toStringAsFixed(4)}, ${currentCheckIn.location.longitude.toStringAsFixed(4)}\nRadius: ${currentCheckIn.radius}m'
                                    : 'Currently Not Checked In',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: isLoading || currentCheckIn != null
                              ? null
                              : () => context
                                  .read<UserActionCubit>()
                                  .userCheckIn(),
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12)),
                          child: isLoading && currentCheckIn == null
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Text('User Check In'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: isLoading || currentCheckIn == null
                              ? null
                              : () => context
                                  .read<UserActionCubit>()
                                  .userCheckOut(),
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12)),
                          child: isLoading && currentCheckIn != null
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Text('User Check Out'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
