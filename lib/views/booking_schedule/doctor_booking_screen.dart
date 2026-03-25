import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/appointment.dart';
import 'package:projectnhom/implementations/models/patient_profile.dart';
import 'package:projectnhom/implementations/models/schedule.dart';
import 'package:projectnhom/implementations/models/time_slots.dart';
import 'package:projectnhom/implementations/repository/appointment_repository.dart';
import 'package:projectnhom/implementations/repository/doctor_repository.dart';
import 'package:projectnhom/implementations/repository/patient_repository.dart';
import 'package:projectnhom/implementations/repository/scheule_repository.dart';
import 'package:projectnhom/views/booking_schedule/add_patient_screen.dart';
import 'package:projectnhom/views/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final int doctorId;

  const BookingScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final DoctorRepository _doctorRepo = DoctorRepository();
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  final PatientRepository _patientRepo = PatientRepository();
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  final TextEditingController _reasonController = TextEditingController();

  Map<String, dynamic>? _doctorDetail;
  List<Schedule> _schedules = [];
  List<TimeSlot> _availableSlots = [];
  List<PatientProfile> _profiles = [];

  Schedule? _selectedSchedule;
  TimeSlot? _selectedSlot;
  PatientProfile? _selectedProfile;
  int? _currentUserId;

  bool _isLoading = true;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getInt('user_id');

      final doctorDetail = await _doctorRepo.getDoctorDetail(widget.doctorId);
      final schedules = await _scheduleRepo.getSchedulesByDoctor(widget.doctorId);
      
      List<PatientProfile> profiles = [];
      if (_currentUserId != null) {
        profiles = await _patientRepo.getProfilesByUser(_currentUserId!);
      }

      if (!mounted) return;

      setState(() {
        _doctorDetail = doctorDetail;
        _schedules = schedules;
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSlots(int scheduleId) async {
    final slots = await _scheduleRepo.getAvailableSlots(scheduleId);
    if (!mounted) return;

    setState(() {
      _availableSlots = slots;
      _selectedSlot = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_doctorDetail == null) {
      return const Scaffold(
        body: Center(child: Text("Không tìm thấy bác sĩ")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Đặt lịch khám",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorHeader(),
                  const Divider(),
                  _buildSectionTitle("1. Chọn ngày khám"),
                  _buildScheduleList(),
                  _buildSectionTitle("2. Chọn khung giờ"),
                  _buildSlotGrid(),
                  _buildSectionTitle("3. Ai là người khám?"),
                  _buildPatientSelector(),
                  _buildSectionTitle("4. Lý do khám"),
                  _buildReasonInput(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_doctorDetail!['full_name'] ?? 'Bác sĩ').toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  (_doctorDetail!['specialty_name'] ?? 'Chưa rõ').toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "📍 ${(_doctorDetail!['clinic_name'] ?? 'Chưa rõ').toString()}",
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
                Text(
                  "💰 ${(_doctorDetail!['price'] ?? 0)} VNĐ",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_schedules.isEmpty) {
      return const Text(
        "Bác sĩ chưa có lịch khám sắp tới.",
        style: TextStyle(color: Colors.grey),
      );
    }

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _schedules.length,
        itemBuilder: (context, index) {
          final sch = _schedules[index];
          final isSelected = _selectedSchedule?.id == sch.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(sch.availableDate),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedSchedule = sch);
                  _loadSlots(sch.id!);
                }
              },
              selectedColor: Colors.blue.shade100,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotGrid() {
    if (_selectedSchedule == null) {
      return const Text(
        "Vui lòng chọn ngày trước",
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    }

    if (_availableSlots.isEmpty) {
      return const Text("Ngày này đã hết lịch trống");
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableSlots.map((slot) {
        final isSelected = _selectedSlot?.id == slot.id;
        return ActionChip(
          label: Text(slot.startTime),
          backgroundColor: isSelected ? Colors.blue : Colors.grey.shade100,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
          ),
          onPressed: () => setState(() => _selectedSlot = slot),
        );
      }).toList(),
    );
  }

  Widget _buildPatientSelector() {
    return Column(
      children: [
        ..._profiles.map((profile) {
          final isSelected = _selectedProfile?.id == profile.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedProfile = profile),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: 1.5,
                ),
                color: isSelected
                    ? Colors.blue.withValues(alpha: 0.05)
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
                            fontSize: 12,
                            color: Colors.grey,
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
        }),
        TextButton.icon(
          onPressed: _currentUserId == null
              ? null
              : () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPatientScreen(
                  userId: _currentUserId!,
                ),
              ),
            );
            if (result == true) {
              _loadAllData();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Thêm hồ sơ mới"),
        ),
      ],
    );
  }

  Widget _buildReasonInput() {
    return TextField(
      controller: _reasonController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "VD: Đau họng, sốt nhẹ từ tối qua...",
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final canBook = _selectedSlot != null &&
        _selectedProfile != null &&
        !_isBooking &&
        _currentUserId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ElevatedButton(
        onPressed: canBook ? _handleBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isBooking
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(color: Colors.white),
        )
            : const Text(
          "XÁC NHẬN ĐẶT LỊCH",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    if (_currentUserId == null ||
        _selectedSlot == null ||
        _selectedProfile == null) {
      return;
    }

    setState(() => _isBooking = true);

    final app = Appointment(
      patientId: _currentUserId!,
      doctorId: widget.doctorId,
      slotId: _selectedSlot!.id!,
      profileId: _selectedProfile!.id!,
      reason: _reasonController.text.trim(),
      status: 'Confirmed',
    );

    final success = await _appointmentRepo.createAppointment(app);

    if (!mounted) return;
    setState(() => _isBooking = false);

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi: Khung giờ này vừa có người đặt!"),
        ),
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
          "Đặt lịch thành công!",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(userId: _currentUserId!),
                ),
                    (route) => false,
              );
            },
            child: const Text("VỀ TRANG CHỦ"),
          ),
        ],
      ),
    );
  }
}
