import 'package:flutter/material.dart';
import 'package:projectnhom/views/booking_schedule/select_specialty_screen.dart';
import 'package:projectnhom/views/main_screen.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

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
              height: 1.3, // Chiều cao dòng
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đặt lịch khám với các bác sĩ chuyên gia chỉ trong vài cú nhấp chuột',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 32),

          // Nút Đặt Lịch Khám Ngay
          SizedBox(
            width: 250,
            height: 50,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(userId: 2, initialIndex: 1), // Nhảy vào Tab 1 (Đặt lịch)
                    ),
                        (route) => false, // Xóa hết các trang cũ để tránh bị lỗi nút quay lại
                  );
                },
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
