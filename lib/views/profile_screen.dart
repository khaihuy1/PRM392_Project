import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _addressDetailController = TextEditingController();

  String? _selectedEthnicity;
  String? _selectedCity;
  String? _selectedWard;

  final List<String> _ethnicities = ['Kinh', 'Tày', 'Thái', 'Mường', 'Hoa', 'Khmer', 'Nùng', 'Khác'];
  
  final Map<String, List<String>> _addressData = {
    'Thành phố Hà Nội': ['Quận Ba Đình', 'Quận Hoàn Kiếm', 'Quận Tây Hồ', 'Huyện Thạch Thất', 'Huyện Đông Anh'],
    'Thành phố Hồ Chí Minh': ['Quận 1', 'Quận 12', 'Huyện Củ Chi', 'Huyện Hóc Môn'],
    'Thành phố Đà Nẵng': ['Quận Hải Châu', 'Quận Thanh Khê', 'Huyện Hòa Vang'],
    'Thành phố Cần Thơ': ['Quận Ninh Kiều', 'Quận Cái Răng'],
  };

  List<String> get _cities => _addressData.keys.toList();
  List<String> _availableWards = [];

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
          _addressDetailController.text = _userData?['detail_address'] ?? '';
          _selectedEthnicity = _userData?['ethnicity'];
          _selectedCity = _userData?['city'];
          _selectedWard = _userData?['ward'];
          
          if (_selectedCity != null) {
            _availableWards = _addressData[_selectedCity] ?? [];
          }
          
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
          'ethnicity': _selectedEthnicity,
          'city': _selectedCity,
          'ward': _selectedWard,
          'detail_address': _addressDetailController.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image với Logo (Khôi phục lại phần ảnh bị mất)
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://gacbepbamien.com/wp-content/uploads/2021/08/hinh-anh-bac-si-kham-benh-1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        const Color(0xFF0066B3).withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 50, color: Color(0xFF0066B3)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _userData?['full_name'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _userData?['role'] == 'Admin' ? 'Quản trị viên' : 'Bệnh nhân',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                // Nút Chỉnh sửa nhanh
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.white, size: 28),
                    onPressed: () {
                      if (_isEditing) {
                        _updateUserInfo();
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin tài khoản',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0066B3)),
                  ),
                  const SizedBox(height: 15),
                  
                  // Phần Thông tin cá nhân
                  _buildSectionCard([
                    _buildField(Icons.email, 'Địa chỉ Email (Gmail)', TextEditingController(text: _userData?['email']), isEditable: false),
                    const Divider(),
                    _buildField(Icons.person, 'Họ và tên', _nameController, isEditable: _isEditing),
                    const Divider(),
                    _buildField(Icons.phone, 'Số điện thoại', _phoneController, isEditable: _isEditing, keyboardType: TextInputType.phone),
                  ]),

                  const SizedBox(height: 25),
                  const Text(
                    'Địa chỉ & Dân tộc',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0066B3)),
                  ),
                  const SizedBox(height: 15),

                  _buildSectionCard([
                    _buildDropdown('Dân tộc', _ethnicities, _selectedEthnicity, (v) => setState(() => _selectedEthnicity = v), isEditing: _isEditing),
                    const Divider(),
                    _buildDropdown('Tỉnh/Thành phố', _cities, _selectedCity, (v) {
                      setState(() {
                        _selectedCity = v;
                        _selectedWard = null;
                        _availableWards = _addressData[v] ?? [];
                      });
                    }, isEditing: _isEditing),
                    const Divider(),
                    _buildDropdown('Quận/Huyện', _availableWards, _selectedWard, (v) => setState(() => _selectedWard = v), isEditing: _isEditing, enabled: _selectedCity != null),
                    const Divider(),
                    _buildField(Icons.home, 'Địa chỉ chi tiết', _addressDetailController, isEditable: _isEditing),
                  ]),

                  const SizedBox(height: 30),

                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updateUserInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCE9438), // Màu vàng Vinmec
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('LƯU THAY ĐỔI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _isEditing = false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('HỦY'),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
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
                        label: const Text('ĐĂNG XUẤT KHỎI HỆ THỐNG', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(children: children),
    );
  }

  Widget _buildField(IconData icon, String label, TextEditingController controller, {bool isEditable = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0066B3), size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                isEditable
                    ? TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 5)),
                      )
                    : Text(
                        controller.text.isEmpty ? 'Chưa cập nhật' : controller.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isEditable ? Colors.black : Colors.black87,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {bool isEditing = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF0066B3), size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                isEditing
                    ? DropdownButton<String>(
                        value: selectedValue,
                        isExpanded: true,
                        underline: Container(height: 1, color: Colors.grey.shade300),
                        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 15)))).toList(),
                        onChanged: enabled ? onChanged : null,
                      )
                    : Text(selectedValue ?? 'Chưa cập nhật', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
