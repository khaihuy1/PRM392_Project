import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Sử dụng thư viện chuẩn
import 'package:projectnhom/implementations/repository/appointment_repository.dart';
import 'appointment_detail_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  final int userId;
  final String userRole;

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
    bool isDoctor = widget.userRole == 'Doctor';
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          isDoctor ? 'Danh sách bệnh nhân khám' : 'Lịch hẹn của tôi',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildAppointmentList(isDoctor),
    );
  }

  Widget _buildAppointmentList(bool isDoctor) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: isDoctor 
          ? _appointmentRepo.getDoctorAppointments(widget.userId)
          : _appointmentRepo.getAllAppointments(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi kết nối: ${snapshot.error}'));
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return _buildEmptyState(isDoctor);
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshList(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final item = appointments[index];
              return _buildAppointmentCard(item, isDoctor);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDoctor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            isDoctor ? 'Hôm nay chưa có bệnh nhân nào đặt lịch' : 'Chưa có lịch hẹn nào\nBạn hãy thử đặt lịch nhé!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> item, bool isDoctor) {
    String status = item['status'] ?? 'Pending';
    String displayDate = item['available_date'] ?? '';
    
    // Format lại ngày nếu cần
    try {
      DateTime date = DateTime.parse(displayDate);
      displayDate = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      // Giữ nguyên nếu không parse được
    }
    
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
                  displayDate,
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              _buildStatusTag(status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isDoctor ? "Bệnh nhân: ${item['patient_name']}" : "Bác sĩ: ${item['doctor_name']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (isDoctor) ...[
             const SizedBox(height: 4),
             Text(
               "Giới tính: ${item['patient_gender']} - Sinh năm: ${item['patient_dob'].toString().split('-')[0]}",
               style: const TextStyle(color: Colors.grey, fontSize: 13),
             ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text("Giờ khám: ${item['start_time']} - ${item['end_time']}"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.notes, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text("Lý do: ${item['reason'] ?? 'Không có'}", maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isDoctor && (status == 'Pending' || status == 'Chờ khám'))
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateAppointmentStatus(item['appointment_id'], 'Confirmed'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Xác nhận'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _updateAppointmentStatus(item['appointment_id'], 'Cancelled'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Từ chối'),
                    ),
                  ],
                )
              else if (isDoctor && status == 'Confirmed')
                ElevatedButton.icon(
                  onPressed: () => _updateAppointmentStatus(item['appointment_id'], 'Completed'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Hoàn thành khám'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                )
              else
                const SizedBox(),
                
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentDetailScreen(appointment: item),
                    ),
                  );
                  if (result == true) _refreshList();
                },
                child: const Text('Chi tiết >'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateAppointmentStatus(int appointmentId, String status) async {
    bool success = await _appointmentRepo.updateStatus(appointmentId, status);
    if (success) {
      _refreshList();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái: $status'))
      );
    }
  }

  Widget _buildStatusTag(String status) {
    Color color = Colors.orange;
    String text = status;
    if (status == 'Pending' || status == 'Chờ khám') { color = Colors.blue; text = 'Chờ xác nhận'; }
    if (status == 'Confirmed') { color = Colors.green; text = 'Đã xác nhận'; }
    if (status == 'Completed' || status == 'Đã khám') { color = Colors.teal; text = 'Đã khám xong'; }
    if (status == 'Cancelled' || status == 'Đã hủy') { color = Colors.red; text = 'Đã hủy'; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
