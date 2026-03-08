import 'package:flutter/material.dart';

class PatientInfoScreen extends StatelessWidget {
  const PatientInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildHeader(),
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// STEP
            const Text(
              "Bước 4 / 5",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 6),

            LinearProgressIndicator(
              value: 0.8,
              borderRadius: BorderRadius.circular(10),
              minHeight: 6,
            ),

            const SizedBox(height: 16),

            _stepIndicator(),

            const SizedBox(height: 24),

            /// TITLE
            const Text(
              "Thông Tin Bệnh Nhân",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Vui lòng cung cấp thông tin để hoàn tất đặt lịch",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            _textField("Tên *", "Văn A"),
            const SizedBox(height: 12),

            _textField("Họ *", "Nguyễn"),
            const SizedBox(height: 12),

            _textField("Địa Chỉ Email *", "example@email.com"),
            const SizedBox(height: 12),

            _textField("Số Điện Thoại *", "0901234567"),
            const SizedBox(height: 12),

            _textField("Ngày Sinh *", "DD/MM/YYYY"),

            const SizedBox(height: 24),

            /// BUTTON
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6f8fdc),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Xác Nhận Đặt Lịch",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Quay Lại"),
            ),
          ],
        ),
      ),
    );
  }

  /// HEADER
  AppBar _buildHeader() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: const [
          Icon(Icons.monitor_heart, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            "ClinicCare",
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  /// STEP INDICATOR
  Widget _stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _step(true, "Chọn\nChuyên Khoa"),
        _step(true, "Chọn\nBác Sĩ"),
        _step(true, "Chọn\nNgày"),
        _step(false, "Thông\nTin"),
        _step(false, "Xác\nNhận"),
      ],
    );
  }

  Widget _step(bool done, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: done ? Colors.green : Colors.grey.shade300,
          child: done
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
        )
      ],
    );
  }

  /// TEXT FIELD
  Widget _textField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),

        const SizedBox(height: 6),

        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// BOTTOM NAV
  Widget _bottomNav() {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Trang Chủ",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Đặt Lịch",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Hồ Sơ",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: "Cài Đặt",
        ),
      ],
    );
  }
}