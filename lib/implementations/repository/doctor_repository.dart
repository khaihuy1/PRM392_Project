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
}
