import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/widgets/bookings/booking_item.dart';

class BookingsList extends StatelessWidget {
  const BookingsList({
    super.key,
    required this.bookings,
    required this.onBookingTap,
  });

  final List<Booking> bookings;
  final Function(BuildContext, Booking) onBookingTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder:
          (ctx, index) => GestureDetector(
            onTap: () {
              onBookingTap(context, bookings[index]);
            },
            child: BookingItem(booking: bookings[index]),
          ),
    );
  }
}
