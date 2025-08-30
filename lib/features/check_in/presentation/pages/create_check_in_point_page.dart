import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:next_locate/features/check_in/presentation/cubit/check_in_points_list_cubit.dart';
import 'package:next_locate/features/check_in/presentation/cubit/create_check_in_point_cubit.dart';
import 'package:next_locate/features/check_in/presentation/cubit/create_check_in_point_state.dart';

class CreateCheckInPointPage extends StatefulWidget {
  const CreateCheckInPointPage({super.key});

  @override
  State<CreateCheckInPointPage> createState() => _CreateCheckInPointPageState();
}

class _CreateCheckInPointPageState extends State<CreateCheckInPointPage> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Fetch existing check-in points
    context.read<CheckInPointsListCubit>().loadCheckInPoints();
    // Get current location for initial map centering
    context.read<CreateCheckInPointCubit>().getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Create Check-in'),
      ),
      body: BlocConsumer<CreateCheckInPointCubit, CreateCheckInPointState>(
        listener: (context, createPointState) {
          if (createPointState is CreateCheckInPointFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(createPointState.message)),
            );
          } else if (createPointState is CreateCheckInPointSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(createPointState.message)),
            );
            // Refresh the list of points on the map
            context.read<CheckInPointsListCubit>().loadCheckInPoints();
            // Optionally, reset the selection for a new entry
            // context.read<CreateCheckInPointCubit>().resetSelection(); // You'd need to add this method
          } else if (createPointState is CreateCheckInPointLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _mapController.move(createPointState.currentLocation, 15.0);
              }
            });
          }
        },
        builder: (context, createPointState) {
          if (createPointState is CreateCheckInPointLoading ||
              createPointState is CreateCheckInPointInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          // We rely on CreateCheckInPointLoaded for the initial map center (user's current location)
          // If CreateCheckInPointCubit fails to load current location, this builder won't reach FlutterMap.
          // Consider adding a more robust error handling or default map center here.
          if (createPointState is CreateCheckInPointLoaded) {
            return Stack(
              children: [
                BlocBuilder<CheckInPointsListCubit, CheckInPointsListState>(
                  builder: (context, listState) {
                    List<Marker> existingMarkers = [];
                    List<CircleMarker> existingCircles = [];
                    if (listState is CheckInPointsListLoaded) {
                      existingMarkers = listState.checkInPoints.map((point) {
                        return Marker(
                          point: point.location,
                          child: Tooltip(
                            message: 'Lat: ${point.location.latitude.toStringAsFixed(4)}, Lng: ${point.location.longitude.toStringAsFixed(4)}\nRadius: ${point.radius}m',
                            child: const Icon(Icons.location_on, color: Colors.green, size: 35),
                          ),
                        );
                      }).toList();
                      existingCircles = listState.checkInPoints.map((point) {
                        return CircleMarker(
                            point: point.location,
                            radius: point.radius,
                            useRadiusInMeter: true,
                            color: Colors.green.withOpacity(0.2),
                            borderColor: Colors.green,
                            borderStrokeWidth: 1.5);
                      }).toList();
                    }

                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: createPointState.currentLocation, // Centered on user's current location
                        initialZoom: 15.0,
                        onLongPress: (tapPosition, latLng) {
                          context
                              .read<CreateCheckInPointCubit>()
                              .selectLocation(latLng);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.saeedussalehin.next_locate',
                        ),
                        CircleLayer(circles: existingCircles),
                        MarkerLayer(markers: existingMarkers),
                        if (createPointState.selectedLocation != null)
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: createPointState.selectedLocation!,
                                radius: createPointState.radius,
                                useRadiusInMeter: true,
                                color: Colors.blue.withOpacity(0.3),
                                borderColor: Colors.blue,
                                borderStrokeWidth: 2,
                              ),
                            ],
                          ),
                        if (createPointState.selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: createPointState.selectedLocation!,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Radius: ${createPointState.radius.round()} meters'),
                          Slider(
                            value: createPointState.radius,
                            min: 50,
                            max: 500,
                            divisions: 9,
                            label: '${createPointState.radius.round()} meters',
                            onChanged: (double value) {
                              context
                                  .read<CreateCheckInPointCubit>()
                                  .updateRadius(value);
                            },
                          ),
                          ElevatedButton(
                            onPressed: createPointState.selectedLocation == null
                                ? null
                                : () {
                                    context
                                        .read<CreateCheckInPointCubit>()
                                        .saveCheckInPoint();
                                  },
                            child: const Text('Save Check-in Point'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          // Fallback for other states of CreateCheckInPointCubit (e.g., if current location fetch fails)
          return const Center(child: Text('Error loading map. Please ensure location services are enabled.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CreateCheckInPointCubit>().getCurrentLocation();
        },
        tooltip: 'Center on my location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
