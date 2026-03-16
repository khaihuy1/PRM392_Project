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
    // Nâng cấp lên v5 để cập nhật dữ liệu mẫu mới
    final path = join(dbPath, 'medical_booking_v5.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        print("--- ĐANG KHỞI TẠO CƠ SỞ DỮ LIỆU V5 ---");

        // 1. USERS
        await db.execute('''
          CREATE TABLE users(
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            email TEXT UNIQUE,
            phone_number TEXT,
            password_hash TEXT,
            role TEXT,
            ethnicity TEXT,
            city TEXT,
            ward TEXT,
            detail_address TEXT,
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
    print("--- ĐANG NẠP DỮ LIỆU MẪU CHI TIẾT ---");

    // 1. Chèn User mẫu: Khai Huy
    int khaiHuyId = await db.insert('users', {
      'full_name': 'Khai Huy',
      'email': 'khaihuy@student.com',
      'phone_number': '0912345678',
      'password_hash': '123456',
      'role': 'Patient',
      'ethnicity': 'Kinh',
      'city': 'Thành phố Hà Nội',
      'ward': 'Huyện Thạch Thất',
      'detail_address': 'Đại học FPT'
    });

    // 2. Chèn Hồ sơ bệnh nhân cho Khai Huy (như khi đăng ký)
    await db.insert('patient_profiles', {
      'user_id': khaiHuyId,
      'full_name': 'Khai Huy',
      'gender': 'Nam',
      'relationship': 'Bản thân',
      'dob': '20/10/2002',
      'phone_number': '0912345678'
    });

    // 3. Chèn Admin mẫu
    await db.insert('users', {
      'full_name': 'Admin System',
      'email': 'admin@clinic.com',
      'password_hash': '123456',
      'role': 'Admin'
    });

    // 4. Chèn Chuyên khoa mẫu
    await db.insert('specialties', {'name': 'Nội Tổng Quát', 'description': 'Khám sàng lọc và tư vấn sức khỏe tổng thể'});
    await db.insert('specialties', {'name': 'Tim Mạch', 'description': 'Chuyên khoa sâu về tim và huyết áp'});

    // 5. Chèn Phòng khám mẫu
    await db.insert('clinics', {
      'name': 'Bệnh viện Đa khoa Quốc tế Vinmec', 
      'address': '458 Minh Khai, Hai Bà Trưng, Hà Nội', 
      'operating_hours': '24/7'
    });

    print("--- DỮ LIỆU MẪU ĐÃ SẴN SÀNG ---");
  }
}
