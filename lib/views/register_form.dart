import 'package:flutter/material.dart';
import 'package:projectnhom/views/login_screen.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông Tin Cá Nhân'),
        Row(
          children: [
            Expanded(
              child: _buildTextField(label: 'Tên *', hint: 'Nguyễn Văn'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(label: 'Họ *', hint: 'A'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSectionTitle('Thông Tin Liên Hệ'),
        _buildTextField(label: 'Email *', hint: 'example@email.com'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Số Điện Thoại *', hint: '0901234567'),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Ngày Sinh *',
          hint: 'dd/mm/yyyy',
          suffixIcon: Icons.calendar_today,
        ),
        const SizedBox(height: 20),

        _buildSectionTitle('Mật Khẩu'),
        _buildTextField(
          label: 'Mật Khẩu *',
          hint: 'Tối thiểu 6 ký tự',
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Xác Nhận Mật Khẩu *',
          hint: 'Nhập lại mật khẩu',
          isPassword: true,
        ),
        const SizedBox(height: 24),

        // Điều khoản
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Text.rich(
            TextSpan(
              text: 'Bằng việc đăng ký, bạn đồng ý với ',
              style: TextStyle(fontSize: 12, color: Colors.black54),
              children: [
                TextSpan(
                  text: 'Điều khoản sử dụng',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' và '),
                TextSpan(
                  text: 'Chính sách bảo mật',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' của ClinicCare.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Buttons
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Đăng Ký',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Đã có tài khoản? Đăng nhập',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    bool isPassword = false,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 18) : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }
}
