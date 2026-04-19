import 'package:flutter/material.dart';

class QuestDetailScreen extends StatelessWidget {
  final String enrollmentId;
  final String questId;
  const QuestDetailScreen({super.key, required this.enrollmentId, required this.questId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Quest')),
      body: Center(child: Text('Quest: $questId')),
    );
  }
}
