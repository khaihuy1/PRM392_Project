class Doctor {
  final int? id;
  final String fullName;
  final int specialtyId;
  final int clinicId;
  final String? bio;
  final int experienceYears;
  final double rating;

  Doctor({
    this.id,
    required this.fullName,
    required this.specialtyId,
    required this.clinicId,
    this.bio,
    required this.experienceYears,
    required this.rating,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) => Doctor(
    id: map['doctor_id'],
    fullName: map['full_name'] ?? '',
    specialtyId: map['specialty_id'],
    clinicId: map['clinic_id'],
    bio: map['bio'],
    experienceYears: map['experience_years'] ?? 0,
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
  );
}