class Doctor {
  final int doctorId;
  final int userId;
  final int specialtyId;
  final int clinicId;
  final String fullName;
  final String bio;
  final int experienceYears;
  final double rating;
  final int price;
  final String? position;
  final String? workplace;
  final String? services;
  final String? education;
  final String? workExperienceDetail;
  final String? organizations;
  final String? researchWorks;
  final String? avatar;
  final String? specialtyName;
  final String? clinicName;

  Doctor({
    required this.doctorId,
    required this.userId,
    required this.specialtyId,
    required this.clinicId,
    required this.fullName,
    required this.bio,
    required this.experienceYears,
    required this.rating,
    required this.price,
    this.position,
    this.workplace,
    this.services,
    this.education,
    this.workExperienceDetail,
    this.organizations,
    this.researchWorks,
    this.avatar,
    this.specialtyName,
    this.clinicName,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      doctorId: map['doctor_id'] ?? 0,
      userId: map['user_id'] ?? 0,
      specialtyId: map['specialty_id'] ?? 0,
      clinicId: map['clinic_id'] ?? 0,
      fullName: map['full_name'] ?? '',
      bio: map['bio'] ?? '',
      experienceYears: map['experience_years'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      price: map['price'] ?? 0,
      position: map['position'],
      workplace: map['workplace'],
      services: map['services'],
      education: map['education'],
      workExperienceDetail: map['work_experience_detail'],
      organizations: map['organizations'],
      researchWorks: map['research_works'],
      avatar: map['avatar'],
      specialtyName: map['specialty_name'],
      clinicName: map['clinic_name'],
    );
  }
}