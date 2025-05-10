import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/helpers/booking_sorter.dart';
import 'package:frontend/providers/bookings_provider.dart';
import 'package:frontend/providers/user_info_provider.dart';
import 'package:frontend/widgets/bookings/bookings_list.dart';

// Class displaying the list of upcoming bookings and allowing status updates
class UpcomingBookings extends ConsumerWidget {
  const UpcomingBookings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleID = ref.read(userInfoProvider).userRole;
    final bookings = ref.watch(bookingsProvider);
    final sorted = BookingSorter.sortBookings(
      bookings,
      roleID,
      ref.read(userInfoProvider).userID,
    );
    final upcomingBookings = sorted['upcoming']!;

    //final upcomingBookings = bookings; //TEMP

    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: BookingsList(
            bookings: upcomingBookings,
            onBookingTap: (context, booking) {
              Navigator.pushNamed(
                context,
                '/bookingDetails',
                arguments: booking,
              );
            },
          ),
        ),
      ],
    );
  }
}
