import 'package:flutter/material.dart';

class PrayerJournalScreen extends StatelessWidget {
  const PrayerJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Journal')),
      body: const Center(
        child: Text('Track your prayers and answered prayers'),
      ),
    );
  }
}