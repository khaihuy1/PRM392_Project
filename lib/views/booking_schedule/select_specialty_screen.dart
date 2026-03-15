import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/specialty.dart';
import 'package:projectnhom/implementations/repository/specialty_repository.dart';
import 'package:projectnhom/views/booking_schedule/select_clinic_screen.dart';

class SelectSpecialtyScreen extends StatefulWidget {
  const SelectSpecialtyScreen({super.key});

  @override
  State<SelectSpecialtyScreen> createState() => _SelectSpecialtyScreenState();
}

class _SelectSpecialtyScreenState extends State<SelectSpecialtyScreen> {
  final SpecialtyRepository _specialtyRepo = SpecialtyRepository();
  Specialty? selectedSpecialty;

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
                    'Chọn Chuyên Khoa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lựa chọn loại chuyên khoa bạn cần khám',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _buildSearch(),
                  const SizedBox(height: 12),
                  Expanded(child: _buildSpecialtyList()),
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

  Widget _buildSpecialtyList() {
    return FutureBuilder<List<Specialty>>(
      future: _specialtyRepo.fetchAllSpecialties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError)
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu chuyên khoa.'));
        }

        final specialties = snapshot.data!;
        return ListView.builder(
          itemCount: specialties.length,
          itemBuilder: (context, index) {
            final item = specialties[index];
            final isSelected = selectedSpecialty?.id == item.id;

            return GestureDetector(
              onTap: () => setState(() => selectedSpecialty = item),
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
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description ?? 'Mô tả chuyên khoa',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Radio<int>(
                      value: item.id!,
                      groupValue: selectedSpecialty?.id,
                      onChanged: (v) =>
                          setState(() => selectedSpecialty = item),
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

  // ===================== UI WIDGETS CỦA BẠN (DÁN LẠI VÀO ĐÂY) =====================

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.local_hospital, color: Colors.blue),
          SizedBox(width: 8),
          Text('ClinicCare', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bước 1 / 5'),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: 0.2,
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
        final isActive = index == 0;
        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isActive ? Colors.blue : Colors.grey.shade300,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ),
            if (index != 4)
              Container(width: 30, height: 2, color: Colors.grey.shade300),
          ],
        );
      }),
    );
  }

  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Tìm kiếm chuyên khoa...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedSpecialty == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectClinicScreen(
                          specialtyId: selectedSpecialty!.id!,
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

      ],
    );
  }


}
