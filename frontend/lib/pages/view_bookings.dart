import 'package:flutter/material.dart';
import 'package:frontend/pages/booking_history.dart';
import 'package:frontend/pages/upcoming_bookings.dart';

class ViewBookingsPage extends StatefulWidget {
  const ViewBookingsPage({super.key});

  @override
  State<ViewBookingsPage> createState() => _ViewBookingsPageState();
}

class _ViewBookingsPageState extends State<ViewBookingsPage> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const UpcomingBookingsPage();
    String activePageTitle = 'Upcoming Bookings';

    if (_selectedPageIndex == 1) {
      activePage = const BookingHistoryPage();
      activePageTitle = 'Booking History';
    }

    return Scaffold(
      appBar: AppBar(title: Text(activePageTitle)),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          _selectPage(index);
        },
        items: [
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
