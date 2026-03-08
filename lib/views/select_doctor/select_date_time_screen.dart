import 'package:flutter/material.dart';
import 'package:projectnhom/views/select_doctor/patient_info_screen.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({super.key});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime focusedMonth = DateTime(2026, 3);
  DateTime? selectedDate;
  String? selectedTime;

  final List<String> timeSlots = [
    '09:00', '09:30', '10:00',
    '10:30', '11:00', '11:30',

  ];

  final List<String> monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  String formatVietnameseDate(DateTime date) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} tháng ${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = selectedDate != null && selectedTime != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 16),

            const Text(
              'Chọn Ngày & Giờ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            const Text(
              'Lựa chọn thời gian phù hợp với bạn',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            _buildCalendar(),

            const SizedBox(height: 16),

            _buildTimeSlots(),

            const SizedBox(height: 24),

            _buildActions(canContinue),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: const [
          Icon(Icons.local_hospital, color: Colors.blue),
          SizedBox(width: 8),
          Text('ClinicCare', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isDone = index < 2;
        final isActive = index == 2;

        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor:
              isDone || isActive ? Colors.blue : Colors.grey.shade300,
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ),
            if (index != 4)
              Container(
                width: 30,
                height: 2,
                color: Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth =
    DateUtils.getDaysInMonth(focusedMonth.year, focusedMonth.month);
    final firstWeekday =
        DateTime(focusedMonth.year, focusedMonth.month, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    focusedMonth = DateTime(
                      focusedMonth.year,
                      focusedMonth.month - 1,
                    );
                  });
                },
              ),
              Text(
                '${monthNames[focusedMonth.month - 1]} ${focusedMonth.year}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    focusedMonth = DateTime(
                      focusedMonth.year,
                      focusedMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + firstWeekday - 1,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox();
              }

              final day = index - firstWeekday + 2;
              final date =
              DateTime(focusedMonth.year, focusedMonth.month, day);

              final isSelected = selectedDate != null &&
                  DateUtils.isSameDay(selectedDate, date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = date;
                    selectedTime = null;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                    isSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color:
                      isSelected ? Colors.white : Colors.black,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: selectedDate == null
          ? const Center(
        child: Text(
          'Vui lòng chọn ngày trước',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khung Giờ Có Sẵn',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            formatVietnameseDate(selectedDate!),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: timeSlots.map((time) {
              final isSelected = selectedTime == time;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedTime = time);
                },
                child: Container(
                  width: 100,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool canContinue) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientInfoScreen(),
                ),
              ); // Thêm dấu ); ở đây
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tiếp Tục'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay Lại'),
          ),
        ),
      ],
    );
  }
}