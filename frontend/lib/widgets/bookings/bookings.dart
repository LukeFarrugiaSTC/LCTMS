import 'package:flutter/material.dart';
import 'package:frontend/models/address.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/widgets/bookings/bookings_list.dart';

class Bookings extends StatelessWidget {
  Bookings({super.key});

  final List<Address> _tempPickUpAddresses = [
    Address(houseNameNo: '12', street: 'Triq id-Dwieli', town: 'Dingli'),
    Address(houseNameNo: '24', street: 'Triq id-Dghajjes', town: 'Msida'),
    Address(houseNameNo: '48', street: 'Triq il-Kullegg', town: 'Msida'),
  ];

  final List<Address> _tempDestinationAddresses = [
    Address(houseNameNo: '85', street: 'Triq l-isptar', town: 'Swatar'),
    Address(houseNameNo: '58', street: 'Triq il-Kontijiet', town: 'Valletta'),
    Address(houseNameNo: '48', street: 'Triq il-Flus', town: 'Msida'),
  ];

  List<Booking> get _tempBookings => [
    Booking(
      id: 0,
      name: 'Luke',
      surname: 'Farrugia',
      pickUpLocation: _tempPickUpAddresses[0],
      dropOffLocation: _tempDestinationAddresses[0],
      bookingTime: DateTime(2025, 3, 15, 15, 30),
      bookingStatus: BookingStatus.booked,
    ),

    Booking(
      id: 1,
      name: 'Rita',
      surname: 'Farrugia',
      pickUpLocation: _tempPickUpAddresses[1],
      dropOffLocation: _tempDestinationAddresses[1],
      bookingTime: DateTime(2025, 2, 15, 15, 30),
      bookingStatus: BookingStatus.completed,
    ),

    Booking(
      id: 2,
      name: 'Rita',
      surname: 'Farrugia',
      pickUpLocation: _tempPickUpAddresses[2],
      dropOffLocation: _tempDestinationAddresses[2],
      bookingTime: DateTime(2025, 1, 15, 15, 30),
      bookingStatus: BookingStatus.cancelled,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookings')),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(child: BookingsList(bookings: _tempBookings)),
          ],
        ),
      ),
    );
  }
}
