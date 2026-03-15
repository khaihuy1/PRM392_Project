import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/appointment.dart';
import 'package:projectnhom/implementations/models/patient_profile.dart';
import 'package:projectnhom/implementations/repository/appointment_repository.dart';
import 'package:projectnhom/implementations/repository/patient_repository.dart';
import 'package:projectnhom/views/booking_schedule/add_patient_screen.dart';
import 'package:projectnhom/views/landing_page.dart';
import 'package:projectnhom/views/main_screen.dart';

class SelectPatientScreen extends StatefulWidget {
  final int doctorId;
  final int slotId;

  const SelectPatientScreen({
    super.key,
    required this.doctorId,
    required this.slotId,
  });

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  final PatientRepository _patientRepo = PatientRepository();
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  final TextEditingController _reasonController = TextEditingController();

  PatientProfile? selectedProfile;
  bool isBooking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgress(),
          const SizedBox(height: 12),
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ai là người khám?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 1. DANH SÁCH HỒ SƠ
                  _buildProfileList(),

                  const SizedBox(height: 24),

                  // 2. NHẬP LÝ DO KHÁM
                  const Text(
                    'Lý do khám',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Mô tả triệu chứng hoặc lý do khám...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  // ===================== LOGIC & WIDGETS =====================

  Widget _buildProfileList() {
    return FutureBuilder<List<PatientProfile>>(
      future: _patientRepo.getProfilesByUser(2),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();

        final profiles = snapshot.data ?? [];

        return Column(
          children: [
            ...profiles.map((profile) {
              final isSelected = selectedProfile?.id == profile.id;
              return GestureDetector(
                onTap: () => setState(() => selectedProfile = profile),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    color: isSelected
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(profile.fullName[0]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              profile.relationship,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.blue),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Nút thêm hồ sơ mới
            OutlinedButton.icon(
              onPressed: () async {
                // Giả sử ID người dùng đăng nhập hiện tại là 2 (Khai Huy)
                // Trong thực tế, bạn có thể lấy từ AuthProvider hoặc một biến Global
                int currentLoggedInUserId = 2;

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPatientScreen(userId: currentLoggedInUserId),
                  ),
                );

                if (result == true) {
                  setState(() {});
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm hồ sơ người thân'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (selectedProfile == null || isBooking)
              ? null
              : _handleBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isBooking
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'XÁC NHẬN ĐẶT LỊCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    setState(() => isBooking = true);

    final appointment = Appointment(
      patientId: 1,
      doctorId: widget.doctorId,
      slotId: widget.slotId,
      profileId: selectedProfile!.id!,
      reason: _reasonController.text,
      status: 'Confirmed',
    );

    final success = await _appointmentRepo.createAppointment(appointment);

    setState(() => isBooking = false);

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Khung giờ này vừa có người đặt!')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text(
          'Đặt lịch thành công! Bạn có thể kiểm tra lại trong phần lịch sử.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(userId: 2),
              ),
            ),
            child: const Text('VỀ TRANG CHỦ'),
          ),
        ],
      ),
    );
  }

  // --- Các hàm UI AppBar, Progress, StepIndicator dán tương tự các màn trước ---
  AppBar _buildAppBar() =>
      AppBar(title: const Text('Thông tin bệnh nhân'), elevation: 0);

  Widget _buildProgress() =>
      const LinearProgressIndicator(value: 1.0, color: Colors.blue);

  Widget _buildStepIndicator() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Text(
      "Bước 5 / 5 - Hoàn tất",
      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    ),
  );
}
