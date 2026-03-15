import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/clinic.dart';
import 'package:projectnhom/implementations/repository/clinic_repository.dart';
import '../booking_schedule/select_doctor_screen.dart'; // Màn hình tiếp theo

class SelectClinicScreen extends StatefulWidget {
  final int specialtyId; // Nhận ID từ màn hình Specialty

  const SelectClinicScreen({super.key, required this.specialtyId});

  @override
  State<SelectClinicScreen> createState() => _SelectClinicScreenState();
}

class _SelectClinicScreenState extends State<SelectClinicScreen> {
  final ClinicRepository _clinicRepo = ClinicRepository();
  Clinic? selectedClinic;

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
                    'Chọn Cơ Sở / Phòng Khám',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Danh sách các cơ sở có chuyên khoa bạn đã chọn',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _buildSearch(),
                  const SizedBox(height: 12),
                  // Gọi Database để lấy danh sách Clinic theo SpecialtyId
                  Expanded(child: _buildClinicList()),
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

  Widget _buildClinicList() {
    return FutureBuilder<List<Clinic>>(
      future: _clinicRepo.getClinicsBySpecialty(widget.specialtyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text('Lỗi: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Hiện không có cơ sở nào hỗ trợ chuyên khoa này.'));
        }

        final clinics = snapshot.data!;
        return ListView.builder(
          itemCount: clinics.length,
          itemBuilder: (context, index) {
            final item = clinics[index];
            final isSelected = selectedClinic?.id == item.id;

            return GestureDetector(
              onTap: () => setState(() => selectedClinic = item),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on_outlined, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.address,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Radio<int>(
                      value: item.id!,
                      groupValue: selectedClinic?.id,
                      onChanged: (v) => setState(() => selectedClinic = item),
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

  // ===================== UI WIDGETS (Header & Footer) =====================

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Chọn Cơ Sở', style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildProgress() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bước 2 / 5'),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: 0.4, // Tăng lên 40%
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
        final isCompleted = index < 1;
        final isActive = index == 1;
        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isActive || isCompleted ? Colors.blue : Colors.grey.shade300,
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text('${index + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontSize: 12)),
            ),
            if (index != 4) Container(width: 30, height: 2, color: index < 1 ? Colors.blue : Colors.grey.shade300),
          ],
        );
      }),
    );
  }

  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm nhanh cơ sở...',
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
            onPressed: selectedClinic == null ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectDoctorScreen(
                    specialtyId: widget.specialtyId,
                    clinicId: selectedClinic!.id!,
                  ),
                ),
              );
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