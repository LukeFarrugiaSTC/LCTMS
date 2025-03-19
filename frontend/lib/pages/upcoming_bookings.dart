import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/widgets/bookings/bookings_list.dart';

class UpcomingBookingsPage extends StatelessWidget {
  const UpcomingBookingsPage({
    super.key,
    required this.tempBookings,
    required this.onBookingTap,
  });

  final List<Booking> tempBookings;
  final Function(BuildContext, Booking) onBookingTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: BookingsList(
              bookings: tempBookings,
              onBookingTap: onBookingTap,
            ),
          ),
        ],
      ),
    );
  }
}
