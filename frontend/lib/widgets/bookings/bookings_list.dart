import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/widgets/bookings/booking_item.dart';

class BookingsList extends StatelessWidget {
  const BookingsList({super.key, required this.bookings});

  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (ctx, index) => BookingItem(booking: bookings[index]),
    );
  }
}
