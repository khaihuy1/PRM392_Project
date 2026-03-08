import 'package:flutter/material.dart';
import 'package:projectnhom/views/select_doctor/select_date_time_screen.dart';

class SelectDoctorScreen extends StatefulWidget {
  const SelectDoctorScreen({super.key});

  @override
  State<SelectDoctorScreen> createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  int selectedIndex = -1;

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'BS. Sarah Johnson',
      'specialty': 'Tim Mạch',
      'experience': '15 năm',
      'rating': 4.9,
      'reviews': 234,
      'available': 'Hôm nay',
      'avatar': 'https://i.pravatar.cc/150?img=47',
    },
    {
      'name': 'BS. Michael Chen',
      'specialty': 'Tim Mạch',
      'experience': '12 năm',
      'rating': 4.8,
      'reviews': 189,
      'available': 'Ngày mai',
      'avatar': 'https://i.pravatar.cc/150?img=12',
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
                    'Chọn Bác Sĩ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lựa chọn bác sĩ phù hợp với bạn',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildDoctorList()),
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

  // ================= Widgets =================

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
          Text('Bước 2 / 5'),
          SizedBox(height: 6),
          LinearProgressIndicator(
            value: 0.4,
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
        final isDone = index < 1;
        final isActive = index == 1;

        return Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isActive || isDone
                  ? Colors.blue
                  : Colors.grey.shade300,
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
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

  Widget _buildDoctorList() {
    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () => setState(() => selectedIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(doctor['avatar']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor['specialty'],
                            style: const TextStyle(color: Colors.blue),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              doctor['available'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio(
                      value: index,
                      groupValue: selectedIndex,
                      onChanged: (_) => setState(() => selectedIndex = index),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.work_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(doctor['experience']),
                    const Spacer(),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${doctor['rating']} (${doctor['reviews']})'),
                  ],
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
                  builder: (context) => const SelectDateTimeScreen(),
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
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Quay Lại'),
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
