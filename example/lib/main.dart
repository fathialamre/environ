import 'dart:io';

import 'package:environ/environ.dart';
import 'package:flutter/material.dart';

void main() async {
  const String envFile = String.fromEnvironment(
    'ENV_FILE',
    defaultValue: '.env',
  );

  await Environ.loadEnv(filePath: envFile);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Hello, ${Environ.getString('APP_NAME')}!')),
    );
  }
}
