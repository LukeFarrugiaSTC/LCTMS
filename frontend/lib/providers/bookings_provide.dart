import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/address.dart';
import 'package:frontend/models/booking.dart';

// StateNotifier for managing bookings
class BookingNotifier extends StateNotifier<List<Booking>> {
  BookingNotifier()
    : super([
        Booking(
          id: 0,
          name: 'Luke',
          surname: 'Farrugia',
          pickUpLocation: Address(
            houseNameNo: '12',
            street: 'Triq id-Dwieli',
            town: 'Dingli',
          ),
          dropOffLocation: Address(
            houseNameNo: '85',
            street: 'Triq l-isptar',
            town: 'Swatar',
          ),
          bookingTime: DateTime(2025, 3, 15, 15, 30),
          bookingStatus: BookingStatus.booked,
        ),
        Booking(
          id: 1,
          name: 'Rita',
          surname: 'Farrugia',
          pickUpLocation: Address(
            houseNameNo: '24',
            street: 'Triq id-Dghajjes',
            town: 'Msida',
          ),
          dropOffLocation: Address(
            houseNameNo: '58',
            street: 'Triq il-Kontijiet',
            town: 'Valletta',
          ),
          bookingTime: DateTime(2025, 2, 15, 15, 30),
          bookingStatus: BookingStatus.completed,
        ),
        Booking(
          id: 2,
          name: 'Rita',
          surname: 'Farrugia',
          pickUpLocation: Address(
            houseNameNo: '48',
            street: 'Triq il-Kullegg',
            town: 'Msida',
          ),
          dropOffLocation: Address(
            houseNameNo: '48',
            street: 'Triq il-Flus',
            town: 'Msida',
          ),
          bookingTime: DateTime(2025, 1, 15, 15, 30),
          bookingStatus: BookingStatus.cancelled,
        ),
      ]);

  //method to add a booking to the app's state
  void addBooking(Booking booking) {
    state = [...state, booking];
  }
}

//To Do
//Method to add a booking
//Method to remove a booking
//method to update a booking status

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, List<Booking>>((ref) {
      return BookingNotifier();
    });
