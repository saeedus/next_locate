import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_locate/features/check_in/presentation/cubit/check_in_points_list_cubit.dart';

import '../../../../core/di/injection_container.dart';

class CheckInPointsListPage extends StatelessWidget {
  const CheckInPointsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CheckInPointsListCubit>()..loadCheckInPoints(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Check-in Points'),
        ),
        body: BlocBuilder<CheckInPointsListCubit, CheckInPointsListState>(
          builder: (context, state) {
            if (state is CheckInPointsListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CheckInPointsListLoaded) {
              if (state.checkInPoints.isEmpty) {
                return const Center(child: Text('No check-in points found.'));
              }
              return ListView.builder(
                itemCount: state.checkInPoints.length,
                itemBuilder: (context, index) {
                  final point = state.checkInPoints[index];
                  return ListTile(
                    title: Text('ID: ${point.id}'), // Or any other relevant info
                    subtitle: Text(
                        'Lat: ${point.location.latitude}, Lng: ${point.location.longitude}\nRadius: ${point.radius}m\nCreated by: ${point.createdBy} at ${point.createdAt.toIso8601String()}'),
                    isThreeLine: true,
                  );
                },
              );
            } else if (state is CheckInPointsListFailure) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is CheckInPointsListInitial) {
              return const Center(child: Text('Initializing...'));
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }
}
