import '../local/app_database.dart';
import '../models/doctor.dart';

class DoctorRepository {
  final AppDatabase _database = AppDatabase.instance;

  // Lấy danh sách bác sĩ dưới dạng Map (cho các widget cần xử lý thủ công)
  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    return await _database.getAllDoctors();
  }

  // Lấy danh sách bác sĩ và chuyển sang Model Doctor
  Future<List<Doctor>> getAllDoctorsAsModel() async {
    final result = await _database.getAllDoctors();
    return result.map((e) => Doctor.fromMap(e)).toList();
  }

  // Lấy thông tin chi tiết 1 bác sĩ theo ID
  Future<Doctor?> getDoctorById(int doctorId) async {
    final result = await _database.getDoctorById(doctorId);
    if (result == null) return null;
    return Doctor.fromMap(result);
  }

  // Lấy map thông tin chi tiết bác sĩ (bao gồm Clinic, Specialty, User)
  Future<Map<String, dynamic>?> getDoctorDetail(int doctorId) async {
    return await _database.getDoctorById(doctorId);
  }

  // Lấy danh sách bác sĩ theo chuyên khoa
  Future<List<Doctor>> getDoctorsBySpecialty(int specialtyId) async {
    final result = await _database.getDoctorsBySpecialty(specialtyId);
    return result.map((e) => Doctor.fromMap(e)).toList();
  }

  // Lấy danh sách bác sĩ theo chuyên khoa và phòng khám
  Future<List<Doctor>> getDoctorsBySpecialtyAndClinic(
    int specialtyId,
    int clinicId,
  ) async {
    final result = await _database.getDoctorsBySpecialtyAndClinic(
      specialtyId,
      clinicId,
    );
    return result.map((e) => Doctor.fromMap(e)).toList();
  }

  // Lấy tất cả bác sĩ kèm thông tin chi tiết (Clinic, Specialty, User)
  Future<List<Map<String, dynamic>>> getAllDoctorsWithDetails() async {
    return await _database.getAllDoctorsWithDetails();
  }
}
