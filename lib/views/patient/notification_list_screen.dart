import 'package:flutter/material.dart';

class NotificationListScreen extends StatelessWidget {
  final String userRole;
  final bool isNested;

  const NotificationListScreen({
    super.key, 
    required this.userRole,
    this.isNested = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = userRole == 'Admin' || userRole == 'Doctor';

    // Mock data
    final List<Map<String, String>> allNotifications = [
      {
        'title': 'Lịch hẹn sắp tới',
        'content': 'Bạn có lịch hẹn khám với Bác sĩ Lê Mạnh Hùng vào lúc 08:30 ngày mai.',
        'time': '10 phút trước',
        'type': 'reminder',
        'for': 'Patient'
      },
      {
        'title': 'Bệnh nhân mới',
        'content': 'Bệnh nhân Khai Huy đã đặt lịch khám vào lúc 09:00 ngày 25/03.',
        'time': '30 phút trước',
        'type': 'reminder',
        'for': 'Admin'
      },
      {
        'title': 'Đặt lịch thành công',
        'content': 'Lịch hẹn cho bệnh nhân Trần Thị Em đã được xác nhận.',
        'time': '2 giờ trước',
        'type': 'success',
        'for': 'Patient'
      },
      {
        'title': 'Cập nhật hệ thống',
        'content': 'Hệ thống quản lý bệnh nhân đã được cập nhật phiên bản mới.',
        'time': '5 giờ trước',
        'type': 'promo',
        'for': 'Admin'
      },
    ];

    final filteredNotifications = allNotifications.where((n) {
      return isAdmin ? n['for'] == 'Admin' : n['for'] == 'Patient';
    }).toList();

    Widget content = filteredNotifications.isEmpty
        ? const Center(child: Text('Không có thông báo nào.'))
        : ListView.builder(
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final item = filteredNotifications[index];
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getIconColor(item['type']).withOpacity(0.1),
                      child: Icon(_getIcon(item['type']), color: _getIconColor(item['type'])),
                    ),
                    title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item['content']!),
                        const SizedBox(height: 4),
                        Text(item['time']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            },
          );
    if (isNested) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: const Color(0xFF0066B3),
        foregroundColor: Colors.white,
      ),
      body: content,
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'reminder': return Icons.notifications_active;
      case 'success': return Icons.check_circle;
      case 'promo': return Icons.local_offer;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'reminder': return Colors.orange;
      case 'success': return Colors.green;
      case 'promo': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
