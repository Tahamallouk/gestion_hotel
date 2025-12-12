import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String? id;
  final String userId;
  final String hotelId;
  final String roomId;
  final String roomType;
  final String viewType;
  final String boardType;
  final int basePrice;
  final int viewExtra;
  final int boardPrice;
  final int nights;
  final int totalPrice;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;

  Reservation({
    this.id,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    String? roomType,
    String? viewType,
    String? boardType,
    int? basePrice,
    int? viewExtra,
    int? boardPrice,
    int? nights,
    int? totalPrice,
    required this.startDate,
    required this.endDate,
    this.status = 'pending',
    DateTime? createdAt,
  })  : roomType = roomType ?? '',
        viewType = viewType ?? '',
        boardType = boardType ?? '',
        basePrice = basePrice ?? 0,
        viewExtra = viewExtra ?? 0,
        boardPrice = boardPrice ?? 0,
        nights = _resolveNights(nights, startDate, endDate),
        totalPrice = totalPrice ??
            _computeTotalPrice(
              basePrice: basePrice,
              viewExtra: viewExtra,
              boardPrice: boardPrice,
              providedNights: nights,
              startDate: startDate,
              endDate: endDate,
            ),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'userId': userId,
        'hotelId': hotelId,
        'roomId': roomId,
        'roomType': roomType,
        'viewType': viewType,
        'boardType': boardType,
        'basePrice': basePrice,
        'viewExtra': viewExtra,
        'boardPrice': boardPrice,
        'nights': nights,
        'totalPrice': totalPrice,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Reservation.fromMap(Map<String, dynamic> map) {
    dynamic sd = map['startDate'];
    dynamic ed = map['endDate'];
    dynamic ca = map['createdAt'];

    DateTime startDate;
    DateTime endDate;
    DateTime createdAt;

    if (sd is Timestamp) {
      startDate = sd.toDate();
    } else if (sd is String) {
      startDate = DateTime.tryParse(sd) ?? DateTime.now();
    } else {
      startDate = DateTime.now();
    }

    if (ed is Timestamp) {
      endDate = ed.toDate();
    } else if (ed is String) {
      endDate = DateTime.tryParse(ed) ?? DateTime.now();
    } else {
      endDate = DateTime.now();
    }

    if (ca is Timestamp) {
      createdAt = ca.toDate();
    } else if (ca is String) {
      createdAt = DateTime.tryParse(ca) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Reservation(
      id: map['id'] as String?,
      userId: map['userId'] as String? ?? '',
      hotelId: map['hotelId'] as String? ?? '',
      roomId: map['roomId'] as String? ?? '',
      roomType: map['roomType'] as String? ?? '',
      viewType: map['viewType'] as String? ?? '',
      boardType: map['boardType'] as String? ?? '',
      basePrice: (map['basePrice'] is int) ? map['basePrice'] as int : int.tryParse(map['basePrice']?.toString() ?? '0') ?? 0,
      viewExtra: (map['viewExtra'] is int) ? map['viewExtra'] as int : int.tryParse(map['viewExtra']?.toString() ?? '0') ?? 0,
      boardPrice: (map['boardPrice'] is int) ? map['boardPrice'] as int : int.tryParse(map['boardPrice']?.toString() ?? '0') ?? 0,
      nights: (map['nights'] is int) ? map['nights'] as int : int.tryParse(map['nights']?.toString() ?? '0') ?? 0,
      totalPrice: (map['totalPrice'] is int) ? map['totalPrice'] as int : int.tryParse(map['totalPrice']?.toString() ?? '0') ?? 0,
      startDate: startDate,
      endDate: endDate,
      status: map['status'] as String? ?? 'pending',
      createdAt: createdAt,
    );
  }

  Reservation copyWith({
    String? id,
    String? userId,
    String? hotelId,
    String? roomId,
    String? roomType,
    String? viewType,
    String? boardType,
    int? basePrice,
    int? viewExtra,
    int? boardPrice,
    int? nights,
    int? totalPrice,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      roomId: roomId ?? this.roomId,
      roomType: roomType ?? this.roomType,
      viewType: viewType ?? this.viewType,
      boardType: boardType ?? this.boardType,
      basePrice: basePrice ?? this.basePrice,
      viewExtra: viewExtra ?? this.viewExtra,
      boardPrice: boardPrice ?? this.boardPrice,
      nights: nights ?? this.nights,
      totalPrice: totalPrice ?? this.totalPrice,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Reservation{id: $id, userId: $userId, hotelId: $hotelId, roomId: $roomId, roomType: $roomType, viewType: $viewType, boardType: $boardType, basePrice: $basePrice, viewExtra: $viewExtra, boardPrice: $boardPrice, nights: $nights, totalPrice: $totalPrice, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt}';
  }

  static int _resolveNights(int? provided, DateTime startDate, DateTime endDate) {
    return provided ?? endDate.difference(startDate).inDays;
  }

  static int _computeTotalPrice({
    required int? basePrice,
    required int? viewExtra,
    required int? boardPrice,
    required int? providedNights,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final nightlyRate = (basePrice ?? 0) + (viewExtra ?? 0) + (boardPrice ?? 0);
    final effectiveNights = _resolveNights(providedNights, startDate, endDate);
    return nightlyRate * effectiveNights;
  }
}
