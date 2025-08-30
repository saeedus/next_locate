
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../check_in/domain/entities/check_in_point.dart';
import '../cubit/user_action_cubit.dart';
import '../cubit/user_action_state.dart';

class UserActionsPage extends StatefulWidget {
  const UserActionsPage({super.key});

  @override
  State<UserActionsPage> createState() => _UserActionsPageState();
}

class _UserActionsPageState extends State<UserActionsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch current status when the page loads
    context.read<UserActionCubit>().fetchCurrentUserStatus();
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
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is UserActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is UserActionInProgress || state is UserActionStatusLoading;
          CheckInPoint? currentCheckIn;
          if (state is UserActionStatusLoaded) {
            currentCheckIn = state.currentCheckInPoint;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state is UserActionStatusLoading)
                  const Center(child: CircularProgressIndicator()),
                if (state is UserActionStatusLoaded)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        currentCheckIn != null
                            ? 'Currently Checked In at: ${currentCheckIn.location.latitude}, ${currentCheckIn.location.longitude}'
                            : 'Currently Not Checked In',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading || currentCheckIn != null 
                      ? null 
                      : () => context.read<UserActionCubit>().userCheckIn(),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: isLoading && currentCheckIn == null // Show loading only for check-in button
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('User Check In'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading || currentCheckIn == null
                    ? null
                    : () => context.read<UserActionCubit>().userCheckOut(),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: isLoading && currentCheckIn != null // Show loading only for check-out button
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('User Check Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
