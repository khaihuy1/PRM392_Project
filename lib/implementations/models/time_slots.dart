class TimeSlot {
  final int? id;
  final int scheduleId;
  final String startTime;
  final String endTime;
  final bool isBooked;

  TimeSlot({
    this.id,
    required this.scheduleId,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) => TimeSlot(
    id: map['slot_id'],
    scheduleId: map['schedule_id'],
    startTime: map['start_time'],
    endTime: map['end_time'],
    isBooked: map['is_booked'] == 1, // Chuyển từ int (0/1) sang bool
  );
}