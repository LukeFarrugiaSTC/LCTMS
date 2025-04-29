import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/helpers/booking_sorter.dart';
import 'package:frontend/helpers/booking_status_helper.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/providers/bookings_provider.dart';
import 'package:frontend/widgets/bookings/bookings_list.dart';

// Class displaying the list of upcoming bookings and allowing status updates
class UpcomingBookingsPage extends ConsumerWidget {
  const UpcomingBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //const storage = FlutterSecureStorage();
    //final user = storage.read(key: 'userID');
    //final roleID = int.parse(storage.read(key: 'roleId').toString());
    final roleID = 3;
    final bookings = ref.watch(bookingsProvider);
    final sorted = BookingSorter.sortBookings(bookings, roleID);
    final upcomingBookings = sorted['upcoming']!;

    //final upcomingBookings = bookings; //TEMP

    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: BookingsList(
            bookings: upcomingBookings,
            onBookingTap: (context, booking) {
              _showStatusChangeSheet(context, booking, ref, roleID);
            },
          ),
        ),
      ],
    );
  }

  void _showStatusChangeSheet(
    BuildContext context,
    Booking booking,
    WidgetRef ref,
    int roleID,
  ) {
    final editableStatuses = getEditableStatusesForRole(roleID);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Change Booking Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...editableStatuses.map((status) {
                return ListTile(
                  title: Text(status.bookingStatusValue),
                  onTap: () {
                    ref
                        .read(bookingsProvider.notifier)
                        .updateStatus(booking.id!, status);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
