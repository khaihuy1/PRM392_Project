import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/schedule.dart';
import 'package:projectnhom/implementations/models/time_slots.dart';
import 'package:projectnhom/implementations/repository/scheule_repository.dart';
import 'package:projectnhom/views/booking_schedule/select_patient_screen.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final int doctorId;

  const SelectDateTimeScreen({super.key, required this.doctorId});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  final ScheduleRepository _scheduleRepo = ScheduleRepository();

  Schedule? selectedSchedule;
  TimeSlot? selectedSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgress(),
          const SizedBox(height: 12),
          _buildStepIndicator(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn Thời Gian Khám',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // 1. PHẦN CHỌN NGÀY
                  const Text(
                    'Chọn ngày khám',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDateList(),

                  const SizedBox(height: 24),

                  // 2. PHẦN CHỌN GIỜ
                  const Text(
                    'Chọn khung giờ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTimeGrid(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  // ===================== LOGIC CALL DATABASE =====================

  // Widget hiển thị danh sách ngày khám (Ngang)
  Widget _buildDateList() {
    return FutureBuilder<List<Schedule>>(
      future: _scheduleRepo.getSchedulesByDoctor(widget.doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Text('Bác sĩ hiện chưa có lịch khám.');

        final schedules = snapshot.data!;
        return SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final item = schedules[index];
              final isSelected = selectedSchedule?.id == item.id;

              return GestureDetector(
                onTap: () => setState(() {
                  selectedSchedule = item;
                  selectedSlot = null; // Reset giờ khi đổi ngày
                }),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.availableDate.split('-').last, // Chỉ lấy ngày
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Tháng ${item.availableDate.split('-')[1]}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTimeGrid() {
    if (selectedSchedule == null) {
      return const Center(child: Text('Vui lòng chọn ngày trước'));
    }

    return FutureBuilder<List<TimeSlot>>(
      future: _scheduleRepo.getAvailableSlots(selectedSchedule!.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Text('Ngày này đã hết chỗ.');

        final slots = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final item = slots[index];
            final isSelected = selectedSlot?.id == item.id;

            return GestureDetector(
              onTap: () => setState(() => selectedSlot = item),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  item.startTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===================== UI WIDGETS =====================

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Chọn Thời Gian',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildProgress() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bước 4 / 5'),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: 0.8,
            backgroundColor: Color(0xFFE0E0E0),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isCompleted = index < 3;
        final isActive = index == 3;
        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isActive || isCompleted
                  ? Colors.blue
                  : Colors.grey.shade300,
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
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
                color: index < 3 ? Colors.blue : Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (selectedSchedule == null || selectedSlot == null)
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectPatientScreen(
                      doctorId: widget.doctorId,
                      slotId: selectedSlot!.id!,
                    ),
                  ),
                );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tiếp Tục',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay Lại', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
