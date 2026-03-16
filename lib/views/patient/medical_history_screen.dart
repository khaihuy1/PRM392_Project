import 'package:flutter/material.dart';
import '../../implementations/repository/appointment_repository.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final int userId;
  const MedicalHistoryScreen({super.key, required this.userId});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final AppointmentRepository _appointmentRepo = AppointmentRepository();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final appointments = await _appointmentRepo.getAllAppointments(widget.userId);
    setState(() {
      _history = appointments.where((a) => a['status'] == 'Completed').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử khám bệnh'),
        backgroundColor: const Color(0xFF0066B3),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('Chưa có lịch sử khám bệnh nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE3F2FD),
                          child: Icon(Icons.history, color: Color(0xFF0066B3)),
                        ),
                        title: Text(item['doctor_name'] ?? 'Bác sĩ', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Bệnh nhân: ${item['patient_name']}'),
                            Text('Ngày: ${item['available_date']} | ${item['start_time']}'),
                            Text('Phòng khám: ${item['clinic_name']}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
