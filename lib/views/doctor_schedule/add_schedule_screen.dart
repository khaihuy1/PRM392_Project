import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectnhom/implementations/models/schedule.dart';
import 'package:projectnhom/implementations/models/time_slots.dart';
import 'package:projectnhom/implementations/repository/scheule_repository.dart';

class AddScheduleScreen extends StatefulWidget {
  final int doctorId;
  const AddScheduleScreen({super.key, required this.doctorId});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _scheduleRepo = ScheduleRepository();
  
  // Chuyển từ 1 ngày sang danh sách nhiều ngày
  List<DateTime> _selectedDates = [DateTime.now().add(const Duration(days: 1))];
  
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  int _slotDuration = 30; // minutes
  bool _isSaving = false;

  // Hàm chọn nhiều ngày (giả lập chọn thêm ngày vào danh sách)
  Future<void> _addDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'CHỌN NGÀY MUỐN THÊM VÀO LỊCH',
    );
    
    if (picked != null && !_selectedDates.any((d) => _isSameDay(d, picked))) {
      setState(() {
        _selectedDates.add(picked);
        _selectedDates.sort((a, b) => a.compareTo(b));
      });
    }
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Future<void> _selectTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  Future<void> _saveAll() async {
    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất một ngày')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Lặp qua từng ngày đã chọn để tạo lịch
      for (var date in _selectedDates) {
        final schedule = Schedule(
          doctorId: widget.doctorId,
          availableDate: DateFormat('yyyy-MM-dd').format(date),
          startTime: _startTime.format(context),
          endTime: _endTime.format(context),
        );

        List<TimeSlot> slots = [];
        DateTime start = DateTime(date.year, date.month, date.day, _startTime.hour, _startTime.minute);
        DateTime end = DateTime(date.year, date.month, date.day, _endTime.hour, _endTime.minute);

        while (start.isBefore(end)) {
          DateTime next = start.add(Duration(minutes: _slotDuration));
          if (next.isAfter(end)) break;
          
          slots.add(TimeSlot(
            scheduleId: 0,
            startTime: DateFormat('HH:mm').format(start),
            endTime: DateFormat('HH:mm').format(next),
            isBooked: false,
          ));
          start = next;
        }

        await _scheduleRepo.createScheduleWithSlots(schedule, slots);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tạo lịch thành công cho ${_selectedDates.length} ngày'))
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lập lịch làm việc'),
        backgroundColor: const Color(0xFF0066B3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Danh sách các ngày trực', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _addDate,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Thêm ngày'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Hiển thị danh sách các ngày đã chọn dưới dạng Chip
            Wrap(
              spacing: 8,
              children: _selectedDates.map((date) => InputChip(
                label: Text(DateFormat('dd/MM').format(date)),
                onDeleted: _selectedDates.length > 1 ? () {
                  setState(() => _selectedDates.remove(date));
                } : null,
                deleteIconColor: Colors.red,
                backgroundColor: Colors.blue.withOpacity(0.1),
              )).toList(),
            ),
            if (_selectedDates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Chưa có ngày nào được chọn', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const Divider(height: 32),
            const Text('Khung giờ làm việc (Áp dụng cho tất cả các ngày đã chọn)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bắt đầu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_startTime.format(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kết thúc', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(_endTime.format(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Thời gian mỗi ca (phút)', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _slotDuration,
              isExpanded: true,
              items: [15, 30, 45, 60].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value phút / bệnh nhân'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _slotDuration = val!),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE9438),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _selectedDates.length <= 1 
                          ? 'LƯU LỊCH LÀM VIỆC' 
                          : 'LƯU LỊCH CHO ${_selectedDates.length} NGÀY',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Lưu ý: Hệ thống sẽ tự động tạo các khung giờ khám dựa trên khoảng thời gian bạn đã chọn.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
