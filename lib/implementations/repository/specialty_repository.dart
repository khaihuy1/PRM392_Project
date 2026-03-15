import 'package:projectnhom/implementations/local/app_database.dart';
import 'package:projectnhom/implementations/models/specialty.dart';

class SpecialtyRepository {
  final database = AppDatabase.instance;

  Future<List<Specialty>> fetchAllSpecialties() async {
    final db = await database.db;
    final List<Map<String, dynamic>> maps = await db.query('specialties');
    return List.generate(maps.length, (i) {
      return Specialty.fromMap(maps[i]);
    });
  }
}
