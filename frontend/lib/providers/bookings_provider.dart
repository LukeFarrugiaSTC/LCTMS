import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/address.dart';
import 'package:frontend/models/booking.dart';

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super(_initialBookings);

  void updateStatus(int bookingId, BookingStatus newStatus) {
    state =
        state.map((booking) {
          if (booking.id == bookingId) {
            return booking.copyWith(bookingStatus: newStatus);
          }
          return booking;
        }).toList();
  }

  List<Booking> get upcomingBookings =>
      state.where((b) => b.bookingTime.isAfter(DateTime.now())).toList();

  List<Booking> get historyBookings =>
      state.where((b) => b.bookingTime.isBefore(DateTime.now())).toList();

  //resets state so that refresh button works
  void resetBookings() {
    state = _initialBookings.map((b) => b.copyWith()).toList();
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>(
  (ref) => BookingsNotifier(),
);

// -- Dummy Booking Data --

final List<Address> _tempPickUpAddresses = [
  Address(houseNameNo: '12', street: 'Triq id-Dwieli', town: 'Msida'),
  Address(houseNameNo: '24', street: 'Triq id-Dghajjes', town: 'Msida'),
  Address(houseNameNo: '48', street: 'Triq il-Kullegg', town: 'Msida'),
  Address(houseNameNo: '32, Maria', street: 'Triq l-Isqof', town: 'Msida'),
  Address(houseNameNo: '45', street: 'Triq il-Marina', town: 'Msida'),
  Address(houseNameNo: '31', street: 'Triq il-Qasam', town: 'Msida'),
];

final List<Address> _tempDestinationAddresses = [
  Address(houseNameNo: '85', street: 'Triq l-isptar', town: 'Swatar'),
  Address(houseNameNo: '58', street: 'Triq il-Kontijiet', town: 'Valletta'),
  Address(houseNameNo: '48', street: 'Triq il-Flus', town: 'Msida'),
  Address(
    houseNameNo: '7, Junior College',
    street: 'Triq il-Kullegg',
    town: 'Msida',
  ),
];

final List<Booking> _initialBookings = [
  Booking(
    id: 0,
    userID: 0,
    name: 'Grace',
    surname: 'Tanti',
    pickUpLocation: _tempPickUpAddresses[0],
    dropOffLocation: _tempDestinationAddresses[1],
    bookingTime: DateTime(2025, 4, 15, 08, 00),
    bookingStatus: BookingStatus.booked,
  ),
  Booking(
    id: 1,
    userID: 0,
    name: 'Charles',
    surname: 'Mifsud Bonnici',
    pickUpLocation: _tempPickUpAddresses[1],
    dropOffLocation: _tempDestinationAddresses[3],
    bookingTime: DateTime(2025, 3, 15, 08, 30),
    bookingStatus: BookingStatus.inProgress,
  ),
  Booking(
    id: 2,
    userID: 0,
    name: 'Maria',
    surname: 'Grech',
    pickUpLocation: _tempPickUpAddresses[2],
    dropOffLocation: _tempDestinationAddresses[3],
    bookingTime: DateTime(2025, 3, 9, 12, 30),
    bookingStatus: BookingStatus.cancelled,
  ),
  Booking(
    id: 3,
    userID: 0,
    name: 'Andrea',
    surname: 'Deguara',
    pickUpLocation: _tempPickUpAddresses[3],
    dropOffLocation: _tempDestinationAddresses[0],
    bookingTime: DateTime(2025, 2, 18, 10, 00),
    bookingStatus: BookingStatus.completed,
  ),
  Booking(
    id: 4,
    userID: 1,
    name: 'Moira',
    surname: 'Buhagiar',
    pickUpLocation: _tempPickUpAddresses[4],
    dropOffLocation: _tempDestinationAddresses[1],
    bookingTime: DateTime(2025, 1, 25, 09, 30),
    bookingStatus: BookingStatus.completed,
  ),
  Booking(
    id: 5,
    userID: 2,
    name: 'Kola',
    surname: 'Farrugia',
    pickUpLocation: _tempPickUpAddresses[5],
    dropOffLocation: _tempDestinationAddresses[2],
    bookingTime: DateTime(2025, 1, 15, 15, 30),
    bookingStatus: BookingStatus.cancelled,
  ),
];
