import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectnhom/views/main_screen.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  Future<void> _navigateToBooking(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // Lấy userId thực tế đã lưu từ lúc đăng nhập, mặc định là 1 nếu không tìm thấy
    final int userId = prefs.getInt('user_id') ?? 1;

    if (!context.mounted) return;

    // Chuyển hướng về MainScreen và chọn Tab index 1 (Đặt lịch của Bệnh nhân)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(userId: userId, initialIndex: 1),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Chăm Sóc Sức Khỏe\nChất Lượng Trong Tầm Tay',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đặt lịch khám với các bác sĩ chuyên gia chỉ trong vài cú nhấp chuột',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: 250,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _navigateToBooking(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Đặt Lịch Khám Ngay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
