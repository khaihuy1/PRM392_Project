import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/repository/appointment_repository.dart';

class AppointmentController extends ChangeNotifier {
  final AppointmentRepository _repository = AppointmentRepository();

  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get appointments => _appointments;
  bool get isLoading => _isLoading;

  // Hàm lấy danh sách và xử lý lại dữ liệu
  Future<void> fetchAppointments(int userId) async {
    _isLoading = true;
    notifyListeners(); // Báo UI hiện loading

    try {
      _appointments = await _repository.getAllAppointments(userId);
    } catch (e) {
      debugPrint("Lỗi tại Controller: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Báo UI tắt loading và hiển thị data
    }
  }

  // Hàm xử lý hủy lịch (Ví dụ thêm)
  Future<bool> cancelAppointment(int appointmentId, int slotId) async {
    return true;
  }
}