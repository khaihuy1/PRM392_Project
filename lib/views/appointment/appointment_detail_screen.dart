import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/repository/appointment_repository.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final AppointmentRepository _repo = AppointmentRepository();

  AppointmentDetailScreen({super.key, required this.appointment});

  void _handleCancel(BuildContext context) async {
    // Hiển thị hộp thoại xác nhận
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
        appointment['slot_id'], // Bạn nhớ JOIN thêm slot_id ở câu SQL getAll nhé
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã hủy lịch thành công')));
        Navigator.pop(
          context,
          true,
        ); // Quay lại trang danh sách và báo cần load lại
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết lịch khám')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Bác sĩ', appointment['doctor_name']),
            _infoRow('Bệnh nhân', appointment['patient_name']),
            _infoRow('Ngày khám', appointment['available_date']),
            _infoRow(
              'Giờ khám',
              "${appointment['start_time']} - ${appointment['end_time']}",
            ),
            _infoRow('Trạng thái', appointment['status']),
            const Spacer(),
            if (appointment['status'] == 'Confirmed' ||
                appointment['status'] == 'Pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleCancel(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'HỦY LỊCH KHÁM',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
