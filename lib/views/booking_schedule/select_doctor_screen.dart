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
    required this.clinicId
  });

  @override
  State<SelectDoctorScreen> createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  final DoctorRepository _doctorRepo = DoctorRepository();
  Doctor? selectedDoctor;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn Bác Sĩ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Đội ngũ bác sĩ chuyên khoa giàu kinh nghiệm',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _buildSearch(),
                  const SizedBox(height: 12),
                  // Gọi Database lọc theo cả 2 ID
                  Expanded(child: _buildDoctorList()),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== LOGIC CALL DATABASE =====================

  Widget _buildDoctorList() {
    return FutureBuilder<List<Doctor>>(
      future: _doctorRepo.getDoctorsBySpecialtyAndClinic(
          widget.specialtyId,
          widget.clinicId
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không tìm thấy bác sĩ phù hợp tại cơ sở này.'));
        }

        final doctors = snapshot.data!;
        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final item = doctors[index];
            final isSelected = selectedDoctor?.id == item.id;

            return GestureDetector(
              onTap: () => setState(() => selectedDoctor = item),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person, size: 35, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.fullName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.experienceYears} năm kinh nghiệm',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                item.rating.toString(),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Radio<int>(
                      value: item.id!,
                      groupValue: selectedDoctor?.id,
                      onChanged: (v) => setState(() => selectedDoctor = item),
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

  // ===================== UI WIDGETS =====================

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Đặt Lịch Khám', style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildProgress() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bước 3 / 5'),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: 0.6,
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
        final isCompleted = index < 2;
        final isActive = index == 2;
        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isActive || isCompleted ? Colors.blue : Colors.grey.shade300,
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text('${index + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 12)),
            ),
            if (index != 4) Container(width: 30, height: 2, color: index < 2 ? Colors.blue : Colors.grey.shade300),
          ],
        );
      }),
    );
  }

  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm tên bác sĩ...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedDoctor == null ? null : () {
              // Chuyển sang màn hình chọn ngày giờ
              Navigator.push(context, MaterialPageRoute(builder: (context) => SelectDateTimeScreen(doctorId: selectedDoctor!.id!)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tiếp Tục', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Quay Lại'),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}