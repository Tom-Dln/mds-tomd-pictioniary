import 'package:flutter/material.dart';

class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Text(
          'Placeholder home screen',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
