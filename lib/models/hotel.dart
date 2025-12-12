import 'package:cloud_firestore/cloud_firestore.dart';

class Hotel {
  final String? id;
  final String name;
  final String city;
  final String address;
  final DateTime createdAt;

  Hotel({
    this.id,
    required this.name,
    required this.city,
    required this.address,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'city': city,
        'address': address,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Hotel.fromMap(Map<String, dynamic> map) {
    final dynamic ts = map['createdAt'];
    DateTime created;
    if (ts is Timestamp) {
      created = ts.toDate();
    } else if (ts is int) {
      created = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts is String) {
      created = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    return Hotel(
      id: map['id'] as String?,
      name: map['name'] as String? ?? '',
      city: map['city'] as String? ?? '',
      address: map['address'] as String? ?? '',
      createdAt: created,
    );
  }

  Hotel copyWith({
    String? id,
    String? name,
    String? city,
    String? address,
    DateTime? createdAt,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Hotel{id: $id, name: $name, city: $city, address: $address, createdAt: $createdAt}';
  }
}
