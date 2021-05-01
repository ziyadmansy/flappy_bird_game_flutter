import 'package:flutter/material.dart';

class CreditsScreen extends StatelessWidget {
  static const String ROUTE_NAME = '/creditsScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Credits'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Our Team'),
            Text('Ziyad Mansy'),
            Text('Aya Abd El-Aziz'),
          ],
        ),
      ),
    );
  }
}