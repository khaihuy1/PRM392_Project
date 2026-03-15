class Schedule {
  final int? id;
  final int doctorId;
  final String availableDate; // Định dạng yyyy-MM-dd
  final String startTime;
  final String endTime;

  Schedule({
    this.id,
    required this.doctorId,
    required this.availableDate,
    required this.startTime,
    required this.endTime,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
    id: map['schedule_id'],
    doctorId: map['doctor_id'],
    availableDate: map['available_date'],
    startTime: map['start_time'],
    endTime: map['end_time'],
  );
}