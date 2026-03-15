import 'package:flutter/material.dart';
import 'package:projectnhom/views/feature_section.dart';
import 'package:projectnhom/views/header.dart';
import 'package:projectnhom/views/hero_section.dart';



class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Header(),
            SizedBox(height: 48),
            HeroSection(),
            SizedBox(height: 60),
            FeaturesSection(),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}