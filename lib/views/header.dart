import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng MediaQuery để kiểm tra chiều rộng màn hình (Module 6)
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Phần 1: Logo (Module 4: Row & Icon)
          Row(
            children: [
              const Icon(Icons.monitor_heart, color: Color(0xFF2962FF), size: 32),
              const SizedBox(width: 8),
              Text(
                'ClinicCare',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
              ),
            ],
          ),

          // Phần 2: Navigation Buttons (Module 5: Navigator)
          if (!isMobile) // Nếu là Desktop/Tablet thì hiện đầy đủ nút
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Đăng Nhập', style: TextStyle(color: Colors.black87)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Đăng Ký'),
                ),
              ],
            )
          else // Nếu là Mobile thì hiện icon Menu (Module 4)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Thường sẽ mở Drawer ở đây
                Scaffold.of(context).openEndDrawer();
              },
            ),
        ],
      ),
    );
  }
}