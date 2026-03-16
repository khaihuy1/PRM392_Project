import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/appointment.dart';
import 'package:projectnhom/implementations/models/patient_profile.dart';
import 'package:projectnhom/implementations/repository/appointment_repository.dart';
import 'package:projectnhom/implementations/repository/patient_repository.dart';
import 'package:projectnhom/views/booking_schedule/add_patient_screen.dart';
import 'package:projectnhom/views/landing_page.dart';
import 'package:projectnhom/views/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';



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
  // 1. Hàm helper lấy UserId
  Future<int?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // 2. Hàm gom nhóm logic lấy dữ liệu cho FutureBuilder
  Future<Map<String, dynamic>> _loadInitialData() async {
    int? userId = await getSavedUserId();
    if (userId == null) throw Exception("User not logged in");

    final profiles = await _patientRepo.getProfilesByUser(userId);
    return {'userId': userId, 'profiles': profiles};
  }

  final PatientRepository _patientRepo = PatientRepository();
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  final TextEditingController _reasonController = TextEditingController();

  PatientProfile? selectedProfile;
  bool isBooking = false;

  @override
  Widget build(BuildContext context) {
    // Sử dụng FutureBuilder bao ngoài để lấy UserId trước khi vẽ UI
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadInitialData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Lỗi tải dữ liệu người dùng")),
          );
        }

        final int currentUserId = snapshot.data!['userId'];
        final List<PatientProfile> profiles = snapshot.data!['profiles'];

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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Truyền dữ liệu vào danh sách hồ sơ
                      _buildProfileList(profiles, currentUserId),

                      const SizedBox(height: 24),
                      // ... phần Lý do khám giữ nguyên ...
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
              _buildActions(currentUserId), // Truyền ID vào hàm xác nhận
            ],
          ),
        );
      },
    );
  }

  // ===================== LOGIC & WIDGETS ĐÃ SỬA =====================

  Widget _buildProfileList(List<PatientProfile> profiles, int currentUserId) {
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
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

        OutlinedButton.icon(
          onPressed: () async {
            // Dùng ID lấy từ FutureBuilder
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPatientScreen(userId: currentUserId),
              ),
            );
            if (result == true) setState(() {});
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm hồ sơ người thân'),
        ),
      ],
    );
  }

  Widget _buildActions(int currentUserId) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (selectedProfile == null || isBooking)
              ? null
              : () => _handleBooking(currentUserId), // Truyền ID vào đây
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

  Future<void> _handleBooking(int currentUserId) async {
    setState(() => isBooking = true);

    final appointment = Appointment(
      patientId: currentUserId,
      // ĐÃ SỬA: Không dùng số 1 nữa
      doctorId: widget.doctorId,
      slotId: widget.slotId,
      profileId: selectedProfile!.id!,
      reason: _reasonController.text,
      status: 'Confirmed',
    );

    final success = await _appointmentRepo.createAppointment(appointment);
    setState(() => isBooking = false);

    if (success) {
      _showSuccessDialog(currentUserId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Khung giờ này vừa có người đặt!')),
      );
    }
  }

  void _showSuccessDialog(int currentUserId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text('Đặt lịch thành công!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(userId: currentUserId),
              ),
              (route) => false,
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
