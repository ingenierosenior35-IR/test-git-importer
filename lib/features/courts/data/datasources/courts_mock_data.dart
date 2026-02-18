import '../models/court_model.dart';

class CourtsMockData {
  static final List<Court> _courts = [];
  static final List<Reservation> _reservations = [];
  static int _reservationCounter = 1000;

  static void initialize() {
    if (_courts.isEmpty) {
      _initializeCourts();
    }
  }

  static void _initializeCourts() {
    _courts.addAll([
      Court(
        id: 'court1',
        name: 'Cancha Deportiva Central',
        address: 'Av. Principal 123, Madrid',
        surfaceType: 'Césped artificial',
        pricePerHour: 40.0,
        amenities: ['Vestuarios', 'Estacionamiento', 'Iluminación'],
      ),
      Court(
        id: 'court2',
        name: 'Polideportivo Norte',
        address: 'Calle Norte 456, Madrid',
        surfaceType: 'Césped natural',
        pricePerHour: 50.0,
        amenities: ['Vestuarios', 'Cafetería', 'Graderías', 'Estacionamiento'],
      ),
      Court(
        id: 'court3',
        name: 'Sport Center 5',
        address: 'Calle 5ta 789, Madrid',
        surfaceType: 'Sintético',
        pricePerHour: 35.0,
        amenities: ['Vestuarios', 'Iluminación'],
      ),
      Court(
        id: 'court4',
        name: 'Arena Deportiva Sur',
        address: 'Av. Sur 321, Madrid',
        surfaceType: 'Césped artificial',
        pricePerHour: 45.0,
        amenities: ['Vestuarios', 'Estacionamiento', 'Iluminación', 'Duchas'],
      ),
      Court(
        id: 'court5',
        name: 'Complejo Deportivo Este',
        address: 'Calle Este 654, Madrid',
        surfaceType: 'Césped natural',
        pricePerHour: 55.0,
        amenities: ['Vestuarios', 'Cafetería', 'Estacionamiento', 'Graderías', 'WiFi'],
      ),
    ]);
  }

  static List<String> getAvailableTimeSlots(DateTime date) {
    return [
      '08:00-09:00',
      '09:00-10:00',
      '10:00-11:00',
      '11:00-12:00',
      '12:00-13:00',
      '14:00-15:00',
      '15:00-16:00',
      '16:00-17:00',
      '17:00-18:00',
      '18:00-19:00',
      '19:00-20:00',
      '20:00-21:00',
      '21:00-22:00',
    ];
  }

  static List<Court> getAllCourts() {
    initialize();
    return List.unmodifiable(_courts);
  }

  static Court? getCourtById(String id) {
    initialize();
    try {
      return _courts.firstWhere((court) => court.id == id);
    } catch (e) {
      return null;
    }
  }

  static Reservation createReservation({
    required String courtId,
    required String matchId,
    required DateTime date,
    required String timeSlot,
    required double price,
    String? paymentMethodId,
  }) {
    initialize();
    final reservation = Reservation(
      id: 'RES${_reservationCounter++}',
      courtId: courtId,
      matchId: matchId,
      date: date,
      timeSlot: timeSlot,
      status: paymentMethodId != null ? ReservationStatus.paid : ReservationStatus.pending,
      price: price,
      paymentMethodId: paymentMethodId,
      createdAt: DateTime.now(),
    );
    _reservations.add(reservation);
    return reservation;
  }

  static Reservation? getReservationById(String id) {
    initialize();
    try {
      return _reservations.firstWhere((res) => res.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Reservation> getReservationsByMatchId(String matchId) {
    initialize();
    return _reservations.where((res) => res.matchId == matchId).toList();
  }

  static void updateReservationStatus(String id, ReservationStatus status) {
    initialize();
    final index = _reservations.indexWhere((res) => res.id == id);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(status: status);
    }
  }

  static bool isTimeSlotAvailable(String courtId, DateTime date, String timeSlot) {
    initialize();
    // Check if there's already a reservation for this court, date, and time slot
    return !_reservations.any((res) => 
      res.courtId == courtId && 
      res.date.year == date.year &&
      res.date.month == date.month &&
      res.date.day == date.day &&
      res.timeSlot == timeSlot &&
      res.status != ReservationStatus.cancelled
    );
  }
}
