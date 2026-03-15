class Clinic {
  final int? id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String? operatingHours;

  Clinic({
    this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.operatingHours,
  });

  factory Clinic.fromMap(Map<String, dynamic> map) => Clinic(
    id: map['clinic_id'],
    name: map['name'] ?? '',
    address: map['address'] ?? '',
    phoneNumber: map['phone_number'],
    operatingHours: map['operating_hours'],
  );

  Map<String, dynamic> toMap() => {
    'clinic_id': id,
    'name': name,
    'address': address,
    'phone_number': phoneNumber,
    'operating_hours': operatingHours,
  };
}
