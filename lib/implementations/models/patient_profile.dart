class PatientProfile {
  final int? id;
  final int userId; // ID của tài khoản đang đăng nhập
  final String fullName;
  final String relationship; // Ví dụ: 'Bản thân', 'Con', 'Bố', 'Mẹ'
  final String dob; // Ngày sinh (Date of Birth)
  final String? phoneNumber;
  final String? gender;

  PatientProfile({
    this.id,
    required this.userId,
    required this.fullName,
    required this.relationship,
    required this.dob,
    this.phoneNumber,
    this.gender,
  });

  factory PatientProfile.fromMap(Map<String, dynamic> map) => PatientProfile(
    id: map['profile_id'],
    userId: map['user_id'],
    fullName: map['full_name'] ?? '',
    relationship: map['relationship'] ?? '',
    dob: map['dob'] ?? '',
    phoneNumber: map['phone_number'],
    gender: map['gender'],
  );

  Map<String, dynamic> toMap() => {
    'profile_id': id,
    'user_id': userId,
    'full_name': fullName,
    'relationship': relationship,
    'dob': dob,
    'phone_number': phoneNumber,
    'gender': gender,
  };
}
