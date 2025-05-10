import 'package:flutter/material.dart';
import 'package:frontend/helpers/booking_status_helper.dart';
import 'package:frontend/models/booking.dart';
import 'package:intl/intl.dart';

//Class defining the booking cards structure
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
            // Date & Status Row
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
            //Name and Surname
            Text(
              'Name: ${booking.name} ${booking.surname}',
              style: Theme.of(context).textTheme.bodyLarge!,
            ),

            //Pick Up Address
            Text(
              'Pick Up: ${booking.pickUpLocation.houseNameNo}, ${booking.pickUpLocation.street}, ${booking.pickUpLocation.town}',
              style: Theme.of(context).textTheme.bodyLarge!,
            ),

            //Drop Off Address
            Text(
              'Drop Off: ${booking.dropOffLocation}',
              style: Theme.of(context).textTheme.bodyLarge!,
            ),

            //Booking Status
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
