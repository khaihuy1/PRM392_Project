import 'package:projectnhom/implementations/local/app_database.dart';
import 'package:projectnhom/implementations/models/doctor.dart';

class DoctorRepository {
  final _appDb = AppDatabase.instance;

  Future<List<Doctor>> getDoctorsBySpecialtyAndClinic(
    int specialtyId,
    int clinicId,
  ) async {
    final db = await _appDb.db;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT d.*, u.full_name
      FROM doctors d
      JOIN users u ON d.user_id = u.user_id
      WHERE d.specialty_id = ? AND d.clinic_id = ?
    ''',
      [specialtyId, clinicId],
    );

    return maps.map((map) => Doctor.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>?> getDoctorDetail(int doctorId) async {
    final db = await _appDb.db;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT d.*, u.full_name, s.name AS specialty_name, c.name AS clinic_name
    FROM doctors d
    JOIN users u ON d.user_id = u.user_id
    JOIN specialties s ON d.specialty_id = s.specialty_id
    JOIN clinics c ON d.clinic_id = c.clinic_id
    WHERE d.doctor_id = ?
  ''', [doctorId]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllDoctorsWithDetails() async {
    final db = await _appDb.db;

    // Sử dụng JOIN để lấy thông tin từ các bảng liên quan
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        d.*, 
        u.full_name, 
        s.name AS specialty_name, 
        c.name AS clinic_name
      FROM doctors d
      JOIN users u ON d.user_id = u.user_id
      JOIN specialties s ON d.specialty_id = s.specialty_id
      JOIN clinics c ON d.clinic_id = c.clinic_id
    ''');

    return result;
  }
}
