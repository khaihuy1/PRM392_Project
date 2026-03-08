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
    final path = join(dbPath, 'medical_booking.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // USERS
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

        // PATIENT PROFILES
        await db.execute('''
        CREATE TABLE patient_profiles(
          profile_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          full_name TEXT,
          relationship TEXT,
          dob TEXT,
          FOREIGN KEY(user_id) REFERENCES users(user_id)
        );
        ''');

        // SPECIALTIES
        await db.execute('''
        CREATE TABLE specialties(
          specialty_id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT
        );
        ''');

        // CLINICS
        await db.execute('''
        CREATE TABLE clinics(
          clinic_id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          address TEXT
        );
        ''');

        // DOCTORS
        await db.execute('''
        CREATE TABLE doctors(
          doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          specialty_id INTEGER,
          clinic_id INTEGER,
          bio TEXT,
          experience_years INTEGER,
          rating REAL,
          FOREIGN KEY(user_id) REFERENCES users(user_id),
          FOREIGN KEY(specialty_id) REFERENCES specialties(specialty_id),
          FOREIGN KEY(clinic_id) REFERENCES clinics(clinic_id)
        );
        ''');

        // SCHEDULES
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

        // TIME SLOTS
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

        // APPOINTMENTS
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

        // REVIEWS
        await db.execute('''
        CREATE TABLE reviews(
          review_id INTEGER PRIMARY KEY AUTOINCREMENT,
          appointment_id INTEGER,
          rating INTEGER,
          comment TEXT,
          created_at TEXT,
          FOREIGN KEY(appointment_id) REFERENCES appointments(appointment_id)
        );
        ''');

        // NOTIFICATIONS
        await db.execute('''
        CREATE TABLE notifications(
          notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          title TEXT,
          message TEXT,
          is_read INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(user_id) REFERENCES users(user_id)
        );
        ''');

        // MEDICAL RECORDS
        await db.execute('''
        CREATE TABLE medical_records(
          record_id INTEGER PRIMARY KEY AUTOINCREMENT,
          appointment_id INTEGER,
          diagnosis TEXT,
          prescription TEXT,
          notes TEXT,
          FOREIGN KEY(appointment_id) REFERENCES appointments(appointment_id)
        );
        ''');

        // Seed admin user
        await db.insert('users', {
          'full_name': 'Admin',
          'email': 'admin@gmail.com',
          'password_hash': '123456',
          'role': 'Admin',
        });
      },

      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < newVersion) {
          // Handle migrations later
        }
      },
    );
  }
}
