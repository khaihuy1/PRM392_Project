import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/repository/doctor_repository.dart';
import 'package:projectnhom/views/booking_schedule/doctor_booking_screen.dart';
import 'package:projectnhom/views/booking_schedule/doctor_detail_screen.dart';
import 'package:projectnhom/implementations/models/doctor.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  final DoctorRepository _doctorRepo = DoctorRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;

  String _selectedSpecialty = 'Tất cả';
  String _selectedClinic = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    try {
      final data = await _doctorRepo.getAllDoctors();
      if (!mounted) return;
      setState(() {
        _allDoctors = data;
        _filteredDoctors = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint("Lỗi tải bác sĩ: $e");
    }
  }

  void _runFilter() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredDoctors = _allDoctors.where((doc) {
        final fullName = (doc['full_name'] ?? '').toString().toLowerCase();
        final specialtyName = (doc['specialty_name'] ?? '').toString();
        final clinicName = (doc['clinic_name'] ?? '').toString();

        final matchesName = fullName.contains(query);
        final matchesSpecialty =
            _selectedSpecialty == 'Tất cả' || specialtyName == _selectedSpecialty;
        final matchesClinic =
            _selectedClinic == 'Tất cả' || clinicName == _selectedClinic;

        return matchesName && matchesSpecialty && matchesClinic;
      }).toList();
    });
  }

  List<String> get _specialtyOptions {
    final items = _allDoctors
        .map((e) => (e['specialty_name'] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Tất cả', ...items];
  }

  List<String> get _clinicOptions {
    final items = _allDoctors
        .map((e) => (e['clinic_name'] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Tất cả', ...items];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tìm kiếm Bác sĩ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                return _buildDoctorCard(_filteredDoctors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          "Không tìm thấy bác sĩ phù hợp",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => _runFilter(),
            decoration: InputDecoration(
              hintText: "Tên bác sĩ...",
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterDropdown(
                _specialtyOptions,
                _selectedSpecialty,
                    (val) {
                  setState(() => _selectedSpecialty = val!);
                  _runFilter();
                },
              ),
              const SizedBox(width: 10),
              _buildFilterDropdown(
                _clinicOptions,
                _selectedClinic,
                    (val) {
                  setState(() => _selectedClinic = val!);
                  _runFilter();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
      List<String> items,
      String currentVal,
      ValueChanged<String?> onChanged,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentVal,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
            items: items.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (doctor['full_name'] ?? 'Bác sĩ').toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${doctor['specialty_name'] ?? 'Chưa rõ'} • ${doctor['clinic_name'] ?? 'Chưa rõ'}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    Text(
                      " ${(doctor['rating'] ?? 0).toString()} ",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "(${doctor['experience_years'] ?? 0} năm kinh nghiệm)",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  final doctorId = doctor['doctor_id'] as int?;
                  if (doctorId == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(doctorId: doctorId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text("Đặt lịch", style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: () {
                  final docObj = Doctor.fromMap(doctor);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorDetailScreen(doctor: docObj),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text("Chi tiết",
                    style: TextStyle(fontSize: 12, color: Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
