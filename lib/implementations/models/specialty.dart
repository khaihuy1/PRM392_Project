class Specialty {
  final int? id;
  final String name;
  final String? description;

  Specialty({this.id, required this.name, this.description});

  //   Map from db to Object

  factory Specialty.fromMap(Map<String, dynamic> map) => Specialty(
    id: map['specialty_id'],
    name: map['name'],
    description: map['description'],
  );

  //   Map from Object to db
  Map<String, dynamic> toMap() => {
    'specialty_id': id,
    'name': name,
    'description': description,
  };
}
