import 'package:flutter/material.dart';
import 'package:projectnhom/implementations/models/patient_profile.dart';
import 'package:projectnhom/implementations/repository/patient_repository.dart';

class AddPatientScreen extends StatefulWidget {
  final int userId;
  const AddPatientScreen({super.key, required this.userId});
  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Nam';
  String _selectedRelation = 'Người thân';

  final PatientRepository _patientRepo = PatientRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Hồ Sơ Mới', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Họ và tên', Icons.person, 'Vui lòng nhập tên'),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Số điện thoại', Icons.phone, 'Vui lòng nhập SĐT', keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildDropdown('Quan hệ', ['Bản thân', 'Bố', 'Mẹ', 'Vợ', 'Chồng', 'Con', 'Người thân'], (val) => _selectedRelation = val!),
              const SizedBox(height: 16),
              _buildDropdown('Giới tính', ['Nam', 'Nữ', 'Khác'], (val) => _selectedGender = val!),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String error, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null || value.isEmpty ? error : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.firstWhere((e) => e == (label == 'Giới tính' ? _selectedGender : _selectedRelation)),
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.blue,
        ),
        onPressed: _submitData,
        child: const Text('LƯU HỒ SƠ', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      final newProfile = PatientProfile(
        userId: widget.userId,
        fullName: _nameController.text,
        relationship: _selectedRelation,
        gender: _selectedGender,
        phoneNumber: _phoneController.text,
        dob: _dobController.text,
      );

      await _patientRepo.addProfile(newProfile);
      if (mounted) Navigator.pop(context, true); // Trả về 'true' để báo hiệu cần load lại list
    }
  }
}