import 'package:projectnhom/implementations/local/app_database.dart';
import 'package:projectnhom/implementations/models/appointment.dart';

class AppointmentRepository {
  final _appDb = AppDatabase.instance;

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

  // Lấy lịch hẹn cho BỆNH NHÂN
  Future<List<Map<String, dynamic>>> getAllAppointments(int userId) async {
    final db = await _appDb.db;
    final String sql = '''
    SELECT 
      a.appointment_id,
      a.status,
      a.reason,
      p.full_name as patient_name,
      u_doc.full_name as doctor_name,
      c.name as clinic_name,
      s.available_date,
      ts.start_time,
      ts.end_time,
      a.slot_id
    FROM appointments a
    JOIN patient_profiles p ON a.profile_id = p.profile_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN users u_doc ON d.user_id = u_doc.user_id 
    JOIN clinics c ON d.clinic_id = c.clinic_id
    JOIN time_slots ts ON a.slot_id = ts.slot_id
    JOIN schedules s ON ts.schedule_id = s.schedule_id
    WHERE p.user_id = ?
    ORDER BY s.available_date DESC, ts.start_time DESC
  ''';
    return await db.rawQuery(sql, [userId]);
  }

  // Lấy lịch hẹn cho BÁC SĨ
  Future<List<Map<String, dynamic>>> getDoctorAppointments(int userId) async {
    final db = await _appDb.db;
    final String sql = '''
    SELECT 
      a.appointment_id,
      a.status,
      a.reason,
      p.full_name as patient_name,
      p.gender as patient_gender,
      p.dob as patient_dob,
      s.available_date,
      ts.start_time,
      ts.end_time,
      a.slot_id
    FROM appointments a
    JOIN patient_profiles p ON a.profile_id = p.profile_id
    JOIN doctors d ON a.doctor_id = d.doctor_id
    JOIN time_slots ts ON a.slot_id = ts.slot_id
    JOIN schedules s ON ts.schedule_id = s.schedule_id
    WHERE d.user_id = ?
    ORDER BY s.available_date ASC, ts.start_time ASC
  ''';
    return await db.rawQuery(sql, [userId]);
  }

  // Cập nhật trạng thái lịch hẹn (Bác sĩ dùng)
  Future<bool> updateStatus(int appointmentId, String status) async {
    final db = await _appDb.db;
    try {
      await db.update(
        'appointments',
        {'status': status},
        where: 'appointment_id = ?',
        whereArgs: [appointmentId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId, int slotId) async {
    final db = await _appDb.db;
    return await db.transaction((txn) async {
      try {
        await txn.update(
          'appointments',
          {'status': 'Cancelled'},
          where: 'appointment_id = ?',
          whereArgs: [appointmentId],
        );
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
