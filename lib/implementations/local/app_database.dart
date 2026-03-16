import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    // Lưu ý: Đã đổi tên file để cơ sở dữ liệu được khởi tạo lại với mật khẩu mới
    final path = join(dbPath, 'medical_booking_v3.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        print("--- ĐANG KHỞI TẠO CƠ SỞ DỮ LIỆU ---");

        // 1. USERS
        await db.execute('''
          CREATE TABLE users(
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            email TEXT UNIQUE,
            phone_number TEXT,
            password_hash TEXT,
            role TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          );
        ''');

        // 2. PATIENT PROFILES
        await db.execute('''
          CREATE TABLE patient_profiles(
            profile_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            full_name TEXT,
            gender TEXT,
            relationship TEXT,
            dob TEXT,
            phone_number TEXT,
            FOREIGN KEY(user_id) REFERENCES users(user_id)
          );
        ''');

        // 3. SPECIALTIES
        await db.execute('''
          CREATE TABLE specialties(
            specialty_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT
          );
        ''');

        // 4. CLINICS
        await db.execute('''
          CREATE TABLE clinics(
            clinic_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone_number TEXT,
            operating_hours TEXT,
            address TEXT
          );
        ''');

        // 5. DOCTORS
        await db.execute('''
          CREATE TABLE doctors(
            doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            specialty_id INTEGER,
            clinic_id INTEGER,
            bio TEXT,
            experience_years INTEGER,
            rating REAL,
            price INTEGER DEFAULT 0,
            FOREIGN KEY(user_id) REFERENCES users(user_id),
            FOREIGN KEY(specialty_id) REFERENCES specialties(specialty_id),
            FOREIGN KEY(clinic_id) REFERENCES clinics(clinic_id)
          );
        ''');

        // 6. SCHEDULES
        await db.execute('''
          CREATE TABLE schedules(
            schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,
            doctor_id INTEGER,
            available_date TEXT,
            start_time TEXT,
            end_time TEXT,
            FOREIGN KEY(doctor_id) REFERENCES doctors(doctor_id)
          );
        ''');

        // 7. TIME SLOTS
        await db.execute('''
          CREATE TABLE time_slots(
            slot_id INTEGER PRIMARY KEY AUTOINCREMENT,
            schedule_id INTEGER,
            start_time TEXT,
            end_time TEXT,
            is_booked INTEGER DEFAULT 0,
            FOREIGN KEY(schedule_id) REFERENCES schedules(schedule_id)
          );
        ''');

        // 8. APPOINTMENTS
        await db.execute('''
          CREATE TABLE appointments(
            appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id INTEGER,
            doctor_id INTEGER,
            slot_id INTEGER,
            profile_id INTEGER,
            reason TEXT,
            status TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(patient_id) REFERENCES users(user_id),
            FOREIGN KEY(doctor_id) REFERENCES doctors(doctor_id),
            FOREIGN KEY(slot_id) REFERENCES time_slots(slot_id),
            FOREIGN KEY(profile_id) REFERENCES patient_profiles(profile_id)
          );
        ''');

        await _seedData(db);
      },
    );
  }

  Future<void> _seedData(Database db) async {
    print("--- ĐANG NẠP DỮ LIỆU MẪU CÓ MẬT KHẨU ---");

    // 1. Chèn Users với mật khẩu mặc định là '123456'
    await db.insert('users', {
      'full_name': 'Admin System',
      'email': 'admin@clinic.com',
      'password_hash': '123456',
      'role': 'Admin'
    });
    
    await db.insert('users', {
      'full_name': 'Khai Huy',
      'email': 'khaihuy@student.com',
      'password_hash': '123456',
      'role': 'Patient'
    }); // id: 2

    await db.insert('users', {
      'full_name': 'Bác sĩ Lê Mạnh Hùng',
      'email': 'hung.le@clinic.com',
      'password_hash': '123456',
      'role': 'Doctor'
    }); // id: 3

    await db.insert('users', {
      'full_name': 'Bác sĩ Phạm Minh Anh',
      'email': 'anh.pham@clinic.com',
      'password_hash': '123456',
      'role': 'Doctor'
    }); // id: 4

    // 2. Chèn Hồ sơ bệnh nhân
    await db.insert('patient_profiles', {
      'user_id': 2,
      'full_name': 'Khai Huy (Bản thân)',
      'gender': 'Nam',
      'relationship': 'Bản thân',
      'dob': '2002-10-20',
      'phone_number': '0912345678'
    });
    await db.insert('patient_profiles', {
      'user_id': 2,
      'full_name': 'Trần Thị Em',
      'gender': 'Nữ',
      'relationship': 'Em gái',
      'dob': '2010-05-12',
      'phone_number': '0988888888'
    });

    // 3. Chèn Chuyên khoa
    await db.insert('specialties', {'name': 'Nội Tổng Quát', 'description': 'Khám sàng lọc, tư vấn sức khỏe tổng thể'});
    await db.insert('specialties', {'name': 'Tim Mạch', 'description': 'Chuyên khoa về tim và huyết áp'});
    await db.insert('specialties', {'name': 'Nhi Khoa', 'description': 'Chăm sóc sức khỏe toàn diện cho trẻ em'});

    // 4. Chèn Phòng khám
    await db.insert('clinics', {'name': 'Phòng khám Đa khoa Quốc tế', 'address': '456 Võ Văn Kiệt, Quận 1', 'operating_hours': '08:00 - 20:00'});
    await db.insert('clinics', {'name': 'Bệnh viện Vinmec', 'address': '208 Nguyễn Hữu Cảnh, Bình Thạnh', 'operating_hours': '24/7'});

    // 5. Chèn Bác sĩ
    await db.insert('doctors', {
      'user_id': 3, 'specialty_id': 1, 'clinic_id': 1,
      'bio': '15 năm kinh nghiệm tại BV Bạch Mai', 'experience_years': 15, 'rating': 4.9, 'price': 300000
    });
    await db.insert('doctors', {
      'user_id': 4, 'specialty_id': 3, 'clinic_id': 2,
      'bio': 'Chuyên gia tâm lý và sức khỏe nhi nhi', 'experience_years': 8, 'rating': 4.7, 'price': 500000
    });

    // 6. Lịch khám
    int schId = await db.insert('schedules', {
      'doctor_id': 1, 'available_date': '2026-03-20', 'start_time': '08:00', 'end_time': '12:00'
    });

    List<String> hours = ['08:00', '08:30', '09:00', '09:30', '10:00', '10:30'];
    for (String h in hours) {
      await db.insert('time_slots', {
        'schedule_id': schId, 'start_time': h, 'end_time': '', 'is_booked': 0
      });
    }

    print("--- DỮ LIỆU MẪU ĐÃ ĐƯỢC CẬP NHẬT MẬT KHẨU ---");
  }
}
