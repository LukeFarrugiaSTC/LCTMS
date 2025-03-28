import 'package:frontend/models/address.dart';

enum BookingStatus { booked, inProgress, completed, cancelled }

class Booking {
  Booking({
    this.id, //generated by DB
    required this.userID,
    required this.name,
    required this.surname,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.bookingTime,
    required this.bookingStatus,
  });

  final int? id;
  final int userID;
  final String name;
  final String surname;
  final Address pickUpLocation;
  final Address dropOffLocation;
  final DateTime bookingTime;
  BookingStatus bookingStatus;

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
