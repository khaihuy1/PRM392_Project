import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/doctor.dart';
import 'package:projectnhom/implementations/repository/doctor_repository.dart';
import 'package:projectnhom/views/booking_schedule/select_date_time_screen.dart';

class SelectDoctorScreen extends StatefulWidget {
  final int specialtyId;
  final int clinicId;

  const SelectDoctorScreen({
    super.key,
    required this.specialtyId,
    required this.clinicId,
  });

  @override
  State<SelectDoctorScreen> createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  final DoctorRepository _doctorRepo = DoctorRepository();
  final TextEditingController _searchController = TextEditingController();

  Doctor? selectedDoctor;
  String _searchQuery = '';
  late Future<List<Doctor>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _doctorRepo.getDoctorsBySpecialtyAndClinic(
      widget.specialtyId,
      widget.clinicId,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _doctorPrimaryKey(Doctor doctor) {
    return doctor.doctorId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đặt Lịch Khám',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn Bác Sĩ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Đội ngũ bác sĩ chuyên khoa giàu kinh nghiệm',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildDoctorList()),
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Tìm tên bác sĩ...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDoctorList() {
    return FutureBuilder<List<Doctor>>(
      future: _doctorsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final allDoctors = snapshot.data ?? [];
        final filteredDoctors = allDoctors.where((doc) {
          return doc.fullName.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredDoctors.isEmpty) {
          return const Center(
            child: Text('Không tìm thấy bác sĩ nào phù hợp.'),
          );
        }

        return ListView.builder(
          itemCount: filteredDoctors.length,
          itemBuilder: (context, index) {
            final doctor = filteredDoctors[index];
            final isSelected = selectedDoctor != null &&
                _doctorPrimaryKey(selectedDoctor!) == _doctorPrimaryKey(doctor);

            return GestureDetector(
              onTap: () => setState(() => selectedDoctor = doctor),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? Colors.blue.withOpacity(0.05)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${doctor.experienceYears} năm kinh nghiệm',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Radio<int>(
                      value: _doctorPrimaryKey(doctor),
                      groupValue: selectedDoctor == null
                          ? null
                          : _doctorPrimaryKey(selectedDoctor!),
                      activeColor: Colors.blue,
                      onChanged: (_) => setState(() => selectedDoctor = doctor),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Bước 3 / 5"), Text("60%")],
          ),
        ),
        LinearProgressIndicator(
          value: 0.6,
          backgroundColor: Colors.grey.shade200,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: selectedDoctor == null
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectDateTimeScreen(
                    doctorId: _doctorPrimaryKey(selectedDoctor!),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tiếp Tục',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Quay Lại', style: TextStyle(color: Colors.blue)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}