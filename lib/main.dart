import 'package:flutter/material.dart';
import 'package:flutter_application_inz/pages/admin_dashboard.dart';
import 'package:flutter_application_inz/pages/manager_dashboard.dart';
import 'package:flutter_application_inz/pages/programmer_dashboard.dart';
import 'package:flutter_application_inz/pages/welcome_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: welcomeScreen(),
    );
  }
}
