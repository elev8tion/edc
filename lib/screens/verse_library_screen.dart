import 'package:flutter/material.dart';

class VerseLibraryScreen extends StatelessWidget {
  const VerseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verse Library')),
      body: const Center(
        child: Text('Browse and search Bible verses'),
      ),
    );
  }
}