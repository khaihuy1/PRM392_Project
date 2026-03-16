import 'package:projectnhom/implementations/local/app_database.dart';
import 'package:projectnhom/implementations/models/schedule.dart';
import 'package:projectnhom/implementations/models/time_slots.dart';

class ScheduleRepository {
  final _appDb = AppDatabase.instance;

  // 1. Lấy danh sách các ngày bác sĩ có lịch khám
  Future<List<Schedule>> getSchedulesByDoctor(int doctorId) async {
    final db = await _appDb.db;

    // Lọc những ngày khám bắt đầu từ ngày mốt (hôm nay + 1 ngày)
    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'doctor_id = ? AND available_date > date("now", "+1 day")',
      whereArgs: [doctorId],
      orderBy: 'available_date ASC',
    );

    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  // 2. Lấy các khung giờ CÒN TRỐNG (is_booked = 0) của một ngày khám
  Future<List<TimeSlot>> getAvailableSlots(int scheduleId) async {
    final db = await _appDb.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_slots',
      where: 'schedule_id = ? AND is_booked = 0',
      whereArgs: [scheduleId],
      orderBy: 'start_time ASC',
    );

    return maps.map((map) => TimeSlot.fromMap(map)).toList();
  }
}
