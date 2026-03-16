import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../implementations/local/app_database.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedEthnicity;
  String? _selectedCity;
  String? _selectedWard;
  DateTime? _selectedDate;
  bool _isLoading = false;

  final List<String> _ethnicities = ['Kinh', 'Tày', 'Thái', 'Mường', 'Hoa', 'Khmer', 'Nùng', 'H\'Mông', 'Dao', 'Gia Rai', 'Ê Đê', 'Ba Na', 'Sán Chay', 'Chăm', 'Kơ Ho', 'Xơ Đăng', 'Sán Dìu', 'Hrê', 'Cơ Tu', 'Giáy', 'Khác'];

  // Danh sách đầy đủ 63 tỉnh thành Việt Nam
  final Map<String, List<String>> _addressData = {
    'Thành phố Hà Nội': ['Quận Ba Đình', 'Quận Hoàn Kiếm', 'Quận Tây Hồ', 'Quận Long Biên', 'Quận Cầu Giấy', 'Quận Đống Đa', 'Quận Hai Bà Trưng', 'Quận Hoàng Mai', 'Quận Thanh Xuân', 'Huyện Sóc Sơn', 'Huyện Đông Anh', 'Huyện Gia Lâm', 'Quận Nam Từ Liêm', 'Huyện Thanh Trì', 'Quận Bắc Từ Liêm', 'Huyện Mê Linh', 'Quận Hà Đông', 'Thị xã Sơn Tây', 'Huyện Ba Vì', 'Huyện Phúc Thọ', 'Huyện Đan Phượng', 'Huyện Hoài Đức', 'Huyện Quốc Oai', 'Huyện Thạch Thất', 'Huyện Chương Mỹ', 'Huyện Thanh Oai', 'Huyện Thường Tín', 'Huyện Phú Xuyên', 'Huyện Ứng Hòa', 'Huyện Mỹ Đức'],
    'Thành phố Hồ Chí Minh': ['Quận 1', 'Quận 12', 'Quận Thủ Đức', 'Quận 9', 'Quận Gò Vấp', 'Quận Bình Thạnh', 'Quận Tân Bình', 'Quận Tân Phú', 'Quận Phú Nhuận', 'Quận 2', 'Quận 3', 'Quận 10', 'Quận 11', 'Quận 4', 'Quận 5', 'Quận 6', 'Quận 8', 'Quận Bình Tân', 'Quận 7', 'Huyện Củ Chi', 'Huyện Hóc Môn', 'Huyện Bình Chánh', 'Huyện Nhà Bè', 'Huyện Cần Giờ'],
    'Thành phố Đà Nẵng': ['Quận Liên Chiểu', 'Quận Thanh Khê', 'Quận Hải Châu', 'Quận Sơn Trà', 'Quận Ngũ Hành Sơn', 'Quận Cẩm Lệ', 'Huyện Hòa Vang'],
    'Thành phố Hải Phòng': ['Quận Hồng Bàng', 'Quận Ngô Quyền', 'Quận Lê Chân', 'Quận Hải An', 'Quận Kiến An', 'Quận Đồ Sơn', 'Quận Dương Kinh', 'Huyện Thuỷ Nguyên', 'Huyện An Dương', 'Huyện An Lão', 'Huyện Tiên Lãng', 'Huyện Vĩnh Bảo', 'Huyện Kiến Thuỵ', 'Huyện Cát Hải'],
    'Thành phố Cần Thơ': ['Quận Ninh Kiều', 'Quận Bình Thuỷ', 'Quận Cái Răng', 'Quận Thốt Nốt', 'Huyện Vĩnh Thạnh', 'Huyện Cờ Đỏ', 'Huyện Phong Điền', 'Huyện Thới Lai'],
    'Tỉnh An Giang': ['Thành phố Long Xuyên', 'Thành phố Châu Đốc', 'Thị xã Tân Châu', 'Huyện An Phú', 'Huyện Tịnh Biên', 'Huyện Tri Tôn', 'Huyện Châu Phú', 'Huyện Châu Thành', 'Huyện Chợ Mới', 'Huyện Thoại Sơn'],
    'Tỉnh Bà Rịa - Vũng Tàu': ['Thành phố Vũng Tàu', 'Thành phố Bà Rịa', 'Huyện Châu Đức', 'Huyện Xuyên Mộc', 'Huyện Long Điền', 'Huyện Đất Đỏ', 'Thị xã Phú Mỹ', 'Huyện Côn Đảo'],
    'Tỉnh Bắc Giang': ['Thành phố Bắc Giang', 'Huyện Yên Thế', 'Huyện Tân Yên', 'Huyện Lạng Giang', 'Huyện Lục Nam', 'Huyện Lục Ngạn', 'Huyện Sơn Động', 'Huyện Yên Dũng', 'Huyện Việt Yên', 'Huyện Hiệp Hòa'],
    'Tỉnh Bắc Kạn': ['Thành phố Bắc Kạn', 'Huyện Pác Nặm', 'Huyện Ba Bể', 'Huyện Ngân Sơn', 'Huyện Chợ Đồn', 'Huyện Chợ Mới', 'Huyện Na Rì'],
    'Tỉnh Bạc Liêu': ['Thành phố Bạc Liêu', 'Huyện Hồng Dân', 'Huyện Phước Long', 'Huyện Vĩnh Lợi', 'Thị xã Giá Rai', 'Huyện Đông Hải', 'Huyện Hoà Bình'],
    'Tỉnh Bắc Ninh': ['Thành phố Bắc Ninh', 'Huyện Yên Phong', 'Huyện Quế Võ', 'Huyện Tiên Du', 'Thị xã Từ Sơn', 'Huyện Thuận Thành', 'Huyện Gia Bình', 'Huyện Lương Tài'],
    'Tỉnh Bến Tre': ['Thành phố Bến Tre', 'Huyện Châu Thành', 'Huyện Chợ Lách', 'Huyện Mỏ Cày Nam', 'Huyện Giồng Trôm', 'Huyện Bình Đại', 'Huyện Ba Tri', 'Huyện Thạnh Phú', 'Huyện Mỏ Cày Bắc'],
    'Tỉnh Bình Định': ['Thành phố Quy Nhơn', 'Huyện An Lão', 'Thị xã Hoài Nhơn', 'Huyện Hoài Ân', 'Huyện Phù Mỹ', 'Huyện Vĩnh Thạnh', 'Huyện Tây Sơn', 'Huyện Phù Cát', 'Thị xã An Nhơn', 'Huyện Tuy Phước', 'Huyện Vân Canh'],
    'Tỉnh Bình Dương': ['Thành phố Thủ Dầu Một', 'Huyện Bàu Bàng', 'Huyện Dầu Tiếng', 'Thành phố Bến Cát', 'Huyện Phú Giáo', 'Thành phố Tân Uyên', 'Thành phố Dĩ An', 'Thành phố Thuận An', 'Huyện Bắc Tân Uyên'],
    'Tỉnh Bình Phước': ['Thị xã Phước Long', 'Thành phố Đồng Xoài', 'Thị xã Bình Long', 'Huyện Bù Gia Mập', 'Huyện Lộc Ninh', 'Huyện Bù Đốp', 'Huyện Hớn Quản', 'Huyện Đồng Phú', 'Huyện Bù Đăng', 'Thị xã Chơn Thành', 'Huyện Phú Riềng'],
    'Tỉnh Bình Thuận': ['Thành phố Phan Thiết', 'Huyện Tuy Phong', 'Huyện Bắc Bình', 'Huyện Hàm Thuận Bắc', 'Huyện Hàm Thuận Nam', 'Huyện Tánh Linh', 'Huyện Đức Linh', 'Huyện Hàm Tân', 'Thị xã La Gi', 'Huyện Phú Quý'],
    'Tỉnh Cà Mau': ['Thành phố Cà Mau', 'Huyện U Minh', 'Huyện Thới Bình', 'Huyện Trần Văn Thời', 'Huyện Cái Nước', 'Huyện Đầm Dơi', 'Huyện Năm Căn', 'Huyện Phú Tân', 'Huyện Ngọc Hiển'],
    'Tỉnh Cao Bằng': ['Thành phố Cao Bằng', 'Huyện Bảo Lâm', 'Huyện Bảo Lạc', 'Huyện Hà Quảng', 'Huyện Trùng Khánh', 'Huyện Hạ Lang', 'Huyện Quảng Hòa', 'Huyện Hoà An', 'Huyện Nguyên Bình', 'Huyện Thạch An'],
    'Tỉnh Đắk Lắk': ['Thành phố Buôn Ma Thuột', 'Thị xã Buôn Hồ', 'Huyện Ea H\'leo', 'Huyện Krông Năng', 'Huyện Krông Búk', 'Huyện Ea Súp', 'Huyện Buôn Đôn', 'Huyện Cư M\'gar', 'Huyện Krông Pắc', 'Huyện Krông Bông', 'Huyện Krông Ana', 'Huyện Lắk', 'Huyện Ea Kar', 'Huyện M\'Drắk', 'Huyện Krông Rắc'],
    'Tỉnh Đắk Nông': ['Thành phố Gia Nghĩa', 'Huyện Đăk Glong', 'Huyện Đăk Mil', 'Huyện Krông Nô', 'Huyện Đăk Song', 'Huyện Đăk R\'Lấp', 'Huyện Tuy Đức', 'Huyện Cư Jút'],
    'Tỉnh Điện Biên': ['Thành phố Điện Biên Phủ', 'Thị xã Mường Lay', 'Huyện Điện Biên', 'Huyện Điện Biên Đông', 'Huyện Mường Ang', 'Huyện Mường Chà', 'Huyện Mường Nhé', 'Huyện Nậm Pồ', 'Huyện Tủa Chùa', 'Huyện Tuần Giáo'],
    'Tỉnh Đồng Nai': ['Thành phố Biên Hòa', 'Thành phố Long Khánh', 'Huyện Tân Phú', 'Huyện Định Quán', 'Huyện Xuân Lộc', 'Huyện Cẩm Mỹ', 'Huyện Thống Nhất', 'Huyện Trảng Bom', 'Huyện Vĩnh Cửu', 'Huyện Long Thành', 'Huyện Nhơn Trạch'],
    'Tỉnh Đồng Tháp': ['Thành phố Cao Lãnh', 'Thành phố Sa Đéc', 'Thành phố Hồng Ngự', 'Huyện Tân Hồng', 'Huyện Hồng Ngự', 'Huyện Tam Nông', 'Huyện Tháp Mười', 'Huyện Cao Lãnh', 'Huyện Thanh Bình', 'Huyện Lấp Vò', 'Huyện Lai Vung', 'Huyện Châu Thành'],
    'Tỉnh Gia Lai': ['Thành phố Pleiku', 'Thị xã An Khê', 'Thị xã Ayun Pa', 'Huyện KBang', 'Huyện Đăk Đoa', 'Huyện Chư Păh', 'Huyện Ia Grai', 'Huyện Mang Yang', 'Huyện Kông Chro', 'Huyện Đức Cơ', 'Huyện Chư Prông', 'Huyện Chư Sê', 'Huyện Đăk Pơ', 'Huyện Ia Pa', 'Huyện Krông Pa', 'Huyện Phú Thiện', 'Huyện Chư Pưh'],
    'Tỉnh Hà Giang': ['Thành phố Hà Giang', 'Huyện Đồng Văn', 'Huyện Mèo Vạc', 'Huyện Yên Minh', 'Huyện Quản Bạ', 'Huyện Vị Xuyên', 'Huyện Bắc Mê', 'Huyện Hoàng Su Phì', 'Huyện Xín Mần', 'Huyện Bắc Quang', 'Huyện Quang Bình'],
    'Tỉnh Hà Nam': ['Thành phố Phủ Lý', 'Thị xã Duy Tiên', 'Huyện Kim Bảng', 'Huyện Thanh Liêm', 'Huyện Bình Lục', 'Huyện Lý Nhân'],
    'Tỉnh Hà Tĩnh': ['Thành phố Hà Tĩnh', 'Thị xã Hồng Lĩnh', 'Huyện Nghi Xuân', 'Huyện Đức Thọ', 'Huyện Hương Sơn', 'Huyện Hương Khê', 'Huyện Vũ Quang', 'Huyện Can Lộc', 'Huyện Lộc Hà', 'Huyện Thạch Hà', 'Huyện Cẩm Xuyên', 'Huyện Kỳ Anh', 'Thị xã Kỳ Anh'],
    'Tỉnh Hải Dương': ['Thành phố Hải Dương', 'Thành phố Chí Linh', 'Huyện Nam Sách', 'Thành phố Kinh Môn', 'Huyện Kim Thành', 'Huyện Thanh Hà', 'Huyện Cẩm Giàng', 'Huyện Bình Giang', 'Huyện Gia Lộc', 'Huyện Tứ Kỳ', 'Huyện Ninh Giang', 'Huyện Thanh Miện'],
    'Tỉnh Hậu Giang': ['Thành phố Vị Thanh', 'Thành phố Ngã Bảy', 'Huyện Châu Thành A', 'Huyện Châu Thành', 'Huyện Phụng Hiệp', 'Huyện Vị Thuỷ', 'Huyện Long Mỹ', 'Thị xã Long Mỹ'],
    'Tỉnh Hòa Bình': ['Thành phố Hòa Bình', 'Huyện Đà Bắc', 'Huyện Lương Sơn', 'Huyện Kim Bôi', 'Huyện Cao Phong', 'Huyện Tân Lạc', 'Huyện Mai Châu', 'Huyện Lạc Sơn', 'Huyện Yên Thủy', 'Huyện Lạc Thủy'],
    'Tỉnh Hưng Yên': ['Thành phố Hưng Yên', 'Huyện Văn Lâm', 'Huyện Văn Giang', 'Huyện Yên Mỹ', 'Thị xã Mỹ Hào', 'Huyện Ân Thi', 'Huyện Khoái Châu', 'Huyện Kim Động', 'Huyện Tiên Lữ', 'Huyện Phù Cừ'],
    'Tỉnh Khánh Hòa': ['Thành phố Nha Trang', 'Thành phố Cam Ranh', 'Huyện Cam Lâm', 'Huyện Vạn Ninh', 'Thị xã Ninh Hòa', 'Huyện Khánh Vĩnh', 'Huyện Khánh Sơn', 'Huyện Diên Khánh', 'Huyện Trường Sa'],
    'Tỉnh Kiên Giang': ['Thành phố Rạch Giá', 'Thành phố Hà Tiên', 'Huyện Kiên Lương', 'Huyện Hòn Đất', 'Huyện Tân Hiệp', 'Huyện Châu Thành', 'Huyện Giồng Riềng', 'Huyện Gò Quao', 'Huyện An Biên', 'Huyện An Minh', 'Huyện Vĩnh Thuận', 'Thành phố Phú Quốc', 'Huyện Kiên Hải', 'Huyện U Minh Thượng', 'Huyện Giang Thành'],
    'Tỉnh Kon Tum': ['Thành phố Kon Tum', 'Huyện Đăk Glei', 'Huyện Ngọc Hồi', 'Huyện Đăk Tô', 'Huyện Kon Plông', 'Huyện Kon Rẫy', 'Huyện Đăk Hà', 'Huyện Sa Thầy', 'Huyện Tu Mơ Rông', 'Huyện Ia H\' Drai'],
    'Tỉnh Lai Châu': ['Thành phố Lai Châu', 'Huyện Tam Đường', 'Huyện Mường Tè', 'Huyện Sìn Hồ', 'Huyện Phong Thổ', 'Huyện Than Uyên', 'Huyện Tân Uyên', 'Huyện Nậm Nhùn'],
    'Tỉnh Lâm Đồng': ['Thành phố Đà Lạt', 'Thành phố Bảo Lộc', 'Huyện Đam Rông', 'Huyện Lạc Dương', 'Huyện Lâm Hà', 'Huyện Đơn Dương', 'Huyện Đức Trọng', 'Huyện Di Linh', 'Huyện Bảo Lâm', 'Huyện Đạ Huoai', 'Huyện Đạ Tẻh', 'Huyện Cát Tiên'],
    'Tỉnh Lạng Sơn': ['Thành phố Lạng Sơn', 'Huyện Tràng Định', 'Huyện Bình Gia', 'Huyện Văn Lãng', 'Huyện Cao Lộc', 'Huyện Văn Quan', 'Huyện Bắc Sơn', 'Huyện Hữu Lũng', 'Huyện Chi Lăng', 'Huyện Lộc Bình', 'Huyện Đình Lập'],
    'Tỉnh Lào Cai': ['Thành phố Lào Cai', 'Huyện Bát Xát', 'Huyện Mường Khương', 'Huyện Si Ma Cai', 'Huyện Bắc Hà', 'Huyện Bảo Thắng', 'Huyện Bảo Yên', 'Thị xã Sa Pa', 'Huyện Văn Bàn'],
    'Tỉnh Long An': ['Thành phố Tân An', 'Thị xã Kiến Tường', 'Huyện Tân Hưng', 'Huyện Vĩnh Hưng', 'Huyện Mộc Hóa', 'Huyện Tân Thạnh', 'Huyện Thạnh Hóa', 'Huyện Đức Huệ', 'Huyện Đức Hòa', 'Huyện Bến Lức', 'Huyện Thủ Thừa', 'Huyện Tân Trụ', 'Huyện Cần Đước', 'Huyện Cần Giuộc', 'Huyện Châu Thành'],
    'Tỉnh Nam Định': ['Thành phố Nam Định', 'Huyện Mỹ Lộc', 'Huyện Vụ Bản', 'Huyện Ý Yên', 'Huyện Nghĩa Hưng', 'Huyện Nam Trực', 'Huyện Trực Ninh', 'Huyện Xuân Trường', 'Huyện Giao Thủy', 'Huyện Hải Hậu'],
    'Tỉnh Nghệ An': ['Thành phố Vinh', 'Thị xã Cửa Lò', 'Thị xã Thái Hoà', 'Huyện Quế Phong', 'Huyện Quỳ Châu', 'Huyện Kỳ Sơn', 'Huyện Tương Dương', 'Huyện Nghĩa Đàn', 'Huyện Quỳ Hợp', 'Huyện Quỳnh Lưu', 'Huyện Con Cuông', 'Huyện Tân Kỳ', 'Huyện Anh Sơn', 'Huyện Diễn Châu', 'Huyện Yên Thành', 'Huyện Đô Lương', 'Huyện Thanh Chương', 'Huyện Nghi Lộc', 'Huyện Hưng Nguyên', 'Thị xã Hoàng Mai'],
    'Tỉnh Ninh Bình': ['Thành phố Ninh Bình', 'Thành phố Tam Điệp', 'Huyện Nho Quan', 'Huyện Gia Viễn', 'Huyện Hoa Lư', 'Huyện Yên Khánh', 'Huyện Kim Sơn', 'Huyện Yên Mô'],
    'Tỉnh Ninh Thuận': ['Thành phố Phan Rang-Tháp Chàm', 'Huyện Bác Ái', 'Huyện Ninh Sơn', 'Huyện Ninh Hải', 'Huyện Ninh Phước', 'Huyện Thuận Bắc', 'Huyện Thuận Nam'],
    'Tỉnh Phú Thọ': ['Thành phố Việt Trì', 'Thị xã Phú Thọ', 'Huyện Đoan Hùng', 'Huyện Hạ Hoà', 'Huyện Thanh Ba', 'Huyện Phù Ninh', 'Huyện Yên Lập', 'Huyện Cẩm Khê', 'Huyện Tam Nông', 'Huyện Thanh Thủy', 'Huyện Lâm Thao', 'Huyện Thanh Sơn', 'Huyện Tân Sơn'],
    'Tỉnh Phú Yên': ['Thành phố Tuy Hòa', 'Thị xã Sông Cầu', 'Huyện Đồng Xuân', 'Huyện Tuy An', 'Huyện Sơn Hòa', 'Huyện Sông Hinh', 'Thị xã Đông Hòa', 'Huyện Tây Hòa', 'Huyện Phú Hòa'],
    'Tỉnh Quảng Bình': ['Thành phố Đồng Hới', 'Huyện Tuyên Hóa', 'Huyện Minh Hóa', 'Huyện Quảng Trạch', 'Thị xã Ba Đồn', 'Huyện Bố Trạch', 'Huyện Quảng Ninh', 'Huyện Lệ Thủy'],
    'Tỉnh Quảng Nam': ['Thành phố Tam Kỳ', 'Thành phố Hội An', 'Huyện Tây Giang', 'Huyện Đông Giang', 'Huyện Nam Giang', 'Huyện Phước Sơn', 'Huyện Bắc Trà My', 'Huyện Nam Trà My', 'Huyện Nam Giang', 'Huyện Đại Lộc', 'Thị xã Điện Bàn', 'Huyện Duy Xuyên', 'Huyện Quế Sơn', 'Huyện Thăng Bình', 'Huyện Hiệp Đức', 'Huyện Tiên Phước', 'Huyện Bắc Trà My', 'Huyện Nam Trà My', 'Huyện Núi Thành', 'Huyện Phú Ninh', 'Huyện Nông Sơn'],
    'Tỉnh Quảng Ngãi': ['Thành phố Quảng Ngãi', 'Huyện Bình Sơn', 'Huyện Trà Bồng', 'Huyện Tây Trà', 'Huyện Sơn Tịnh', 'Huyện Tư Nghĩa', 'Huyện Sơn Hà', 'Huyện Sơn Tây', 'Huyện Minh Long', 'Huyện Nghĩa Hành', 'Huyện Mộ Đức', 'Thị xã Đức Phổ', 'Huyện Ba Tơ', 'Huyện Lý Sơn'],
    'Tỉnh Quảng Ninh': ['Thành phố Hạ Long', 'Thành phố Móng Cái', 'Thành phố Cẩm Phả', 'Thành phố Uông Bí', 'Huyện Bình Liêu', 'Huyện Tiên Yên', 'Huyện Đầm Hà', 'Huyện Hải Hà', 'Huyện Ba Chẽ', 'Huyện Vân Đồn', 'Thị xã Đông Triều', 'Thị xã Quảng Yên', 'Huyện Cô Tô'],
    'Tỉnh Quảng Trị': ['Thành phố Đông Hà', 'Thị xã Quảng Trị', 'Huyện Vĩnh Linh', 'Huyện Hướng Hóa', 'Huyện Gio Linh', 'Huyện Đa Krông', 'Huyện Cam Lộ', 'Huyện Triệu Phong', 'Huyện Hải Lăng', 'Huyện Đảo Cồn Cỏ'],
    'Tỉnh Sóc Trăng': ['Thành phố Sóc Trăng', 'Huyện Châu Thành', 'Huyện Kế Sách', 'Huyện Mỹ Tú', 'Huyện Cù Lao Dung', 'Huyện Long Phú', 'Huyện Mỹ Xuyên', 'Thị xã Ngã Năm', 'Huyện Thạnh Trị', 'Thị xã Vĩnh Châu', 'Huyện Trần Đề'],
    'Tỉnh Sơn La': ['Thành phố Sơn La', 'Huyện Quỳnh Nhai', 'Huyện Thuận Châu', 'Huyện Mường La', 'Huyện Bắc Yên', 'Huyện Phù Yên', 'Huyện Mộc Châu', 'Huyện Yên Châu', 'Huyện Mai Sơn', 'Huyện Sông Mã', 'Huyện Sốp Cộp', 'Huyện Vân Hồ'],
    'Tỉnh Tây Ninh': ['Thành phố Tây Ninh', 'Huyện Tân Biên', 'Huyện Tân Châu', 'Huyện Dương Minh Châu', 'Huyện Châu Thành', 'Thị xã Hòa Thành', 'Huyện Gò Dầu', 'Huyện Bến Cầu', 'Thị xã Trảng Bàng'],
    'Tỉnh Thái Bình': ['Thành phố Thái Bình', 'Huyện Quỳnh Phụ', 'Huyện Hưng Hà', 'Huyện Đông Hưng', 'Huyện Thái Thụy', 'Huyện Tiền Hải', 'Huyện Kiến Xương', 'Huyện Vũ Thư'],
    'Tỉnh Thái Nguyên': ['Thành phố Thái Nguyên', 'Thành phố Sông Công', 'Huyện Định Hóa', 'Huyện Phú Lương', 'Huyện Đồng Hỷ', 'Huyện Võ Nhai', 'Huyện Đại Từ', 'Thị xã Phổ Yên', 'Huyện Phú Bình'],
    'Tỉnh Thanh Hóa': ['Thành phố Thanh Hóa', 'Thị xã Bỉm Sơn', 'Thành phố Sầm Sơn', 'Huyện Mường Lát', 'Huyện Quan Hóa', 'Huyện Bá Thước', 'Huyện Quan Sơn', 'Huyện Lang Chánh', 'Huyện Ngọc Lặc', 'Huyện Cẩm Thủy', 'Huyện Thạch Thành', 'Huyện Hà Trung', 'Huyện Vĩnh Lộc', 'Huyện Yên Định', 'Huyện Thọ Xuân', 'Huyện Thường Xuân', 'Huyện Triệu Sơn', 'Huyện Thiệu Hóa', 'Huyện Hoằng Hóa', 'Huyện Hậu Lộc', 'Huyện Nga Sơn', 'Huyện Quảng Xương', 'Huyện Nông Cống', 'Thị xã Nghi Sơn', 'Huyện Như Thanh', 'Huyện Như Xuân'],
    'Tỉnh Thừa Thiên Huế': ['Thành phố Huế', 'Huyện Phong Điền', 'Huyện Quảng Điền', 'Huyện Phú Vang', 'Thị xã Hương Thủy', 'Thị xã Hương Trà', 'Huyện Phú Lộc', 'Huyện A Lưới', 'Huyện Nam Đông'],
    'Tỉnh Tiền Giang': ['Thành phố Mỹ Tho', 'Thị xã Gò Công', 'Thị xã Cai Lậy', 'Huyện Tân Phước', 'Huyện Cái Bè', 'Huyện Cai Lậy', 'Huyện Châu Thành', 'Huyện Chợ Gạo', 'Huyện Gò Công Tây', 'Huyện Gò Công Đông', 'Huyện Tân Phú Đông'],
    'Tỉnh Trà Vinh': ['Thành phố Trà Vinh', 'Huyện Càng Long', 'Huyện Cầu Kè', 'Huyện Tiểu Cần', 'Huyện Châu Thành', 'Huyện Cầu Ngang', 'Huyện Trà Cú', 'Huyện Duyên Hải', 'Thị xã Duyên Hải'],
    'Tỉnh Tuyên Quang': ['Thành phố Tuyên Quang', 'Huyện Lâm Bình', 'Huyện Na Hang', 'Huyện Chiêm Hóa', 'Huyện Hàm Yên', 'Huyện Yên Sơn', 'Huyện Sơn Dương'],
    'Tỉnh Vĩnh Long': ['Thành phố Vĩnh Long', 'Huyện Long Hồ', 'Huyện Mang Thít', 'Huyện Vũng Liêm', 'Huyện Tam Bình', 'Thị xã Bình Minh', 'Huyện Trà Ôn', 'Huyện Bình Tân'],
    'Tỉnh Vĩnh Phúc': ['Thành phố Vĩnh Yên', 'Thành phố Phúc Yên', 'Huyện Lập Thạch', 'Huyện Tam Dương', 'Huyện Tam Đảo', 'Huyện Bình Xuyên', 'Huyện Yên Lạc', 'Huyện Vĩnh Tường', 'Huyện Sông Lô'],
    'Tỉnh Yên Bái': ['Thành phố Yên Bái', 'Thị xã Nghĩa Lộ', 'Huyện Lục Yên', 'Huyện Văn Yên', 'Huyện Mù Căng Chải', 'Huyện Trấn Yên', 'Huyện Trạm Tấu', 'Huyện Văn Chấn', 'Huyện Yên Bình'],
  };

  List<String> get _cities => _addressData.keys.toList();
  List<String> _availableWards = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0066B3)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showValidationDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(color: isSuccess ? Colors.green : const Color(0xFF0066B3), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (isSuccess) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: isSuccess ? Colors.green : const Color(0xFF5ABFA3)),
                  child: const Text('Đồng ý', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _selectedCity == null) {
      _showValidationDialog('Thông tin chưa phù hợp', 'Vui lòng nhập đầy đủ các trường bắt buộc (*)');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final db = await AppDatabase.instance.db;
      await db.insert('users', {
        'full_name': '${_lastNameController.text} ${_firstNameController.text}',
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'password_hash': _passwordController.text,
        'role': 'Patient',
        'ethnicity': _selectedEthnicity,
        'city': _selectedCity,
        'ward': _selectedWard,
        'detail_address': _addressController.text,
      });

      _showValidationDialog('Thành công', 'Tài khoản đã được lưu lại!', isSuccess: true);
    } catch (e) {
      _showValidationDialog('Lỗi', 'Không thể lưu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông Tin Cá Nhân'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTextField(label: 'Tên *', hint: 'Tên', controller: _firstNameController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(label: 'Họ *', hint: 'Họ', controller: _lastNameController)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDropdownField('Dân tộc *', _ethnicities, _selectedEthnicity, (v) => setState(() => _selectedEthnicity = v))),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: 'Ngày Sinh *',
                hint: 'dd/mm/yy',
                controller: _dobController,
                readOnly: true,
                suffixIcon: Icons.calendar_today,
                onTap: () => _selectDate(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSectionTitle('Thông Tin Liên Hệ'),
        _buildTextField(label: 'Email *', hint: 'email@gmail.com', controller: _emailController),
        const SizedBox(height: 16),
        _buildTextField(label: 'Số Điện Thoại *', hint: '0123456789', controller: _phoneController),
        const SizedBox(height: 16),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Tỉnh/Thành phố
            Expanded(
              child: _buildDropdownField('Tỉnh/TP *', _cities, _selectedCity, (city) {
                setState(() {
                  _selectedCity = city;
                  _selectedWard = null; // Reset xã khi đổi tỉnh
                  _availableWards = _addressData[city] ?? []; // Cập nhật danh sách xã mới
                });
              }),
            ),
            const SizedBox(width: 12),
            // Dropdown Xã/Phường (Thay đổi theo Tỉnh)
            Expanded(
              child: _buildDropdownField(
                'Quận/Huyện *', 
                _availableWards, 
                _selectedWard, 
                (v) => setState(() => _selectedWard = v),
                enabled: _selectedCity != null, // Chỉ cho chọn khi đã chọn tỉnh
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(label: 'Địa chỉ chi tiết *', hint: 'Số nhà, tên đường...', controller: _addressController),

        const SizedBox(height: 20),
        _buildSectionTitle('Mật Khẩu'),
        _buildTextField(label: 'Mật Khẩu *', hint: '********', isPassword: true, controller: _passwordController),
        const SizedBox(height: 16),
        _buildTextField(label: 'Xác Nhận Mật Khẩu *', hint: '********', isPassword: true, controller: _confirmPasswordController),
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066B3)),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Đăng Ký', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }

  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, bool isPassword = false, IconData? suffixIcon, bool readOnly = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 16) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? selectedItem, ValueChanged<String?> onChanged, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedItem,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? const Color(0xFFF5F5F5) : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
          hint: Text(enabled ? 'Chọn' : 'Chọn Tỉnh trước', style: const TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}
