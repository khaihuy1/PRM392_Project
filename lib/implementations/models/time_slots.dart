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

  TimeSlot copyWith({
    int? id,
    int? scheduleId,
    String? startTime,
    String? endTime,
    bool? isBooked,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) => TimeSlot(
    id: map['slot_id'],
    scheduleId: map['schedule_id'],
    startTime: map['start_time'],
    endTime: map['end_time'],
    isBooked: map['is_booked'] == 1,
  );

  Map<String, dynamic> toMap() {
    return {
      'slot_id': id,
      'schedule_id': scheduleId,
      'start_time': startTime,
      'end_time': endTime,
      'is_booked': isBooked ? 1 : 0,
    };
  }
}
