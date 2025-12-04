class BookingAddress {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  BookingAddress({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = "India",
  });

  factory BookingAddress.fromJson(Map<String, dynamic> json) {
    return BookingAddress(
      line1: json['line1'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      if (line2 != null) 'line2': line2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  @override
  String toString() {
    final address = [
      line1,
      line2,
      city,
      state,
      postalCode
    ].where((part) => part != null && part.isNotEmpty).join(', ');
    return address;
  }
}

class BookingMember {
  final String memberId;
  final bool selected;
  final String? name;
  final String? relation;

  BookingMember({
    required this.memberId,
    this.selected = true,
    this.name,
    this.relation,
  });

  factory BookingMember.fromJson(Map<String, dynamic> json) {
    final details = json['details']; // backend sends member info inside "details"
    return BookingMember(
      memberId: json['memberId'] ?? '',
      selected: json['selected'] ?? true,
      name: details != null ? details['name'] : null,
      relation: details != null ? details['relation'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'selected': selected,
    };
  }

  @override
  String toString() {
    return 'BookingMember(memberId: $memberId, name: $name, relation: $relation, selected: $selected)';
  }
}


/// Lab info inside package
class LabInfo {
  final String id;
  final String name;
  final String? logoUrl;

  LabInfo({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory LabInfo.fromJson(Map<String, dynamic> json) {
    return LabInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (logoUrl != null) 'logoUrl': logoUrl,
    };
  }
}

class BookingItem {
  final String packageId;
  final List<BookingMember> members;
  final String? packageName;
  final int? price;
  final LabInfo? lab; // ✅ Added lab info

  BookingItem({
    required this.packageId,
    required this.members,
    this.packageName,
    this.price,
    this.lab,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
  final package = json['packageId'];
  LabInfo? lab;

  if (package is Map && package['labId'] != null) {
    final labData = package['labId'];
    if (labData is String) {
      // Only ID is provided
      lab = LabInfo(id: labData, name: "Unknown Lab");
    } else if (labData is Map<String, dynamic>) {
      // Full lab object
      lab = LabInfo.fromJson(labData);
    }
  }

  return BookingItem(
    packageId: package is String ? package : (package['_id'] ?? ''),
    members: (json['members'] as List? ?? [])
        .map((m) => BookingMember.fromJson(m))
        .toList(),
    packageName: package is Map ? package['name'] : null,
    price: package is Map
        ? (package['offerPrice'] ?? package['originalPrice'] ?? 0)
        : null,
    lab: lab,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'members': members.map((m) => m.toJson()).toList(),
      if (packageName != null) 'packageName': packageName,
      if (price != null) 'price': price,
      if (lab != null) 'labId': lab!.toJson(),
    };
  }
}

class PriceBreakdown {
  final double subtotal;
  final double discount;
  final double total;

  PriceBreakdown({
    required this.subtotal,
    this.discount = 0.0,
    required this.total,
  });

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
    };
  }
}

class Booking {
  final String id;
  final String userId;
  final List<BookingItem> items;
  final DateTime bookingDate;
  final String timeSlot;
  final BookingAddress address;
  final String? prescriptionUrl;
  final PriceBreakdown priceBreakdown;
  final String paymentStatus;
  final String orderStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.items,
    required this.bookingDate,
    required this.timeSlot,
    required this.address,
    this.prescriptionUrl,
    required this.priceBreakdown,
    this.paymentStatus = 'pending',
    this.orderStatus = 'booked',
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((item) => BookingItem.fromJson(item))
          .toList(),
      bookingDate: DateTime.parse(json['bookingDate']),
      timeSlot: json['timeSlot'] ?? '',
      address: BookingAddress.fromJson(json['address'] ?? {}),
      prescriptionUrl: json['prescriptionUrl'],
      priceBreakdown: PriceBreakdown.fromJson(json['priceBreakdown'] ?? {}),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      orderStatus: json['orderStatus'] ?? 'booked',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'address': address.toJson(),
      if (prescriptionUrl != null) 'prescriptionUrl': prescriptionUrl,
      'priceBreakdown': priceBreakdown.toJson(),
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
    };
  }
}
