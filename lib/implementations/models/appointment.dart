class Appointment {
  final int? id;
  final int patientId; // ID User chủ app
  final int doctorId;
  final int slotId;
  final int profileId; // ID Hồ sơ người đi khám
  final String reason;
  final String status; // 'Pending', 'Confirmed', 'Cancelled', 'Completed'
  final String? createdAt;

  Appointment({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.slotId,
    required this.profileId,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'patient_id': patientId,
    'doctor_id': doctorId,
    'slot_id': slotId,
    'profile_id': profileId,
    'reason': reason,
    'status': status,
  };
}
