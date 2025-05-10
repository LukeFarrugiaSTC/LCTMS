import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/helpers/booking_sorter.dart';
import 'package:frontend/providers/bookings_provider.dart';
import 'package:frontend/providers/user_info_provider.dart';
//import 'package:frontend/providers/user_info_provider.dart';
import 'package:frontend/widgets/bookings/bookings_list.dart';

// Class displaying a read-only list of past (historical) bookings
class BookingHistoryPage extends ConsumerWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //const storage = FlutterSecureStorage();
    //final user = ref.watch(userInfoProvider);
    final roleID = 3;
    final bookings = ref.watch(bookingsProvider);
    final sorted = BookingSorter.sortBookings(
      bookings,
      roleID,
      ref.read(userInfoProvider).userID,
    );
    final historyBookings = sorted['history']!;

    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: BookingsList(
            bookings: historyBookings,
            onBookingTap: (context, booking) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Cannot change status of historical bookings."),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
