import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/repository/appointment_repository.dart';
import '../patient/notification_list_screen.dart'; // Import màn hình thông báo
import 'appointment_detail_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  final int userId;
  final String userRole; // Thêm role để truyền vào tab thông báo

  const AppointmentListScreen({
    super.key, 
    required this.userId,
    this.userRole = 'Patient',
  });

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  void _refreshList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Lịch hẹn & Thông báo',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Color(0xFF0066B3),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0066B3),
            tabs: [
              Tab(text: 'Lịch hẹn', icon: Icon(Icons.assignment_outlined)),
              Tab(text: 'Thông báo', icon: Icon(Icons.notifications_none)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Danh sách lịch hẹn
            _buildAppointmentList(),
            
            // Tab 2: Danh sách thông báo (Gộp từ NotificationListScreen)
            NotificationListScreen(userRole: widget.userRole, isNested: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _appointmentRepo.getAllAppointments(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi kết nối: ${snapshot.error}'));
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshList(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final item = appointments[index];
              return InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentDetailScreen(appointment: item),
                    ),
                  );
                  if (result == true) {
                    _refreshList();
                  }
                },
                child: _buildAppointmentCard(item),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch hẹn nào\nBạn hãy thử đặt lịch nhé!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['available_date'] ?? '',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusTag(item['status'] ?? 'Chờ khám'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Bác sĩ: ${item['doctor_name']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text("Bệnh nhân: ${item['patient_name']}"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text("Giờ khám: ${item['start_time']} - ${item['end_time']}"),
            ],
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Xem chi tiết >',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color = Colors.orange;
    if (status == 'Chờ khám' || status == 'Pending') color = Colors.blue;
    if (status == 'Confirmed' || status == 'Đã khám') color = Colors.green;
    if (status == 'Cancelled' || status == 'Đã hủy') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
