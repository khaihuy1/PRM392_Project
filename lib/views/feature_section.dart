import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Wrap(
        spacing: 20, // Khoảng cách ngang
        runSpacing: 20, // Khoảng cách dọc khi xuống hàng
        alignment: WrapAlignment.center,
        children: [
          _featureCard("Hẹn Khám Nhanh", Icons.flash_on, Colors.orange),
          _featureCard("Bác Sĩ Giỏi", Icons.verified_user, Colors.green),
          _featureCard("Bảo Mật AI", Icons.security, Colors.blue),
        ],
      ),
    );
  }

  Widget _featureCard(String title, IconData icon, Color color) {
    return Container(
      width: 160, // Cố định chiều rộng để Wrap hoạt động tốt
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}