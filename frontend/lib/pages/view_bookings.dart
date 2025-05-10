import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/pages/booking_history.dart';
import 'package:frontend/pages/upcoming_bookings.dart';
import 'package:frontend/providers/bookings_provider.dart';

// Class defining the view for toggling between upcoming and historical bookings
class ViewBookingsPage extends ConsumerStatefulWidget {
  const ViewBookingsPage({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  ConsumerState<ViewBookingsPage> createState() => _ViewBookingsPageState();
}

class _ViewBookingsPageState extends ConsumerState<ViewBookingsPage> {
  int _selectedPageIndex = 0;
  double _rotationAngle = 0.0;

  // Handles switching between upcoming and history tabs
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  // Triggers rotation animation and refreshes the bookings list
  Future<void> _rotateIcon() async {
    // Start rotation
    setState(() {
      _rotationAngle += 1.0;
    });

    // Optional delay to let the animation play
    await Future.delayed(const Duration(milliseconds: 300));

    // Refresh bookings
    ref.read(bookingsProvider.notifier).resetBookings();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [const UpcomingBookings(), const BookingHistoryPage()];
    final titles = ['Bookings', 'Booking History'];
    final Widget content = pages[_selectedPageIndex];

    return Scaffold(
      appBar:
          widget.showScaffold
              ? AppBar(
                //shows app bar only if in user / admin role
                title: Text(titles[_selectedPageIndex]),
                actions: [
                  IconButton(
                    onPressed: _rotateIcon,
                    icon: AnimatedRotation(
                      turns: _rotationAngle,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                ],
              )
              : null,
      body: content,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Upcoming Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Booking History',
          ),
        ],
      ),
    );
  }
}
