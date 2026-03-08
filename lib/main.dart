import 'package:flutter/material.dart';
import 'package:projectnhom/views/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp là widget bắt buộc phải có ở đây
    return MaterialApp(
      title: 'ClinicCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(), // Gọi trang Landing Page của bạn ở đây
    );
  }
}