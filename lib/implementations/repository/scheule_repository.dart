import 'package:projectnhom/implementations/local/app_database.dart';
import 'package:projectnhom/implementations/models/schedule.dart';
import 'package:projectnhom/implementations/models/time_slots.dart';
import 'package:sqflite/sqflite.dart';

class ScheduleRepository {
  final _appDb = AppDatabase.instance;

  // 1. Lấy danh sách các ngày bác sĩ có lịch khám
  Future<List<Schedule>> getSchedulesByDoctor(int doctorId) async {
    final db = await _appDb.db;

    final List<Map<String, dynamic>> maps = await db.query(
      'schedules',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'available_date DESC',
    );

    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  // 2. Lấy các khung giờ của một ngày khám
  Future<List<TimeSlot>> getTimeSlots(int scheduleId) async {
    final db = await _appDb.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_slots',
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
      orderBy: 'start_time ASC',
    );

    return maps.map((map) => TimeSlot.fromMap(map)).toList();
  }

  // 2.1 Lấy các khung giờ CÒN TRỐNG (is_booked = 0) của một ngày khám (Dành cho bệnh nhân đặt lịch)
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

  // 3. Thêm lịch khám mới và các khung giờ đi kèm
  Future<int> createScheduleWithSlots(Schedule schedule, List<TimeSlot> slots) async {
    final db = await _appDb.db;
    return await db.transaction((txn) async {
      int scheduleId = await txn.insert('schedules', {
        'doctor_id': schedule.doctorId,
        'available_date': schedule.availableDate,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
      });

      for (var slot in slots) {
        await txn.insert('time_slots', {
          'schedule_id': scheduleId,
          'start_time': slot.startTime,
          'end_time': slot.endTime,
          'is_booked': 0,
        });
      }
      return scheduleId;
    });
  }

  // 4. Xóa lịch khám (và các khung giờ liên quan)
  Future<void> deleteSchedule(int scheduleId) async {
    final db = await _appDb.db;
    await db.transaction((txn) async {
      await txn.delete('time_slots', where: 'schedule_id = ?', whereArgs: [scheduleId]);
      await txn.delete('schedules', where: 'schedule_id = ?', whereArgs: [scheduleId]);
    });
  }

  // 5. Cập nhật khung giờ (ví dụ: đánh dấu đã đặt)
  Future<void> updateTimeSlot(TimeSlot slot) async {
    final db = await _appDb.db;
    await db.update(
      'time_slots',
      {'is_booked': slot.isBooked ? 1 : 0},
      where: 'slot_id = ?',
      whereArgs: [slot.id],
    );
  }

  // 6. Xóa một khung giờ đơn lẻ
  Future<void> deleteTimeSlot(int slotId) async {
    final db = await _appDb.db;
    await db.delete('time_slots', where: 'slot_id = ?', whereArgs: [slotId]);
  }

  // 7. Thêm một khung giờ mới vào lịch có sẵn
  Future<void> addTimeSlot(TimeSlot slot) async {
    final db = await _appDb.db;
    await db.insert('time_slots', {
      'schedule_id': slot.scheduleId,
      'start_time': slot.startTime,
      'end_time': slot.endTime,
      'is_booked': slot.isBooked ? 1 : 0,
    });
  }

  Future<int?> getDoctorIdByUserId(int userId) async {
    final db = await _appDb.db;
    final List<Map<String, dynamic>> results = await db.query(
      'doctors',
      columns: ['doctor_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (results.isNotEmpty) {
      return results.first['doctor_id'] as int;
    }
    return null;
  }
}
