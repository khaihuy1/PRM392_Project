import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectnhom/implementations/models/schedule.dart';

class CalendarScheduleScreen extends StatelessWidget {
  final List<Schedule> schedules;
  const CalendarScheduleScreen({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    // Group schedules by month for a simple calendar-like view
    Map<String, List<Schedule>> grouped = {};
    for (var s in schedules) {
      final date = DateTime.parse(s.availableDate);
      final month = DateFormat('MMMM yyyy', 'vi_VN').format(date);
      grouped.putIfAbsent(month, () => []).add(s);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch làm việc (Calendar)'),
        backgroundColor: const Color(0xFF0066B3),
        foregroundColor: Colors.white,
      ),
      body: grouped.isEmpty
          ? const Center(child: Text('Không có lịch làm việc'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final month = grouped.keys.elementAt(index);
                final monthSchedules = grouped[month]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        month.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066B3),
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: 31, // Simplified for demo, shows day numbers
                      itemBuilder: (context, dayIdx) {
                        int day = dayIdx + 1;
                        // Check if any schedule matches this day in this month
                        bool hasSchedule = monthSchedules.any((s) {
                          final d = DateTime.parse(s.availableDate);
                          return d.day == day;
                        });

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            color: hasSchedule ? Colors.orange.shade100 : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: hasSchedule ? Colors.orange.shade900 : Colors.black54,
                              fontWeight: hasSchedule ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
    );
  }
}
