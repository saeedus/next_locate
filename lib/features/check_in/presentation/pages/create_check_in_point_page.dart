import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
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
        title: const Text('Create Check-in Point'),
      ),
      body: BlocConsumer<CreateCheckInPointCubit, CreateCheckInPointState>(
        listener: (context, state) {
          if (state is CreateCheckInPointFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CreateCheckInPointSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is CreateCheckInPointLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _mapController.move(state.currentLocation, 15.0);
              }
            });
          }
        },
        builder: (context, state) {
          if (state is CreateCheckInPointLoading ||
              state is CreateCheckInPointInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CreateCheckInPointLoaded) {
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: state.currentLocation,
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
                    if (state.selectedLocation != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: state.selectedLocation!,
                            radius: state.radius,
                            useRadiusInMeter: true,
                            color: Colors.blue.withOpacity(0.3),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    if (state.selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: state.selectedLocation!,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Slider(
                        value: state.radius,
                        min: 50,
                        max: 500,
                        divisions: 9,
                        label: '${state.radius.round()} meters',
                        onChanged: (double value) {
                          context
                              .read<CreateCheckInPointCubit>()
                              .updateRadius(value);
                        },
                      ),
                      ElevatedButton(
                        onPressed: state.selectedLocation == null
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
              ],
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CreateCheckInPointCubit>().getCurrentLocation();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
