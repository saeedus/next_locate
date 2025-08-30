import 'package:flutter/material.dart';

class CheckInPointsListPage extends StatefulWidget {
  const CheckInPointsListPage({super.key});

  @override
  State<CheckInPointsListPage> createState() => _CheckInPointsListPageState();
}

class _CheckInPointsListPageState extends State<CheckInPointsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in Points'),
      ),
      body: const Center(
        child: Text('List of check-in points will be shown here.'),
      ),
    );
  }
}
