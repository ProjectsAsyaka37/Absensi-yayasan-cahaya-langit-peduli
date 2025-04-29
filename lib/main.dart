import 'package:ujk/services/pref_services.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/welcomescreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartupScreen() async {
    bool loggedIn = await PrefService.isLoggedIn();
    if (loggedIn) {
      return HomeScreen();
    } else {
      return WelcomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Absensi',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getStartupScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
