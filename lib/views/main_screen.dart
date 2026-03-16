import 'package:flutter/material.dart';
import 'package:projectnhom/views/appointment/appointment_list_screen.dart';
import 'package:projectnhom/views/landing_page.dart';
import 'package:projectnhom/views/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'booking_schedule/select_specialty_screen.dart';

class MainScreen extends StatefulWidget {
  final int userId; // Nhận userId được truyền từ trang Login
  final int initialIndex;

  const MainScreen({super.key, required this.userId, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Khởi tạo danh sách các trang bằng userId động từ widget
    _pages = [
      const LandingPage(),
      const SelectSpecialtyScreen(),
      // Nhớ truyền userId vào đây nếu trang này cần
      AppointmentListScreen(userId: widget.userId),
      // Đã thay số 2 bằng userId thật
      ProfileScreen(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0066B3),
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
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
