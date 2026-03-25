import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/repository/appointment_repository.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final AppointmentRepository _repo = AppointmentRepository();

  AppointmentDetailScreen({super.key, required this.appointment});

  void _handleCancel(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch khám này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Quay lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy lịch', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm) {
      bool success = await _repo.cancelAppointment(
        appointment['appointment_id'],
        appointment['slot_id'],
      );

      if (success) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy lịch thành công')));
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem đây là màn hình của Bác sĩ hay Bệnh nhân dựa trên dữ liệu hiện có
    bool isDoctorView = appointment['doctor_name'] == null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết lịch khám', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available, size: 50, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 30),
            
            if (!isDoctorView) _infoRow('Bác sĩ chuyên khoa', appointment['doctor_name'] ?? 'Chưa xác định'),
            _infoRow('Tên bệnh nhân', appointment['patient_name'] ?? 'Chưa xác định'),
            
            const Divider(height: 30),
            
            Row(
              children: [
                Expanded(child: _infoRow('Ngày khám', appointment['available_date'] ?? '')),
                Expanded(child: _infoRow('Giờ khám', "${appointment['start_time']} - ${appointment['end_time']}")),
              ],
            ),
            
            _infoRow('Trạng thái hiện tại', _getStatusText(appointment['status'])),
            
            _infoRow('Lý do khám / Triệu chứng', appointment['reason'] ?? 'Không có thông tin bổ sung'),
            
            const SizedBox(height: 40),
            
            if (appointment['status'] == 'Confirmed' || appointment['status'] == 'Pending' || appointment['status'] == 'Chờ khám')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleCancel(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('HỦY LỊCH HẸN NÀY', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'Pending': return 'Đang chờ xác nhận';
      case 'Chờ khám': return 'Đang chờ khám';
      case 'Confirmed': return 'Đã xác nhận lịch';
      case 'Completed': return 'Đã hoàn thành ca khám';
      case 'Cancelled': return 'Đã hủy lịch';
      default: return status ?? 'Chưa xác định';
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
