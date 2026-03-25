import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/appointment.dart';
import 'package:projectnhom/implementations/models/clinic.dart';
import 'package:projectnhom/implementations/models/doctor.dart';
import 'package:projectnhom/implementations/models/patient_profile.dart';
import 'package:projectnhom/implementations/models/schedule.dart';
import 'package:projectnhom/implementations/models/specialty.dart';
import 'package:projectnhom/implementations/models/time_slots.dart';
import 'package:projectnhom/implementations/repository/appointment_repository.dart';

class BookingController extends ChangeNotifier {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();

  // Dữ liệu người dùng chọn qua từng màn hình
  Specialty? selectedSpecialty;
  Clinic? selectedClinic;
  Doctor? selectedDoctor;
  Schedule? selectedSchedule;
  TimeSlot? selectedSlot;
  PatientProfile? selectedProfile;
  String reason = "";

  // Hàm cập nhật dữ liệu khi người dùng chọn ở mỗi bước
  void updateSpecialty(Specialty specialty) {
    selectedSpecialty = specialty;
    // Reset các bước sau nếu người dùng chọn lại chuyên khoa
    selectedClinic = null;
    selectedDoctor = null;
    notifyListeners();
  }

  void updateClinic(Clinic clinic) {
    selectedClinic = clinic;
    selectedDoctor = null;
    notifyListeners();
  }

  void updateDoctor(Doctor doctor) {
    selectedDoctor = doctor;
    notifyListeners();
  }

  void updateDateTime(Schedule schedule, TimeSlot slot) {
    selectedSchedule = schedule;
    selectedSlot = slot;
    notifyListeners();
  }

  // Logic xác nhận đặt lịch cuối cùng
  Future<bool> confirmBooking(int currentUserId) async {
    if (selectedDoctor == null || selectedSlot == null || selectedProfile == null) {
      return false;
    }

    final appointment = Appointment(
      patientId: currentUserId,
      doctorId: selectedDoctor!.doctorId,
      slotId: selectedSlot!.id!,
      profileId: selectedProfile!.id!,
      reason: reason,
      status: 'Confirmed',
    );

    return await _appointmentRepo.createAppointment(appointment);
  }
}