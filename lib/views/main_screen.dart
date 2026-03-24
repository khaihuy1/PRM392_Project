import 'package:flutter/material.dart';
import 'package:projectnhom/views/appointment/appointment_list_screen.dart';
import 'package:projectnhom/views/landing_page.dart';
import 'package:projectnhom/views/profile_screen.dart';
import 'package:projectnhom/views/patient/medical_history_screen.dart';
import 'package:projectnhom/views/patient/patient_list_screen.dart';
import 'package:projectnhom/implementations/local/app_database.dart';
import 'booking_schedule/select_specialty_screen.dart';
import 'doctor_schedule/doctor_schedule_list_screen.dart';

class MainScreen extends StatefulWidget {
  final int userId;
  final int initialIndex;

  const MainScreen({super.key, required this.userId, this.initialIndex = 0});

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
    try {
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
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Lỗi load role: $e");
    }
  }

  // Hàm tạo danh sách Menu dựa trên quyền của User
  List<Map<String, dynamic>> _getNavItems() {
    final bool isAdmin = _userRole == 'Admin';
    final bool isDoctor = _userRole == 'Doctor';
    
    List<Map<String, dynamic>> items = [];

    // 1. Trang Chủ (Ai cũng có)
    items.add({
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'Trang Chủ',
      'page': const LandingPage(),
    });

    // 2. Đặt Lịch (Chỉ dành cho Patient - Không phải Admin và không phải Doctor)
    if (!isAdmin && !isDoctor) {
      items.add({
        'icon': Icons.calendar_today_outlined,
        'activeIcon': Icons.calendar_today,
        'label': 'Đặt Lịch',
        'page': const SelectSpecialtyScreen(),
      });
    }

    // 3. Lịch làm việc (Chỉ dành cho Doctor)
    if (isDoctor) {
      items.add({
        'icon': Icons.schedule_outlined,
        'activeIcon': Icons.schedule,
        'label': 'Lịch làm',
        'page': DoctorScheduleListScreen(userId: widget.userId),
      });
    }

    // 4. Lịch hẹn (Ai cũng có nhưng logic bên trong trang sẽ khác)
    items.add({
      'icon': Icons.assignment_outlined,
      'activeIcon': Icons.assignment,
      'label': 'Lịch hẹn',
      'page': AppointmentListScreen(
        userId: widget.userId,
        userRole: _userRole ?? 'Patient',
      ),
    });

    // 5. Lịch sử khám (Dành cho Patient - Không phải Doctor)
    if (!isAdmin && !isDoctor) {
      items.add({
        'icon': Icons.history_outlined,
        'activeIcon': Icons.history,
        'label': 'Lịch sử',
        'page': MedicalHistoryScreen(userId: widget.userId),
      });
    }

    // 6. Quản lý Hồ sơ (Chỉ ADMIN thấy)
    if (isAdmin) {
      items.add({
        'icon': Icons.people_outline,
        'activeIcon': Icons.people,
        'label': 'Hồ sơ',
        'page': PatientListScreen(userId: widget.userId),
      });
    }

    // 7. Tài khoản (Ai cũng có)
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0066B3)),
        ),
      );
    }

    final navItems = _getNavItems();

    // Kiểm tra tránh lỗi index out of bounds
    if (_currentIndex >= navItems.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: navItems
            .map<Widget>((item) => item['page'] as Widget)
            .toList(),
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
