import 'package:flutter/material.dart';

/// Données pour la distribution des réservations par statut
class ReservationStatusData {
  final String status;
  final int count;
  final Color color;
  final String displayName;

  ReservationStatusData({
    required this.status,
    required this.count,
    required this.color,
    required this.displayName,
  });

  factory ReservationStatusData.confirmed(int count) {
    return ReservationStatusData(
      status: 'confirmed',
      count: count,
      color: Colors.green,
      displayName: 'Confirmées',
    );
  }

  factory ReservationStatusData.cancelled(int count) {
    return ReservationStatusData(
      status: 'cancelled',
      count: count,
      color: Colors.red,
      displayName: 'Annulées',
    );
  }

  factory ReservationStatusData.pending(int count) {
    return ReservationStatusData(
      status: 'pending',
      count: count,
      color: Colors.amber,
      displayName: 'En attente',
    );
  }
}

/// Données d'occupation pour un hôtel
class HotelOccupancyData {
  final String hotelId;
  final String hotelName;
  final double occupancyRate;
  final int totalRooms;
  final int occupiedRooms;

  HotelOccupancyData({
    required this.hotelId,
    required this.hotelName,
    required this.occupancyRate,
    required this.totalRooms,
    required this.occupiedRooms,
  });

  /// Pourcentage d'occupation arrondi à 1 décimale
  double get occupancyPercentage => double.parse(occupancyRate.toStringAsFixed(1));
}

/// Données des hôtels les plus réservés
class TopHotelData {
  final String hotelId;
  final String hotelName;
  final int reservationCount;

  TopHotelData({
    required this.hotelId,
    required this.hotelName,
    required this.reservationCount,
  });
}

/// Ensemble global de statistiques du dashboard
class DashboardStats {
  final int totalHotels;
  final int totalRooms;
  final int totalReservations;
  final int confirmedReservations;
  final int cancelledReservations;
  final int pendingReservations;
  final double occupancyRate;
  final double estimatedRevenue;
  final List<ReservationStatusData> statusDistribution;
  final List<HotelOccupancyData> occupancyByHotel;
  final List<TopHotelData> topHotels;

  DashboardStats({
    required this.totalHotels,
    required this.totalRooms,
    required this.totalReservations,
    required this.confirmedReservations,
    required this.cancelledReservations,
    required this.pendingReservations,
    required this.occupancyRate,
    required this.estimatedRevenue,
    required this.statusDistribution,
    required this.occupancyByHotel,
    required this.topHotels,
  });

  /// Taux de réservation confirmée
  double get confirmationRate {
    if (totalReservations == 0) return 0;
    return (confirmedReservations / totalReservations) * 100;
  }

  /// Taux d'annulation
  double get cancellationRate {
    if (totalReservations == 0) return 0;
    return (cancelledReservations / totalReservations) * 100;
  }

  /// Taux d'attente
  double get pendingRate {
    if (totalReservations == 0) return 0;
    return (pendingReservations / totalReservations) * 100;
  }

  /// Revenu moyen par réservation confirmée
  double get averageRevenuePerReservation {
    if (confirmedReservations == 0) return 0;
    return estimatedRevenue / confirmedReservations;
  }
}
