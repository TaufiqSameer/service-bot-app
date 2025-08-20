import 'package:flutter/material.dart';
import 'package:service_robot_new/views/about.dart';
import 'package:service_robot_new/views/logs.dart';
import 'package:service_robot_new/views/index.dart';
import 'package:service_robot_new/views/status.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Service Robot',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const IndexPage(),
        '/status': (context) => const StatusPage(),
        '/about': (context) => const AboutPage(),
        '/logs': (context) => const LogsPage(),
      },
    );
  }
}
