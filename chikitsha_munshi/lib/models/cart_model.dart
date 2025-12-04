class CartMember {
  final String id;
  final String name;
  final String relation;
  final String? gender;
  final int? age;
  bool selected;

  CartMember({
    required this.id,
    required this.name,
    required this.relation,
    this.gender,
    this.age,
    required this.selected,
  });

  factory CartMember.fromJson(Map<String, dynamic> json) {
    return CartMember(
      id: json['_id'] ?? json['memberId'] ?? '',
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      gender: json['gender'],
      age: json['age'],
      selected: json['selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "memberId": id,
      "selected": selected,
    };
  }
}

class PackageInfo {
  final String id;
  final String name;
  final String? description;
  final int offerPrice;
  final int originalPrice;

  PackageInfo({
    required this.id,
    required this.name,
    this.description,
    required this.offerPrice,
    required this.originalPrice,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      offerPrice: json['offerPrice'] ?? 0,
      originalPrice: json['originalPrice'] ?? 0,
    );
  }
}

class CartItem {
  final String id;
  final String userId;
  final PackageInfo packageInfo;
  final List<CartMember> members;

  CartItem({
    required this.id,
    required this.userId,
    required this.packageInfo,
    required this.members,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      packageInfo: PackageInfo.fromJson(json['packageId'] ?? {}),
      members: (json['members'] as List? ?? [])
          .map((m) => CartMember.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'packageId': packageInfo.toJson(),
      'members': members.map((m) => m.toJson()).toList(),
    };
  }

  // Helper getters for backward compatibility
  String get packageName => packageInfo.name;
  int get price => packageInfo.originalPrice;
  int get discountedPrice => packageInfo.offerPrice;
}

extension PackageInfoExtension on PackageInfo {
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'offerPrice': offerPrice,
      'originalPrice': originalPrice,
    };
  }
}
