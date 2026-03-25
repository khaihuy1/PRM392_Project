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
    // Đổi tên DB để khởi tạo lại với dữ liệu mới (mỗi chuyên khoa 2-3 bác sĩ)
    final path = join(dbPath, 'medical_booking_v5.db');

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
            diagnosis TEXT,
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
            position TEXT,
            workplace TEXT,
            services TEXT,
            education TEXT,
            work_experience_detail TEXT,
            organizations TEXT,
            research_works TEXT,
            avatar TEXT,
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
    print("--- ĐANG NẠP DỮ LIỆU MẪU ---");

    // 1. USERS
    await db.insert('users', {
      'full_name': 'Admin System',
      'email': 'admin@clinic.com',
      'password_hash': '123456',
      'role': 'Admin',
    });

    await db.insert('users', {
      'full_name': 'Khai Huy',
      'email': 'khaihuy@student.com',
      'password_hash': '123456',
      'role': 'Patient',
      'phone_number': '0912345678',
      'city': 'TP.HCM',
    });

    final doctorNames = [
      'GS.TS.BS Đỗ Tất Cường', 'BS. Lê Mạnh Hùng', 'BS. Phạm Minh Anh', 'BS. Nguyễn Hoàng Nam',
      'BS. Trần Thu Hà', 'BS. Võ Quốc Bảo', 'BS. Đặng Gia Hân', 'BS. Bùi Thành Đạt',
      'BS. Lý Minh Khang', 'BS. Phan Ngọc Mai', 'BS. Hồ Thanh Tùng', 'BS. Đỗ Khánh Linh',
      'BS. Trương Mỹ Nhân', 'BS. Lê Quang Liêm', 'BS. Nguyễn Thị Kim', 'BS. Hoàng Văn Thái',
      'BS. Vũ Đức Đam', 'BS. Trần Ngọc Ân', 'BS. Nguyễn Huy Thắng', 'BS. Đào Thế Duy'
    ];

    final doctorUserIds = <int>[];
    for (int i = 0; i < doctorNames.length; i++) {
      final id = await db.insert('users', {
        'full_name': doctorNames[i],
        'email': 'doctor${i + 1}@clinic.com',
        'password_hash': '123456',
        'role': 'Doctor',
        'phone_number': '0901000${(i + 1).toString().padLeft(3, '0')}',
      });
      doctorUserIds.add(id);
    }

    // 2. HỒ SƠ BỆNH NHÂN
    await db.insert('patient_profiles', {
      'user_id': 2,
      'full_name': 'Khai Huy (Bản thân)',
      'gender': 'Nam',
      'relationship': 'Bản thân',
      'dob': '2002-10-20',
      'phone_number': '0912345678',
      'diagnosis': 'Khám sức khỏe định kỳ',
    });

    await db.insert('patient_profiles', {
      'user_id': 2,
      'full_name': 'Trần Thị Em',
      'gender': 'Nữ',
      'relationship': 'Em gái',
      'dob': '2010-05-12',
      'phone_number': '0988888888',
      'diagnosis': 'Theo dõi tai mũi họng',
    });

    // 3. CHUYÊN KHOA
    final specialties = [
      ['Nội Tổng Quát', 'Khám sàng lọc, tư vấn sức khỏe tổng thể'],
      ['Tim Mạch', 'Khám và điều trị bệnh lý tim mạch'],
      ['Nhi Khoa', 'Chăm sóc sức khỏe trẻ em'],
      ['Da Liễu', 'Khám và điều trị các bệnh da'],
      ['Tai Mũi Họng', 'Khám tai mũi họng'],
      ['Thần Kinh', 'Khám và điều trị bệnh thần kinh'],
      ['Xương Khớp', 'Khám cơ xương khớp'],
      ['Tiêu Hóa', 'Khám tiêu hóa và gan mật'],
    ];

    for (var s in specialties) {
      await db.insert('specialties', {'name': s[0], 'description': s[1]});
    }

    // 4. PHÒNG KHÁM
    final clinics = [
      ['Phòng khám Đa khoa Quốc tế', '456 Võ Văn Kiệt, Quận 1', '08:00 - 20:00', '02838220001'],
      ['Bệnh viện Vinmec Smart City', 'Hà Nội', '24/7', '02439743556'],
      ['Bệnh viện Đại học Y Dược', '215 Hồng Bàng, Quận 5', '07:00 - 17:00', '02838554269'],
      ['Bệnh viện Chợ Rẫy', '201B Nguyễn Chí Thanh, Quận 5', '24/7', '02838554137'],
    ];

    for (var c in clinics) {
      await db.insert('clinics', {
        'name': c[0],
        'address': c[1],
        'operating_hours': c[2],
        'phone_number': c[3],
      });
    }

    // 5. BÁC SĨ (Mỗi chuyên khoa 2-3 bác sĩ)
    final doctorsData = [
      // Nội Tổng Quát (ID: 1)
      {'user': 0, 'spec': 1, 'clinic': 1, 'price': 500000, 'exp': 20, 'rating': 5.0, 'pos': 'Chủ tịch Hội đồng cố vấn'},
      {'user': 8, 'spec': 1, 'clinic': 2, 'price': 300000, 'exp': 10, 'rating': 4.7, 'pos': 'Bác sĩ Nội khoa'},
      {'user': 16, 'spec': 1, 'clinic': 3, 'price': 400000, 'exp': 15, 'rating': 4.8, 'pos': 'Bác sĩ Cao cấp'},

      // Tim Mạch (ID: 2)
      {'user': 1, 'spec': 2, 'clinic': 3, 'price': 700000, 'exp': 25, 'rating': 4.9, 'pos': 'Bác sĩ Tim mạch'},
      {'user': 9, 'spec': 2, 'clinic': 4, 'price': 600000, 'exp': 18, 'rating': 4.8, 'pos': 'Bác sĩ Tim mạch'},
      {'user': 17, 'spec': 2, 'clinic': 1, 'price': 550000, 'exp': 12, 'rating': 4.6, 'pos': 'Bác sĩ Tim mạch'},

      // Nhi Khoa (ID: 3)
      {'user': 2, 'spec': 3, 'clinic': 2, 'price': 450000, 'exp': 15, 'rating': 4.8, 'pos': 'Bác sĩ Nhi khoa'},
      {'user': 10, 'spec': 3, 'clinic': 3, 'price': 350000, 'exp': 8, 'rating': 4.7, 'pos': 'Bác sĩ Nhi khoa'},

      // Da Liễu (ID: 4)
      {'user': 3, 'spec': 4, 'clinic': 1, 'price': 400000, 'exp': 12, 'rating': 4.7, 'pos': 'Bác sĩ Da liễu'},
      {'user': 11, 'spec': 4, 'clinic': 4, 'price': 500000, 'exp': 14, 'rating': 4.9, 'pos': 'Bác sĩ Da liễu'},
      {'user': 18, 'spec': 4, 'clinic': 2, 'price': 420000, 'exp': 9, 'rating': 4.5, 'pos': 'Bác sĩ Da liễu'},

      // Tai Mũi Họng (ID: 5)
      {'user': 4, 'spec': 5, 'clinic': 1, 'price': 350000, 'exp': 10, 'rating': 4.8, 'pos': 'Bác sĩ Tai Mũi Họng'},
      {'user': 12, 'spec': 5, 'clinic': 3, 'price': 380000, 'exp': 11, 'rating': 4.6, 'pos': 'Bác sĩ Tai Mũi Họng'},

      // Thần Kinh (ID: 6)
      {'user': 5, 'spec': 6, 'clinic': 4, 'price': 600000, 'exp': 20, 'rating': 4.9, 'pos': 'Bác sĩ Thần kinh'},
      {'user': 13, 'spec': 6, 'clinic': 2, 'price': 550000, 'exp': 16, 'rating': 4.7, 'pos': 'Bác sĩ Thần kinh'},

      // Xương Khớp (ID: 7)
      {'user': 6, 'spec': 7, 'clinic': 3, 'price': 480000, 'exp': 13, 'rating': 4.8, 'pos': 'Bác sĩ Xương khớp'},
      {'user': 14, 'spec': 7, 'clinic': 1, 'price': 450000, 'exp': 10, 'rating': 4.7, 'pos': 'Bác sĩ Xương khớp'},

      // Tiêu Hóa (ID: 8)
      {'user': 7, 'spec': 8, 'clinic': 4, 'price': 420000, 'exp': 14, 'rating': 4.8, 'pos': 'Bác sĩ Tiêu hóa'},
      {'user': 15, 'spec': 8, 'clinic': 2, 'price': 400000, 'exp': 12, 'rating': 4.6, 'pos': 'Bác sĩ Tiêu hóa'},
      {'user': 19, 'spec': 8, 'clinic': 3, 'price': 430000, 'exp': 11, 'rating': 4.7, 'pos': 'Bác sĩ Tiêu hóa'},
    ];

    for (var d in doctorsData) {
      await db.insert('doctors', {
        'user_id': doctorUserIds[d['user'] as int],
        'specialty_id': d['spec'],
        'clinic_id': d['clinic'],
        'price': d['price'],
        'experience_years': d['exp'],
        'rating': d['rating'],
        'bio': 'Bác sĩ chuyên khoa giàu kinh nghiệm, tận tâm với bệnh nhân.',
        'position': d['pos'],
        'workplace': clinics[(d['clinic'] as int) - 1][0],
        'avatar': 'assets/images/doctors/doctor_${(d['user'] as int) % 12 + 1}.png',
        'education': 'Tốt nghiệp Đại học Y Dược.',
        'services': 'Khám và tư vấn chuyên khoa.',
      });
    }

    // 6. LỊCH KHÁM MẪU (Cho 5 bác sĩ đầu tiên)
    for (int i = 1; i <= 5; i++) {
      final scheduleId = await db.insert('schedules', {
        'doctor_id': i,
        'available_date': '2026-03-20',
        'start_time': '08:00',
        'end_time': '12:00',
      });

      for (int j = 8; j < 11; j++) {
        await db.insert('time_slots', {
          'schedule_id': scheduleId,
          'start_time': '${j.toString().padLeft(2, '0')}:00',
          'end_time': '${j.toString().padLeft(2, '0')}:30',
          'is_booked': 0,
        });
      }
    }

    print("--- DỮ LIỆU MẪU ĐÃ ĐƯỢC TẠO ---");
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final database = await db;
    return await database.rawQuery('''
      SELECT 
        d.doctor_id,
        u.full_name,
        u.email,
        u.phone_number,
        s.name AS specialty_name,
        c.name AS clinic_name,
        c.address AS clinic_address,
        c.phone_number AS clinic_phone,
        d.bio,
        d.position,
        d.workplace,
        d.services,
        d.education,
        d.work_experience_detail,
        d.organizations,
        d.research_works,
        d.avatar,
        d.experience_years,
        d.rating,
        d.price
      FROM doctors d
      JOIN users u ON d.user_id = u.user_id
      JOIN specialties s ON d.specialty_id = s.specialty_id
      JOIN clinics c ON d.clinic_id = c.clinic_id
      ORDER BY d.rating DESC, d.experience_years DESC
    ''');
  }

  Future<Map<String, dynamic>?> getDoctorById(int doctorId) async {
    final database = await db;
    final result = await database.rawQuery('''
      SELECT 
        d.doctor_id,
        u.full_name,
        u.email,
        u.phone_number,
        s.name AS specialty_name,
        c.name AS clinic_name,
        c.address AS clinic_address,
        c.phone_number AS clinic_phone,
        d.bio,
        d.position,
        d.workplace,
        d.services,
        d.education,
        d.work_experience_detail,
        d.organizations,
        d.research_works,
        d.avatar,
        d.experience_years,
        d.rating,
        d.price
      FROM doctors d
      JOIN users u ON d.user_id = u.user_id
      JOIN specialties s ON d.specialty_id = s.specialty_id
      JOIN clinics c ON d.clinic_id = c.clinic_id
      WHERE d.doctor_id = ?
      LIMIT 1
    ''', [doctorId]);

    if (result.isEmpty) return null;
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getDoctorsBySpecialty(int specialtyId) async {
    final database = await db;
    return await database.rawQuery('''
      SELECT 
        d.doctor_id,
        u.full_name,
        s.name AS specialty_name,
        c.name AS clinic_name,
        d.bio,
        d.position,
        d.avatar,
        d.experience_years,
        d.rating,
        d.price
      FROM doctors d
      JOIN users u ON d.user_id = u.user_id
      JOIN specialties s ON d.specialty_id = s.specialty_id
      JOIN clinics c ON d.clinic_id = c.clinic_id
      WHERE d.specialty_id = ?
      ORDER BY d.rating DESC, d.experience_years DESC
    ''', [specialtyId]);
  }

  Future<List<Map<String, dynamic>>> getDoctorsBySpecialtyAndClinic(int specialtyId, int clinicId) async {
    final database = await db;
    return await database.rawQuery('''
      SELECT 
        d.doctor_id,
        u.full_name,
        s.name AS specialty_name,
        c.name AS clinic_name,
        d.bio,
        d.position,
        d.avatar,
        d.experience_years,
        d.rating,
        d.price
      FROM doctors d
      JOIN users u ON d.user_id = u.user_id
      JOIN specialties s ON d.specialty_id = s.specialty_id
      JOIN clinics c ON d.clinic_id = c.clinic_id
      WHERE d.specialty_id = ? AND d.clinic_id = ?
      ORDER BY d.rating DESC, d.experience_years DESC
    ''', [specialtyId, clinicId]);
  }

  Future<List<Map<String, dynamic>>> getAllDoctorsWithDetails() async {
    return getAllDoctors();
  }
}
