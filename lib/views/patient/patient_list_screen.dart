import 'package:flutter/material.dart';
import '../../implementations/models/patient_profile.dart';
import '../../implementations/repository/patient_repository.dart';
import 'patient_info_screen.dart';

class PatientListScreen extends StatefulWidget {
  final int userId;
  const PatientListScreen({super.key, required this.userId});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final PatientRepository _repository = PatientRepository();
  List<PatientProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    // Đối với Admin, có thể lấy toàn bộ hồ sơ hoặc hồ sơ của hệ thống
    final profiles = await _repository.getProfilesByUser(widget.userId);
    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý hồ sơ bệnh nhân'),
        backgroundColor: const Color(0xFF0066B3),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProfile = PatientProfile(
            userId: widget.userId,
            fullName: '',
            relationship: 'Hệ thống',
            dob: '',
            diagnosis: '',
          );
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientInfoScreen(
                profile: newProfile, 
                isEditMode: true,
                isAdminView: true,
              ),
            ),
          );
          _loadProfiles();
        },
        backgroundColor: const Color(0xFF0066B3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? const Center(child: Text('Chưa có hồ sơ bệnh nhân nào.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _profiles.length,
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0066B3).withOpacity(0.1),
                          child: const Icon(Icons.person, color: Color(0xFF0066B3)),
                        ),
                        title: Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Chẩn đoán: ${profile.diagnosis ?? "Chưa có"}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientInfoScreen(
                                profile: profile,
                                isEditMode: true, // Cho phép Admin sửa ngay
                                isAdminView: true,
                              ),
                            ),
                          );
                          _loadProfiles();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
