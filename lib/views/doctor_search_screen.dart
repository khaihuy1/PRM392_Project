import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/repository/doctor_repository.dart';
import 'package:projectnhom/views/booking_schedule/doctor_booking_screen.dart';

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

  // Giá trị lọc hiện tại
  String _selectedSpecialty = 'Tất cả';
  String _selectedClinic = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    final data = await _doctorRepo.getAllDoctorsWithDetails();
    setState(() {
      _allDoctors = data;
      _filteredDoctors = data;
      _isLoading = false;
    });
  }

  void _runFilter() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _allDoctors.where((doc) {
        final matchesName = doc['full_name'].toString().toLowerCase().contains(
          query,
        );
        final matchesSpecialty =
            _selectedSpecialty == 'Tất cả' ||
            doc['specialty_name'] == _selectedSpecialty;
        final matchesClinic =
            _selectedClinic == 'Tất cả' ||
            doc['clinic_name'] == _selectedClinic;
        return matchesName && matchesSpecialty && matchesClinic;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Danh sách Bác sĩ",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                ? const Center(child: Text("Không tìm thấy bác sĩ phù hợp"))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) =>
                        _buildDoctorCard(_filteredDoctors[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Thanh tìm kiếm
          TextField(
            controller: _searchController,
            onChanged: (value) => _runFilter(),
            decoration: InputDecoration(
              hintText: "Nhập tên bác sĩ/chuyên gia...",
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Hàng lọc Dropdown
          Row(
            children: [
              _buildDropdown(
                "Chuyên môn",
                ['Tất cả', 'Nội Tổng Quát', 'Tim Mạch', 'Nhi Khoa'],
                (val) {
                  _selectedSpecialty = val!;
                  _runFilter();
                },
                _selectedSpecialty,
              ),
              const SizedBox(width: 8),
              _buildDropdown(
                "Cơ sở",
                ['Tất cả', 'Phòng khám Đa khoa Quốc tế', 'Bệnh viện Vinmec'],
                (val) {
                  _selectedClinic = val!;
                  _runFilter();
                },
                _selectedClinic,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    ValueChanged<String?> onChanged,
    String currentVal,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentVal,
            isExpanded: true,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột bên trái: Ảnh & Nút
            Column(
              children: [
                Container(
                  width: 90,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/150'),
                      // Thay bằng ảnh thật nếu có
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Điều hướng sang trang BookingScreen và truyền doctor_id
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          doctorId: doctor['doctor_id'], // Lấy ID từ Map dữ liệu bác sĩ
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(90, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Đăng ký",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Cột bên phải: Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['full_name'],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(
                        " ${doctor['rating']} ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "(Kinh nghiệm: ${doctor['experience_years']} năm)",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.medical_services_outlined,
                    doctor['specialty_name'],
                  ),
                  _infoRow(Icons.location_on_outlined, doctor['clinic_name']),
                  const SizedBox(height: 8),
                  Text(
                    "${doctor['price']} VNĐ",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
