import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_locate/core/di/injection_container.dart';
import 'package:next_locate/features/check_in/presentation/cubit/create_check_in_point_cubit.dart';
import 'package:next_locate/features/check_in/presentation/cubit/check_in_points_list_cubit.dart';
import 'package:next_locate/features/check_in/presentation/pages/create_check_in_point_page.dart';
import 'package:next_locate/features/user_actions/presentation/cubit/user_action_cubit.dart'; // Added import
import 'package:next_locate/features/user_actions/presentation/pages/user_actions_page.dart';
import '../cubit/create_check_in_point_state.dart';

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<CreateCheckInPointCubit>()..getCurrentLocation(),
        ),
        BlocProvider(
          create: (context) => sl<CheckInPointsListCubit>()..loadCheckInPoints(),
        ),
        BlocProvider( // Added UserActionCubit provider
          create: (context) => sl<UserActionCubit>()..fetchCurrentUserStatus(),
        ),
      ],
      child: const _MainNavigationPageView(),
    );
  }
}

class _MainNavigationPageView extends StatefulWidget {
  const _MainNavigationPageView();

  @override
  State<_MainNavigationPageView> createState() => _MainNavigationPageViewState();
}

class _MainNavigationPageViewState extends State<_MainNavigationPageView> {
  int _selectedIndex = 0; 

  static final List<Widget> _widgetOptions = <Widget>[
    const CreateCheckInPointPage(),
    const UserActionsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCheckInPointCubit, CreateCheckInPointState>(
      listener: (context, state) {
        if (state is CreateCheckInPointSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Check-in point created successfully!')),
          );
          context.read<CheckInPointsListCubit>().loadCheckInPoints();
          // No need to switch tabs explicitly if the user intends to stay or if CreateCheckInPointPage handles its own refresh
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Map & Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_circle_outlined),
              label: 'User Actions',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
