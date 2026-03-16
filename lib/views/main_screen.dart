import 'package:flutter/material.dart';
import 'package:projectnhom/views/appointment/appointment_list_screen.dart';
import 'landing_page.dart';
import 'booking_schedule/select_specialty_screen.dart';
import 'profile_screen.dart';
import 'patient/medical_history_screen.dart';
import 'patient/patient_list_screen.dart';
import '../implementations/local/app_database.dart';

class MainScreen extends StatefulWidget {
  final int userId;
  final int initialIndex;

  const MainScreen({
    super.key,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final db = await AppDatabase.instance.db;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [widget.userId],
    );

    if (users.isNotEmpty) {
      setState(() {
        _userRole = users.first['role'];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getNavItems() {
    final bool isAdmin = _userRole == 'Admin';
    
    List<Map<String, dynamic>> items = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'Trang Chủ',
        'page': const LandingPage(),
      },
    ];

    // Admin không có nút Đặt lịch
    if (!isAdmin) {
      items.add({
        'icon': Icons.calendar_today_outlined,
        'activeIcon': Icons.calendar_today,
        'label': 'Đặt Lịch',
        'page': SelectSpecialtyScreen(),
      });
    }

    items.addAll([
      {
        'icon': Icons.assignment_outlined,
        'activeIcon': Icons.assignment,
        'label': 'Lịch hẹn',
        'page': AppointmentListScreen(
          userId: widget.userId, 
          userRole: _userRole ?? 'Patient'
        ),
      },
      {
        'icon': Icons.history_outlined,
        'activeIcon': Icons.history,
        'label': 'Lịch sử',
        'page': MedicalHistoryScreen(userId: widget.userId),
      },
    ]);

    // Chỉ ADMIN thấy mục hồ sơ
    if (isAdmin) {
      items.add({
        'icon': Icons.people_outline,
        'activeIcon': Icons.people,
        'label': 'Hồ sơ',
        'page': PatientListScreen(userId: widget.userId),
      });
    }

    items.add({
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Tài khoản',
      'page': ProfileScreen(userId: widget.userId),
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final navItems = _getNavItems();
    if (_currentIndex >= navItems.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: navItems.map<Widget>((item) => item['page'] as Widget).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0066B3),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 9,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon'] as IconData),
            activeIcon: Icon(item['activeIcon'] as IconData),
            label: item['label'] as String,
          );
        }).toList(),
      ),
    );
  }
}
