import 'member_model.dart';

class UserModel {
  final String? id;
  final String phone;
  final List<Member> members;

  UserModel({
    this.id,
    required this.phone,
    this.members = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      phone: json['phone'],
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => Member.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'phone': phone,
        'members': members.map((e) => e.toJson()).toList(),
      };
}
