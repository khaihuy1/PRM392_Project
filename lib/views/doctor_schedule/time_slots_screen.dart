import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectnhom/implementations/models/schedule.dart';
import 'package:projectnhom/implementations/models/time_slots.dart';
import 'package:projectnhom/implementations/repository/scheule_repository.dart';

class TimeSlotsScreen extends StatefulWidget {
  final Schedule schedule;
  const TimeSlotsScreen({super.key, required this.schedule});

  @override
  State<TimeSlotsScreen> createState() => _TimeSlotsScreenState();
}

class _TimeSlotsScreenState extends State<TimeSlotsScreen> {
  final _scheduleRepo = ScheduleRepository();
  List<TimeSlot> _slots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    _slots = await _scheduleRepo.getTimeSlots(widget.schedule.id!);
    setState(() => _isLoading = false);
  }

  Future<void> _toggleBookingStatus(TimeSlot slot) async {
    final updatedSlot = slot.copyWith(isBooked: !slot.isBooked);
    await _scheduleRepo.updateTimeSlot(updatedSlot);
    _loadSlots();
  }

  Future<void> _deleteSlot(int slotId) async {
    await _scheduleRepo.deleteTimeSlot(slotId);
    _loadSlots();
  }

  Future<void> _addNewSlot() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final newSlot = TimeSlot(
        scheduleId: widget.schedule.id!,
        startTime: picked.format(context).replaceAll(RegExp(r'\s?[AP]M'), ''), // HH:mm format
        endTime: '',
        isBooked: false,
      );
      await _scheduleRepo.addTimeSlot(newSlot);
      _loadSlots();
    }
  }

  void _showSlotOptions(TimeSlot slot) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(slot.isBooked ? Icons.event_available : Icons.event_busy),
                title: Text(slot.isBooked ? 'Đánh dấu là Trống' : 'Đánh dấu là Đã đặt'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleBookingStatus(slot);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa khung giờ', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteSlot(slot.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteSlot(int slotId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa khung giờ này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSlot(slotId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.schedule.availableDate);
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd/MM/yyyy').format(date)),
        backgroundColor: const Color(0xFF0066B3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm),
            onPressed: _addNewSlot,
            tooltip: 'Thêm khung giờ lẻ',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFF0F7FF),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF0066B3)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Danh sách khung giờ khám cho ngày ${DateFormat('dd/MM/yyyy').format(date)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _slots.length,
                    itemBuilder: (context, index) {
                      final slot = _slots[index];
                      return InkWell(
                        onTap: () => _showSlotOptions(slot),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: slot.isBooked ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: slot.isBooked ? Colors.red.shade300 : Colors.green.shade300,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slot.startTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: slot.isBooked ? Colors.red.shade900 : Colors.green.shade900,
                                ),
                              ),
                              Text(
                                slot.isBooked ? 'Đã đặt' : 'Trống',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: slot.isBooked ? Colors.red.shade700 : Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
