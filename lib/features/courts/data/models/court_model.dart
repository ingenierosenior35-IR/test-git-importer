class Court {
  final String id;
  final String name;
  final String address;
  final String surfaceType;
  final double pricePerHour;
  final String? imageUrl;
  final List<String> amenities;

  Court({
    required this.id,
    required this.name,
    required this.address,
    required this.surfaceType,
    required this.pricePerHour,
    this.imageUrl,
    this.amenities = const [],
  });
}

class Reservation {
  final String id;
  final String courtId;
  final String matchId;
  final DateTime date;
  final String timeSlot; // e.g., "18:00-19:00"
  final ReservationStatus status;
  final double price;
  final String? paymentMethodId;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.courtId,
    required this.matchId,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.price,
    this.paymentMethodId,
    required this.createdAt,
  });

  Reservation copyWith({
    String? id,
    String? courtId,
    String? matchId,
    DateTime? date,
    String? timeSlot,
    ReservationStatus? status,
    double? price,
    String? paymentMethodId,
    DateTime? createdAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      courtId: courtId ?? this.courtId,
      matchId: matchId ?? this.matchId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      price: price ?? this.price,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  paid,
  cancelled,
}
