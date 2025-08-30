import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:next_locate/core/di/injection_container.dart';
import 'package:next_locate/features/check_in/presentation/cubit/create_check_in_point_cubit.dart';
import 'package:next_locate/features/check_in/presentation/cubit/check_in_points_list_cubit.dart';
import 'package:next_locate/features/check_in/presentation/pages/create_check_in_point_page.dart';
import 'package:next_locate/features/check_in/presentation/pages/check_in_points_list_page.dart';

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
    const CheckInPointsListPage(),
  ];

  void _onItemTapped(int index) {
    // If switching to the map tab, ensure data is fresh
    if (index == 1 && _selectedIndex != 1) {
      context.read<CheckInPointsListCubit>().loadCheckInPoints();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCheckInPointCubit, CreateCheckInPointState>(
      listener: (context, state) {
        if (state is CreateCheckInPointSuccess) {
          // Show SnackBar for success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Check-in point created successfully!')),
          );
          // Reload the list of check-in points
          context.read<CheckInPointsListCubit>().loadCheckInPoints();
          // Switch to the map view tab
          setState(() {
            _selectedIndex = 1;
          });
        }
        // Optionally, handle CreateCheckInPointFailure here too if needed
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add_location_alt),
              label: 'Create Check-in',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'View Check-ins',
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
