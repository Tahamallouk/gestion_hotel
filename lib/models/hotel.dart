import 'package:cloud_firestore/cloud_firestore.dart';

class Hotel {
  final String? id;
  final String name;
  final String city;
  final String country;
  final String address;
  final String? imageUrl;
  final double? rating;
  final String location;
  final double price;
  final double? pricePerNight;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Hotel({
    this.id,
    required this.name,
    required this.city,
    this.country = '',
    required this.address,
    this.imageUrl,
    this.rating,
    this.location = '',
    this.price = 0,
    this.pricePerNight,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'city': city,
        'country': country,
        'address': address,
        'imageUrl': imageUrl,
        'rating': rating,
        'location': location,
        'price': price,
        'createdAt': Timestamp.fromDate(createdAt),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
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

    final dynamic updTs = map['updatedAt'];
    DateTime? updated;
    if (updTs is Timestamp) {
      updated = updTs.toDate();
    } else if (updTs is int) {
      updated = DateTime.fromMillisecondsSinceEpoch(updTs);
    } else if (updTs is String) {
      updated = DateTime.tryParse(updTs);
    }

    return Hotel(
      id: map['id'] as String?,
      name: map['name'] as String? ?? '',
      city: map['city'] as String? ?? '',
      country: map['country'] as String? ?? '',
      address: map['address'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      rating: (map['rating'] is num)
          ? (map['rating'] as num).toDouble()
          : double.tryParse(map['rating']?.toString() ?? '0') ?? 0,
      location: map['location'] as String? ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Hotel copyWith({
    String? id,
    String? name,
    String? city,
    String? country,
    String? address,
    String? imageUrl,
    double? rating,
    String? location,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Hotel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      location: location ?? this.location,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Hotel{id: $id, name: $name, city: $city, country: $country, address: $address, imageUrl: $imageUrl, rating: $rating, location: $location, price: $price, createdAt: $createdAt}';
  }
}
