import 'package:flutter/material.dart';
import '../../implementations/models/doctor.dart';
import 'select_date_time_screen.dart';

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(doctor.fullName, style: const TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh bác sĩ
                  Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.shade50,
                      image: doctor.avatar != null 
                        ? DecorationImage(
                            image: AssetImage(doctor.avatar!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    ),
                    child: doctor.avatar == null 
                      ? const Icon(Icons.person, size: 80, color: Colors.blue)
                      : null,
                  ),
                  const SizedBox(width: 16),
                  // Thông tin chức danh
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.position ?? 'Bác sĩ chuyên khoa',
                          style: const TextStyle(color: Color(0xFF0066B3), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctor.fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0066B3)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SelectDateTimeScreen(doctorId: doctor.doctorId)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5ABFA3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Đăng ký khám', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Các khối thông tin chi tiết (Accordion style)
            _buildInfoSection('Giới thiệu', doctor.bio),
            _buildInfoSection('Chức vụ', doctor.position ?? 'Chưa cập nhật'),
            _buildInfoSection('Chuyên khoa', doctor.specialtyName ?? 'Chưa cập nhật'),
            _buildInfoSection('Nơi làm việc', doctor.workplace ?? 'Hệ thống y tế ClinicCare'),
            _buildInfoSection('Số năm kinh nghiệm', '${doctor.experienceYears} năm'),
            _buildInfoSection('Dịch vụ', doctor.services ?? 'Khám và tư vấn chuyên khoa'),
            _buildInfoSection('Quá trình đào tạo', doctor.education ?? 'Đang cập nhật...'),
            _buildInfoSection('Kinh nghiệm làm việc', doctor.workExperienceDetail ?? 'Đang cập nhật...'),
            _buildInfoSection('Thành viên tổ chức', doctor.organizations ?? 'Hội Y học Việt Nam'),
            _buildInfoSection('Công trình nghiên cứu', doctor.researchWorks ?? 'Đang cập nhật...'),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 1),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0066B3)),
        ),
        backgroundColor: Colors.grey.shade50,
        collapsedBackgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.all(16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}