import 'package:flutter/material.dart';
import 'package:projectnhom/views/select_doctor/select_doctor_screen.dart';

class SelectSpecialtyScreen extends StatefulWidget {
  const SelectSpecialtyScreen({super.key});

  @override
  State<SelectSpecialtyScreen> createState() => _SelectSpecialtyScreenState();
}

class _SelectSpecialtyScreenState extends State<SelectSpecialtyScreen> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> specialties = [
    {
      'name': 'Tim Mạch',
      'desc': 'Chuyên về sức khỏe tim mạch và huyết áp',
      'doctors': 8,
      'icon': Icons.favorite_border,
    },
    {
      'name': 'Thần Kinh',
      'desc': 'Điều trị các vấn đề về não và hệ thần kinh',
      'doctors': 6,
      'icon': Icons.psychology_outlined,
    },
    {
      'name': 'Chấn Thương Chỉnh Hình',
      'desc': 'Chăm sóc xương, khớp và cơ',
      'doctors': 10,
      'icon': Icons.favorite_border,
    },  {
      'name': 'Nội Tổng Quát',
      'desc': 'Khám sàng lọc và tư vấn tổng quát',
      'doctors': 12,
      'icon': Icons.favorite_border,
    },
  ];

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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ===================== Widgets =====================

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: const [
          Icon(Icons.local_hospital, color: Colors.blue),
          SizedBox(width: 8),
          Text('ClinicCare', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
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

  Widget _buildSpecialtyList() {
    return ListView.builder(
      itemCount: specialties.length,
      itemBuilder: (context, index) {
        final item = specialties[index];
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() => selectedIndex = index);
          },
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
                  child: Icon(item['icon'], color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['desc'],
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['doctors']} bác sĩ sẵn sàng',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio(
                  value: index,
                  groupValue: selectedIndex,
                  onChanged: (v) {
                    setState(() => selectedIndex = index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectDoctorScreen(),
                ),
              ); // Thêm dấu ); ở đây
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tiếp Tục'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: Colors.blue,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Trang Chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Đặt Lịch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Hồ Sơ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Cài Đặt',
        ),
      ],
    );
  }
}
