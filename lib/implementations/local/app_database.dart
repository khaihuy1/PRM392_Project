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
    final path = join(dbPath, 'medical_booking_v4.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        print("--- ĐANG KHỞI TẠO CƠ SỞ DỮ LIỆU ---");

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

        await db.execute('''
          CREATE TABLE patient_profiles(
            profile_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            full_name TEXT,
            gender TEXT,
            relationship TEXT,
            dob TEXT,
            phone_number TEXT,
            diagnosis TEXT, -- THÊM CỘT CHẨN ĐOÁN
            FOREIGN KEY(user_id) REFERENCES users(user_id)
          );
        ''');

        await db.execute('''
          CREATE TABLE specialties(
            specialty_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE clinics(
            clinic_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone_number TEXT,
            operating_hours TEXT,
            address TEXT
          );
        ''');

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
    });

    await db.insert('users', {
      'full_name': 'Bác sĩ Lê Mạnh Hùng',
      'email': 'hung.le@clinic.com',
      'password_hash': '123456',
      'role': 'Doctor'
    });

    await db.insert('patient_profiles', {
      'user_id': 2,
      'full_name': 'Khai Huy',
      'gender': 'Nam',
      'relationship': 'Bản thân',
      'dob': '2002-10-20',
      'phone_number': '0912345678',
      'diagnosis': 'Khỏe mạnh'
    });

    await db.insert('specialties', {'name': 'Nội Tổng Quát', 'description': 'Khám sàng lọc'});
    await db.insert('clinics', {'name': 'Phòng khám Đa khoa Quốc tế', 'address': '456 Võ Văn Kiệt', 'operating_hours': '08:00 - 20:00'});
    await db.insert('doctors', {
      'user_id': 3, 'specialty_id': 1, 'clinic_id': 1,
      'bio': '15 năm kinh nghiệm', 'experience_years': 15, 'rating': 4.9, 'price': 300000
    });
  }
}