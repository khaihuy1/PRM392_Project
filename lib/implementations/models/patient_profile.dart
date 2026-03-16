class PatientProfile {
  final int? id;
  final int userId; 
  final String fullName;
  final String relationship; 
  final String dob; 
  final String? phoneNumber;
  final String? gender;
  final String? diagnosis;

  PatientProfile({
    this.id,
    required this.userId,
    required this.fullName,
    required this.relationship,
    required this.dob,
    this.phoneNumber,
    this.gender,
    this.diagnosis,
  });

  factory PatientProfile.fromMap(Map<String, dynamic> map) => PatientProfile(
    id: map['profile_id'],
    userId: map['user_id'],
    fullName: map['full_name'] ?? '',
    relationship: map['relationship'] ?? '',
    dob: map['dob'] ?? '',
    phoneNumber: map['phone_number'],
    gender: map['gender'],
    diagnosis: map['diagnosis'],
  );

  Map<String, dynamic> toMap() => {
    'profile_id': id,
    'user_id': userId,
    'full_name': fullName,
    'relationship': relationship,
    'relationship': relationship,
    'dob': dob,
    'phone_number': phoneNumber,
    'gender': gender,
    'diagnosis': diagnosis,
  };
}
