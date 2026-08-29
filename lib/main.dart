import 'package:flutter/material.dart';

void main() {
  runApp(const DriveWiseApp());
}

class DriveWiseApp extends StatelessWidget {
  const DriveWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DriveWise',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DriveWise'),
        ),
        body: const Center(
          child: Text(
            'Gestiona tu vehículo de forma fácil.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}