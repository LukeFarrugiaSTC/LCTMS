import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/widgets/bookings/booking_item.dart';

//Class defining the list structure of the cards inside view bookings page
class BookingsList extends StatelessWidget {
  const BookingsList({
    super.key,
    required this.bookings,
    required this.onBookingTap,
  });

  final List<Booking> bookings;
  final Function(BuildContext, Booking)
  onBookingTap; // Callback when a booking is tapped

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder:
          (ctx, index) => GestureDetector(
            onTap: () {
              onBookingTap(context, bookings[index]);
            },
            child: BookingItem(
              booking: bookings[index],
            ), // Custom widget for each bookings
          ),
    );
  }
}
