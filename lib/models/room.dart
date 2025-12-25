import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String? id;
  final String hotelId;
  final int number;
  final String type; // double, triple, suite
  final String view; // jardin, piscine, mer
  final int basePrice;
  final int viewExtra;
  final int? capacity;
  final bool isAvailable;
  final String? imageUrl;
  final double? pricePerNight;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Room({
    this.id,
    required this.hotelId,
    required this.number,
    required this.type,
    String? view,
    int? basePrice,
    int? viewExtra,
    double? price,
    this.capacity,
    this.isAvailable = true,
    this.imageUrl,
    this.pricePerNight,
    DateTime? createdAt,
    this.updatedAt,
  })  : view = view ?? '',
        basePrice = basePrice ?? (price != null ? price.round() : 0),
        viewExtra = viewExtra ?? 0,
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'hotelId': hotelId,
        'number': number,
        'type': type,
        'view': view,
        'basePrice': basePrice,
        'viewExtra': viewExtra,
        'capacity': capacity,
        'isAvailable': isAvailable,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      };

  factory Room.fromMap(Map<String, dynamic> map) {
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

    return Room(
      id: map['id'] as String?,
      hotelId: map['hotelId'] as String? ?? '',
      number: (map['number'] is int)
          ? map['number'] as int
          : int.tryParse(map['number']?.toString() ?? '0') ?? 0,
      type: map['type'] as String? ?? '',
      view: map['view'] as String? ?? '',
      basePrice: (map['basePrice'] is int)
          ? map['basePrice'] as int
          : int.tryParse(map['basePrice']?.toString() ?? '0') ?? 0,
      viewExtra: (map['viewExtra'] is int)
          ? map['viewExtra'] as int
          : int.tryParse(map['viewExtra']?.toString() ?? '0') ?? 0,
      capacity: (map['capacity'] is int)
          ? map['capacity'] as int
          : int.tryParse(map['capacity']?.toString() ?? '2') ?? 2,
      isAvailable: map['isAvailable'] as bool? ?? true,
      imageUrl: map['imageUrl'] as String? ?? '',
      createdAt: created,
      updatedAt: updated,
    );
  }

  Room copyWith({
    String? id,
    String? hotelId,
    int? number,
    String? type,
    String? view,
    int? basePrice,
    int? viewExtra,
    int? capacity,
    bool? isAvailable,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      number: number ?? this.number,
      type: type ?? this.type,
      view: view ?? this.view,
      basePrice: basePrice ?? this.basePrice,
      viewExtra: viewExtra ?? this.viewExtra,
      capacity: capacity ?? this.capacity,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Room{id: $id, hotelId: $hotelId, number: $number, type: $type, view: $view, basePrice: $basePrice, viewExtra: $viewExtra, capacity: $capacity, isAvailable: $isAvailable, imageUrl: $imageUrl}';
  }
}
