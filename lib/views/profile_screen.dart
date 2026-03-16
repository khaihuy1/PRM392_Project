import 'package:flutter/material.dart';
import '../implementations/local/app_database.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final db = await AppDatabase.instance.db;
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [widget.userId],
      );

      if (users.isNotEmpty) {
        setState(() {
          _userData = users.first;
          _nameController.text = _userData?['full_name'] ?? '';
          _phoneController.text = _userData?['phone_number'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi load profile: $e");
    }
  }

  Future<void> _updateUserInfo() async {
    setState(() => _isLoading = true);
    try {
      final db = await AppDatabase.instance.db;
      await db.update(
        'users',
        {
          'full_name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
        },
        where: 'user_id = ?',
        whereArgs: [widget.userId],
      );
      
      await _loadUserInfo();
      setState(() => _isEditing = false);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tài khoản', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0066B3),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _updateUserInfo,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0066B3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Color(0xFF0066B3)),
                  ),
                  const SizedBox(height: 15),
                  if (!_isEditing) ...[
                    Text(
                      _userData?['full_name'] ?? 'N/A',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _userData?['email'] ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      'Vai trò: ${_userData?['role'] ?? 'Patient'}',
                      style: const TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ] else ...[
                    const Text('Đang chỉnh sửa...', style: TextStyle(color: Colors.white70)),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Thông tin chi tiết
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoField(
                        icon: Icons.person,
                        label: 'Họ và tên',
                        controller: _nameController,
                        isEditable: _isEditing,
                      ),
                      const Divider(),
                      _buildInfoField(
                        icon: Icons.phone,
                        label: 'Số điện thoại',
                        controller: _phoneController,
                        isEditable: _isEditing,
                        keyboardType: TextInputType.phone,
                      ),
                      const Divider(),
                      _buildStaticRow(Icons.email, 'Email', _userData?['email'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (_isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateUserInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066B3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('LƯU THAY ĐỔI', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = _userData?['full_name'] ?? '';
                            _phoneController.text = _userData?['phone_number'] ?? '';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('HỦY'),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('ĐĂNG XUẤT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0066B3)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (isEditable)
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 5),
                    ),
                  )
                else
                  Text(controller.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0066B3).withOpacity(0.5)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}
