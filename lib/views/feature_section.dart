import 'package:flutter/material.dart';
import 'package:projectnhom/views/doctor_search_screen.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          _featureCard(context, "Hẹn Khám Nhanh", Icons.flash_on, Colors.orange, () {
            // Logic cho Hẹn khám nhanh (nếu có)
          }),
          _featureCard(context, "Bác Sĩ Giỏi", Icons.verified_user, Colors.green, () {
            // Chuyển sang trang DoctorSearchScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DoctorSearchScreen()),
            );
          }),
          _featureCard(context, "Bảo Mật AI", Icons.security, Colors.blue, () {
            // Logic cho Bảo mật AI (nếu có)
          }),
        ],
      ),
    );
  }

  // Thêm tham số BuildContext và VoidCallback onTap
  Widget _featureCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Kích hoạt hàm khi nhấn vào
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}