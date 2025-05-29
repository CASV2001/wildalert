import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/map_screen.dart';
import 'screens/report_sighting_screen.dart';
import 'screens/first_aid_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildAlert',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/scan': (context) => const ScanScreen(),
        '/map': (context) => const MapScreen(),
        '/report': (context) => const ReportSightingScreen(),
        '/first-aid': (context) => const FirstAidScreen(),
      },
    );
  }
}
