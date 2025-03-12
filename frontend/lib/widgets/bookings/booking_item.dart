import 'package:flutter/material.dart';
import 'package:frontend/helpers/booking_status_helper.dart';
import 'package:frontend/models/booking.dart';
import 'package:intl/intl.dart';

class BookingItem extends StatelessWidget {
  const BookingItem({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Date & Time: ${DateFormat('dd-MM-yyyy HH:mm').format(booking.bookingTime)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                ),

                Spacer(),
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: booking.bookingStatus.bookingStatusColour,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Name: ${booking.name} ${booking.surname}',
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            Text(
              'Pick Up: ${booking.pickUpLocation.houseNameNo}, ${booking.pickUpLocation.street}, ${booking.pickUpLocation.town}',
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            Text(
              'Drop Off: ${booking.dropOffLocation.houseNameNo}, ${booking.dropOffLocation.street}, ${booking.dropOffLocation.town}',
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            Text(
              'Status: ${booking.bookingStatus.bookingStatusValue}',
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
          ],
        ),
      ),
    );
  }
}
