import 'health_record_model.dart';

class Member {
  final String? id;
  final String name;
  final int? age;
  final String? gender;
  final List<HealthRecord> healthRecords;

  Member({
    this.id,
    required this.name,
    this.age,
    this.gender,
    this.healthRecords = const [],
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['_id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      healthRecords: (json['healthRecords'] as List<dynamic>?)
              ?.map((e) => HealthRecord.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'age': age,
        'gender': gender,
        'healthRecords': healthRecords.map((e) => e.toJson()).toList(),
      };
}
