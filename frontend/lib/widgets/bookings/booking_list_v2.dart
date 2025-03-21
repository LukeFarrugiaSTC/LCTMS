import 'package:flutter/material.dart';
import 'package:frontend/helpers/booking_status_helper.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/models/expandable_booking.dart';
import 'package:frontend/widgets/bookings/booking_item_v2.dart';
import 'package:intl/intl.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<ExpandableBooking> bookings = [];

  Future<void> _updateStatus(int index, BookingStatus newStatus) async {
    // Simulate an API call delay
    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      final updated = bookings[index].booking.copyWith(
        bookingStatus: newStatus,
      );
      bookings[index] = ExpandableBooking(booking: updated, isExpanded: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            setState(() {
              bookings[index].isExpanded = !isExpanded;
            });
          },
          children:
              bookings.asMap().entries.map((entry) {
                final index = entry.key;
                final expandable = entry.value;
                final booking = expandable.booking;

                return ExpansionPanel(
                  isExpanded: expandable.isExpanded,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text(
                        DateFormat.yMMMd().format(booking.bookingTime),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: booking.bookingStatus.bookingStatusColour,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          booking.bookingStatus.bookingStatusValue,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  body: BookingItemV2(
                    booking: booking,
                    onStatusChanged:
                        (newStatus) => _updateStatus(index, newStatus),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
