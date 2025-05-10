import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';
import 'package:intl/intl.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetails> {
  late Booking booking;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    booking = ModalRoute.of(context)!.settings.arguments as Booking;
  }

  void updateStatus(BookingStatus? newStatus) {
    if (newStatus != null && newStatus != booking.bookingStatus) {
      setState(() {
        booking = booking.copyWith(bookingStatus: newStatus);
      });

      // TODO: Add your backend/API update call here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${newStatus.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = booking.pickUpLocation;
    final formattedTime = DateFormat(
      'EEE, MMM d • HH:mm',
    ).format(booking.bookingTime);
    final labelStyle = TextStyle(color: Colors.grey[600], fontSize: 14);
    final valueStyle = const TextStyle(fontSize: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${booking.name} ${booking.surname}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Text('Pickup Location', style: labelStyle),
            const SizedBox(height: 4),
            Text(
              '${pickup.houseNameNo}, ${pickup.street}, ${pickup.town}',
              style: valueStyle,
            ),

            const SizedBox(height: 16),
            Text('Drop-off Location', style: labelStyle),
            const SizedBox(height: 4),
            Text(booking.dropOffLocation, style: valueStyle),

            const SizedBox(height: 16),
            Text('Time', style: labelStyle),
            const SizedBox(height: 4),
            Text(formattedTime, style: valueStyle),

            const SizedBox(height: 28),
            Text('Booking Status', style: labelStyle),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BookingStatus>(
                  value: booking.bookingStatus,
                  isExpanded: true,
                  onChanged: updateStatus,
                  style: valueStyle,
                  items:
                      BookingStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
