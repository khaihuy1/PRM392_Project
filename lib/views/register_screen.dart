import 'package:flutter/material.dart';
import 'package:projectnhom/views/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Màu nền nhẹ như ảnh
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              // Logo & Title
              const Icon(Icons.monitor_heart, size: 48, color: Colors.blueAccent),
              const SizedBox(height: 8),
              const Text(
                'ClinicCare',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đăng Ký Tài Khoản',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const Text('Tạo tài khoản để đặt lịch khám nhanh chóng'),
              const SizedBox(height: 32),

              // Card Form
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const RegisterForm(),
              ),

              const SizedBox(height: 24),
              TextButton(
                onPressed: () {},
                child: const Text('Quay về trang chủ', style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}