import 'package:flutter/material.dart';
import 'package:projectnhom/views/appointment/appointment_list_screen.dart';
import 'landing_page.dart'; // Trang chủ của bạn
import 'booking_schedule/select_specialty_screen.dart'; // Trang chọn chuyên khoa

class MainScreen extends StatefulWidget {
  final int userId;
  final int initialIndex; // Thêm biến để nhận vị trí tab muốn mở

  const MainScreen({
    super.key,
    required this.userId,
    this.initialIndex = 0, // Mặc định mở Trang chủ (index 0)
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Khởi tạo index từ giá trị truyền vào
    _currentIndex = widget.initialIndex;

    // Danh sách các trang ứng với từng Tab
    _pages = [
      const LandingPage(),
      SelectSpecialtyScreen(),
      const AppointmentListScreen(userId: 2),
      const Center(child: Text('Cài đặt hệ thống')), // Placeholder Cài đặt
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giữ cho các trang không bị load lại khi chuyển tab
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2962FF), // Màu xanh đồng bộ với Hero Button
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang Chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Đặt Lịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Cài Đặt',
          ),
        ],
      ),
    );
  }
}