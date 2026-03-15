import 'package:projectnhom/implementations/local/app_database.dart';
import 'package:projectnhom/implementations/models/appointment.dart';

class AppointmentRepository {
  final _appDb = AppDatabase.instance;

  // --- Hàm createAppointment của bạn giữ nguyên ---
  Future<bool> createAppointment(Appointment appointment) async {
    final db = await _appDb.db;
    return await db.transaction((txn) async {
      try {
        final List<Map<String, dynamic>> slotCheck = await txn.query(
          'time_slots',
          where: 'slot_id = ? AND is_booked = 0',
          whereArgs: [appointment.slotId],
        );

        if (slotCheck.isEmpty) return false;

        await txn.insert('appointments', appointment.toMap());

        await txn.update(
          'time_slots',
          {'is_booked': 1},
          where: 'slot_id = ?',
          whereArgs: [appointment.slotId],
        );
        return true;
      } catch (e) {
        return false;
      }
    });
  }

  // --- HÀM MỚI: LẤY TẤT CẢ LỊCH HẸN CỦA MỘT USER ---
  Future<List<Map<String, dynamic>>> getAllAppointments(int userId) async {
    final db = await _appDb.db;

    final String sql = '''
    SELECT 
      a.appointment_id,
      a.status,
      p.full_name as patient_name,    -- Lấy từ bảng patient_profiles
      u_doc.full_name as doctor_name, -- Lấy từ bảng users (thông qua bảng doctors)
      c.name as clinic_name,          -- Lấy từ bảng clinics
      s.available_date,               -- Lấy từ bảng schedules
      ts.start_time,                  -- Lấy từ bảng time_slots
      ts.end_time,
      a.slot_id
    FROM appointments a
    JOIN patient_profiles p ON a.profile_id = p.profile_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN users u_doc ON d.user_id = u_doc.user_id 
    JOIN clinics c ON d.clinic_id = c.clinic_id
    -- 4. Lấy khung giờ và ngày khám
    JOIN time_slots ts ON a.slot_id = ts.slot_id
    JOIN schedules s ON ts.schedule_id = s.schedule_id
    -- Lọc theo user đang đăng nhập (chủ sở hữu các hồ sơ bệnh nhân)
    WHERE p.user_id = ?
   AND s.available_date >= date('now') -- Chỉ lấy từ ngày hiện tại trở đi
   ORDER BY s.available_date ASC, ts.start_time ASC -- Sắp xếp lịch gần nhất lên đầu
  ''';

    return await db.rawQuery(sql, [userId]);
  }

  Future<bool> cancelAppointment(int appointmentId, int slotId) async {
    final db = await _appDb.db;

    return await db.transaction((txn) async {
      try {
        // 1. Cập nhật trạng thái appointment thành 'Cancelled' thay vì xóa
        int updatedCount = await txn.update(
          'appointments',
          {'status': 'Cancelled'}, // Đổi từ xóa thành update status
          where: 'appointment_id = ?',
          whereArgs: [appointmentId],
        );

        if (updatedCount == 0) return false;

        // 2. Vẫn cần mở lại slot giờ khám đó để người khác có thể đặt
        await txn.update(
          'time_slots',
          {'is_booked': 0},
          where: 'slot_id = ?',
          whereArgs: [slotId],
        );

        return true;
      } catch (e) {
        return false;
      }
    });
  }
}
