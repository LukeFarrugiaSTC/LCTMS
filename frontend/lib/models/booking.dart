import 'package:frontend/models/address.dart';

// Enum representing the different statuses a booking can have
enum BookingStatus {
  pending,
  confirmed,
  driverEnRoute,
  driverArrived,
  clientPickedUp,
  completed,
  cancelled,
  clientNoShow,
  rejected,
  failed,
}

class Booking {
  Booking({
    this.id, //generated by DB
    this.userID,
    required this.name,
    required this.surname,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.bookingTime,
    required this.bookingStatus,
  });

  final int? id;
  final int? userID;
  final String name;
  final String surname;
  final Address pickUpLocation;
  final String dropOffLocation;
  final DateTime bookingTime;
  BookingStatus bookingStatus;

  // Creates a copy of this booking with a potentially new booking status
  Booking copyWith({BookingStatus? bookingStatus}) {
    return Booking(
      id: id,
      userID: userID,
      name: name,
      surname: surname,
      pickUpLocation: pickUpLocation,
      dropOffLocation: dropOffLocation,
      bookingTime: bookingTime,
      bookingStatus: bookingStatus ?? this.bookingStatus,
    );
  }
}
