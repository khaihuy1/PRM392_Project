import 'package:flutter/material.dart';
import '../../implementations/models/patient_profile.dart';
import '../../implementations/repository/patient_repository.dart';

class PatientInfoScreen extends StatefulWidget {
  final PatientProfile profile;
  final bool isEditMode;
  final bool isAdminView;

  const PatientInfoScreen({
    super.key,
    required this.profile,
    this.isEditMode = false,
    this.isAdminView = true,
  });

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _diagnosisController;
  String? _selectedGender;
  String? _selectedRelationship;
  bool _isEditing = false;
  final PatientRepository _repository = PatientRepository();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditMode;
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _dobController = TextEditingController(text: widget.profile.dob);
    _diagnosisController = TextEditingController(text: widget.profile.diagnosis);
    _selectedGender = widget.profile.gender;
    _selectedRelationship = widget.profile.relationship;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = PatientProfile(
        id: widget.profile.id,
        userId: widget.profile.userId,
        fullName: _nameController.text,
        relationship: _selectedRelationship ?? widget.profile.relationship,
        dob: _dobController.text,
        phoneNumber: _phoneController.text,
        gender: _selectedGender,
        diagnosis: _diagnosisController.text,
      );

      if (widget.profile.id == null) {
        await _repository.addProfile(updatedProfile);
      } else {
        await _repository.updateProfile(updatedProfile);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Hồ sơ bệnh nhân' : 'Chi tiết hồ sơ'),
        backgroundColor: const Color(0xFF0066B3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('Họ và tên', _nameController, Icons.person, enabled: _isEditing),
              const SizedBox(height: 16),
              _buildDropdown('Giới tính', ['Nam', 'Nữ', 'Khác'], _selectedGender, (val) => setState(() => _selectedGender = val), enabled: _isEditing),
              const SizedBox(height: 16),
              _buildField('Ngày sinh (YYYY-MM-DD)', _dobController, Icons.calendar_today, enabled: _isEditing),
              const SizedBox(height: 16),
              _buildField('Số điện thoại', _phoneController, Icons.phone, enabled: _isEditing, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              // Nếu là Admin thì hiện chẩn đoán bệnh, nếu không thì hiện Quan hệ
              if (widget.isAdminView)
                _buildField('Chẩn đoán bệnh', _diagnosisController, Icons.medical_services, enabled: _isEditing, maxLines: 3)
              else
                _buildDropdown('Quan hệ', ['Bản thân', 'Con', 'Bố', 'Mẹ', 'Vợ', 'Chồng', 'Khác'], _selectedRelationship, (val) => setState(() => _selectedRelationship = val), enabled: _isEditing),
              
              const SizedBox(height: 32),
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066B3)),
                    child: const Text('LƯU HỒ SƠ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool enabled = true, TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0066B3)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập $label' : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged, {bool enabled = true}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.people, color: Color(0xFF0066B3)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
