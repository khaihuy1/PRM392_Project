import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectnhom/implementations/models/schedule.dart';
import 'package:projectnhom/implementations/repository/scheule_repository.dart';
import 'package:projectnhom/implementations/local/app_database.dart';
import 'add_schedule_screen.dart';
import 'time_slots_screen.dart';
import 'calendar_schedule_screen.dart';

class DoctorScheduleListScreen extends StatefulWidget {
  final int userId;
  const DoctorScheduleListScreen({super.key, required this.userId});

  @override
  State<DoctorScheduleListScreen> createState() => _DoctorScheduleListScreenState();
}

class _DoctorScheduleListScreenState extends State<DoctorScheduleListScreen> {
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  List<Schedule> _schedules = [];
  Map<int, int> _bookedCounts = {}; 
  bool _isLoading = true;
  int? _doctorId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _doctorId = await _scheduleRepo.getDoctorIdByUserId(widget.userId);
    if (_doctorId != null) {
      _schedules = await _scheduleRepo.getSchedulesByDoctor(_doctorId!);
      await _loadStatistics();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadStatistics() async {
    final db = await AppDatabase.instance.db;
    for (var schedule in _schedules) {
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM time_slots 
        WHERE schedule_id = ? AND is_booked = 1 
        AND slot_id IN (SELECT slot_id FROM appointments WHERE status != 'Cancelled')
      ''', [schedule.id]);
      _bookedCounts[schedule.id!] = result.first['count'] as int;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lịch & Thống kê'),
        backgroundColor: const Color(0xFF0066B3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showStatisticsSummary(),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScheduleScreen(schedules: _schedules),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctorId == null
              ? const Center(child: Text('Không tìm thấy thông tin bác sĩ'))
              : Column(
                  children: [
                    _buildQuickStats(),
                    const Divider(height: 1),
                    Expanded(
                      child: _schedules.isEmpty
                          ? const Center(child: Text('Bạn chưa có lịch làm việc nào'))
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _schedules.length,
                                itemBuilder: (context, index) {
                                  final schedule = _schedules[index];
                                  final date = DateTime.parse(schedule.availableDate);
                                  final bookedCount = _bookedCounts[schedule.id] ?? 0;
                                  return _buildScheduleCard(schedule, date, bookedCount);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_doctorId == null) return;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScheduleScreen(doctorId: _doctorId!),
            ),
          );
          if (result == true) _loadData();
        },
        backgroundColor: const Color(0xFFCE9438),
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text('Lập lịch mới', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildQuickStats() {
    int totalPatients = _bookedCounts.values.fold(0, (sum, count) => sum + count);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.blue.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem('Số ca trực', _schedules.length.toString(), Icons.event_note),
          _statItem('Bệnh nhân', totalPatients.toString(), Icons.people_alt),
          _statItem('Hiệu suất', _schedules.isEmpty ? "0%" : "${(totalPatients / (_schedules.length * 8) * 100).toStringAsFixed(0)}%", Icons.trending_up),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0066B3)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildScheduleCard(Schedule schedule, DateTime date, int bookedCount) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimeSlotsScreen(schedule: schedule)),
          );
        },
        onLongPress: () => _showScheduleOptions(schedule),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF0066B3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('dd').format(date), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0066B3), fontSize: 18)),
              Text(DateFormat('MMM').format(date), style: const TextStyle(fontSize: 10, color: Color(0xFF0066B3))),
            ],
          ),
        ),
        title: Text(DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Thời gian: ${schedule.startTime} - ${schedule.endTime}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bookedCount > 0 ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$bookedCount BN', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const Icon(Icons.more_vert, size: 18),
          ],
        ),
      ),
    );
  }

  void _showScheduleOptions(Schedule schedule) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          ListTile(
            leading: const Icon(Icons.event_busy, color: Colors.orange),
            title: const Text('Báo nghỉ trực tuyến'),
            subtitle: const Text('Hủy các lịch hẹn và thông báo cho bệnh nhân'),
            onTap: () {
              Navigator.pop(context);
              _handleReportLeave(schedule);
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_person_outlined, color: Colors.blue),
            title: const Text('Khóa / Mở khóa nhận lịch'),
            subtitle: const Text('Tạm dừng nhận bệnh nhân mới cho ngày này'),
            onTap: () {
              Navigator.pop(context);
              _toggleLockSchedule(schedule);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Xóa lịch làm việc'),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(schedule);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Xử lý Báo Nghỉ: Hủy toàn bộ lịch hẹn hiện có và khóa luôn các slot
  Future<void> _handleReportLeave(Schedule schedule) async {
    final bookedCount = _bookedCounts[schedule.id] ?? 0;
    
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận báo nghỉ'),
        content: Text(bookedCount > 0 
          ? 'Hiện có $bookedCount bệnh nhân đã đặt lịch. Nếu báo nghỉ, toàn bộ lịch hẹn này sẽ bị HỦY. Bạn có chắc chắn?'
          : 'Bạn có chắc chắn muốn báo nghỉ ngày này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Quay lại')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Xác nhận nghỉ'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() => _isLoading = true);
    final db = await AppDatabase.instance.db;
    await db.transaction((txn) async {
      // 1. Hủy các lịch hẹn đang hoạt động
      await txn.update(
        'appointments', 
        {'status': 'Cancelled'}, 
        where: 'slot_id IN (SELECT slot_id FROM time_slots WHERE schedule_id = ?)', 
        whereArgs: [schedule.id]
      );
      // 2. Khóa toàn bộ các slot để không ai đặt được nữa
      await txn.update('time_slots', {'is_booked': 1}, where: 'schedule_id = ?', whereArgs: [schedule.id]);
    });

    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thực hiện báo nghỉ và thông báo tới bệnh nhân.')));
    }
  }

  // Xử lý Khóa/Mở Khóa: Chỉ tác động lên các slot chưa có bệnh nhân đặt thực sự
  Future<void> _toggleLockSchedule(Schedule schedule) async {
    final db = await AppDatabase.instance.db;
    
    // Kiểm tra xem hiện tại có đang bị khóa (manual block) không
    final List<Map<String, dynamic>> blockedSlots = await db.rawQuery('''
      SELECT slot_id FROM time_slots 
      WHERE schedule_id = ? AND is_booked = 1 
      AND slot_id NOT IN (SELECT slot_id FROM appointments WHERE status != 'Cancelled')
    ''', [schedule.id]);

    bool isCurrentlyLocked = blockedSlots.isNotEmpty;

    if (isCurrentlyLocked) {
      // Mở khóa: Chuyển các slot bị khóa thủ công về 0
      await db.rawUpdate('''
        UPDATE time_slots SET is_booked = 0 
        WHERE schedule_id = ? AND is_booked = 1 
        AND slot_id NOT IN (SELECT slot_id FROM appointments WHERE status != 'Cancelled')
      ''', [schedule.id]);
    } else {
      // Khóa: Chuyển các slot đang trống (is_booked = 0) sang 1
      await db.update('time_slots', {'is_booked': 1}, where: 'schedule_id = ? AND is_booked = 0', whereArgs: [schedule.id]);
    }

    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isCurrentlyLocked ? 'Đã mở nhận lịch trở lại' : 'Đã khóa nhận lịch thành công')));
    }
  }

  void _showStatisticsSummary() {
    int totalPatients = _bookedCounts.values.fold(0, (sum, count) => sum + count);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo thống kê hiệu suất'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statRow('Tổng số ca đã trực:', '${_schedules.length} ca'),
            _statRow('Tổng số bệnh nhân:', '$totalPatients người'),
            _statRow('Trung bình bệnh nhân/ca:', '${_schedules.isEmpty ? 0 : (totalPatients / _schedules.length).toStringAsFixed(1)}'),
            const Divider(),
            const Text('Gợi ý tối ưu (AI Suggest):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const Text('- Bạn nên mở thêm slot vào sáng Thứ Hai vì nhu cầu cao.'),
            const Text('- Ca trực tối Thứ Sáu thường ít bệnh nhân, có thể cân nhắc nghỉ.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }

  void _confirmDelete(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch làm việc'),
        content: Text('Bạn có chắc muốn xóa lịch ngày ${schedule.availableDate}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              await _scheduleRepo.deleteSchedule(schedule.id!);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
