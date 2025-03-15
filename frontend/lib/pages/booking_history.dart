import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/widgets/bookings/bookings_list.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key, required List<Booking>? tempBookings})
    : tempBookings = tempBookings ?? const [];

  final List<Booking> tempBookings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          Expanded(child: BookingsList(bookings: tempBookings)),
        ],
      ),
    );
  }
}
