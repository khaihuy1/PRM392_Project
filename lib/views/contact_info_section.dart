import 'package:flutter/material.dart';

class ContactInfoSection extends StatelessWidget {
  const ContactInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Nếu màn hình quá hẹp (< 600px), chuyển sang dạng cột (Column)
        bool isMobile = constraints.maxWidth < 600;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          color: Colors.white,
          child: isMobile
              ? Column(children: _buildItems()) // Mobile: Xếp chồng
              : Row( // Tablet/Desktop: Một hàng ngang
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildItems().map((item) => Expanded(child: item)).toList(),
          ),
        );
      },
    );
  }

  List<Widget> _buildItems() {
    return [
      _contactItem(Icons.access_time, "Giờ Làm Việc", "T2 - T6: 8:00 - 20:00"),
      _contactItem(Icons.location_on, "Địa Chỉ", "Quận 1, TP.HCM"),
      _contactItem(Icons.phone, "Liên Hệ", "1-800-CLINIC"),
    ];
  }

  Widget _contactItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE3F2FD),
            child: Icon(icon, color: const Color(0xFF2962FF)),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}