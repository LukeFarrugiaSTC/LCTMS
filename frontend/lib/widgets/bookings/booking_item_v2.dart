import 'package:flutter/material.dart';
import 'package:frontend/helpers/booking_status_helper.dart';
import 'package:frontend/models/booking.dart';

class BookingItemV2 extends StatelessWidget {
  const BookingItemV2({
    super.key,
    required this.booking,
    required this.onStatusChanged,
  });
  final Booking booking;

  final ValueChanged<BookingStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(title: Text("Name: ${booking.name} ${booking.surname}")),
        ListTile(title: Text("Pickup: ${booking.pickUpLocation.street}")),
        ListTile(title: Text("Drop-off: ${booking.dropOffLocation.street}")),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<BookingStatus>(
            value: booking.bookingStatus,
            items:
                BookingStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.bookingStatusValue),
                  );
                }).toList(),
            onChanged: (newStatus) {
              if (newStatus != null) {
                onStatusChanged(newStatus);
              }
            },
          ),
        ),
      ],
    );
  }
}
