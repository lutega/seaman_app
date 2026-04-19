import 'package:flutter/material.dart';

class QuestOverviewScreen extends StatelessWidget {
  final String enrollmentId;
  const QuestOverviewScreen({super.key, required this.enrollmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quest')),
      body: Center(child: Text('Quest untuk enrollment: $enrollmentId')),
    );
  }
}
