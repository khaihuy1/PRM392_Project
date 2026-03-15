
import 'package:projectnhom/implementations/local/app_database.dart';
import 'package:projectnhom/implementations/models/clinic.dart';

class ClinicRepository {
  final _appDb = AppDatabase.instance;

  Future<List<Clinic>> getClinicsBySpecialty(int specialtyId) async {
    final db = await _appDb.db;
    // raw Query là truy vân thuần
    // query thư viện cung cấp săn các tham số
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT c.* FROM clinics c
      JOIN doctors d ON c.clinic_id = d.clinic_id
      WHERE d.specialty_id = ?
    ''', [specialtyId]);

    return maps.map((map) => Clinic.fromMap(map)).toList();
  }
}