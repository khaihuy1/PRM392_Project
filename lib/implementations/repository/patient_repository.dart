
import 'package:projectnhom/implementations/local/app_database.dart';
import 'package:projectnhom/implementations/models/patient_profile.dart';

class PatientRepository {
  final _appDb = AppDatabase.instance;

  // 1. Lấy tất cả hồ sơ người thân của một User (để chọn khi đặt lịch)
  Future<List<PatientProfile>> getProfilesByUser(int userId) async {
    final db = await _appDb.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'patient_profiles',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return maps.map((map) => PatientProfile.fromMap(map)).toList();
  }

  // 2. Thêm mới một hồ sơ người thân
  Future<int> addProfile(PatientProfile profile) async {
    final db = await _appDb.db;
    return await db.insert('patient_profiles', profile.toMap());
  }

  // 3. Cập nhật hồ sơ
  Future<int> updateProfile(PatientProfile profile) async {
    final db = await _appDb.db;
    return await db.update(
      'patient_profiles',
      profile.toMap(),
      where: 'profile_id = ?',
      whereArgs: [profile.id],
    );
  }

  // 4. Xóa hồ sơ
  Future<int> deleteProfile(int profileId) async {
    final db = await _appDb.db;
    return await db.delete(
      'patient_profiles',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
  }
}