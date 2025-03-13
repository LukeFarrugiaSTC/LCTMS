import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/address.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/booking_history.dart';
import 'package:frontend/pages/upcoming_bookings.dart';
import 'package:frontend/providers/user_info_provider.dart';
import 'package:frontend/helpers/booking_sorter.dart';

class ViewBookingsPage extends ConsumerStatefulWidget {
  ViewBookingsPage({super.key});

  //Dummy list to be removed once we have the API set
  final List<Address> _tempPickUpAddresses = [
    Address(houseNameNo: '12', street: 'Triq id-Dwieli', town: 'Msida'),
    Address(houseNameNo: '24', street: 'Triq id-Dghajjes', town: 'Msida'),
    Address(houseNameNo: '48', street: 'Triq il-Kullegg', town: 'Msida'),
    Address(houseNameNo: '32, Maria', street: 'Triq l-Isqof', town: 'Msida'),
    Address(houseNameNo: '45', street: 'Triq il-Marina', town: 'Msida'),
    Address(houseNameNo: '31', street: 'Triq il-Qasam', town: 'Msida'),
  ];
  //Dummy list to be removed once we have the API set
  final List<Address> _tempDestinationAddresses = [
    Address(houseNameNo: '85', street: 'Triq l-isptar', town: 'Swatar'),
    Address(houseNameNo: '58', street: 'Triq il-Kontijiet', town: 'Valletta'),
    Address(houseNameNo: '48', street: 'Triq il-Flus', town: 'Msida'),
    Address(
      houseNameNo: '7, Junior College',
      street: 'Triq il-Kullegg',
      town: 'Msida',
    ),
  ];

  //Dummy list to be removed once we have the API set
  List<Booking> get _tempBookings => [
    Booking(
      id: 0,
      userID: 0,
      name: 'Grace',
      surname: 'Tanti',
      pickUpLocation: _tempPickUpAddresses[0],
      dropOffLocation: _tempDestinationAddresses[1],
      bookingTime: DateTime(2025, 4, 15, 15, 30),
      bookingStatus: BookingStatus.booked,
    ),

    Booking(
      id: 1,
      userID: 0,
      name: 'Charles',
      surname: 'Mifsud Bonnici',
      pickUpLocation: _tempPickUpAddresses[1],
      dropOffLocation: _tempDestinationAddresses[3],
      bookingTime: DateTime(2025, 2, 13, 07, 00),
      bookingStatus: BookingStatus.inProgress,
    ),

    Booking(
      id: 2,
      userID: 0,
      name: 'Maria',
      surname: 'Grech',
      pickUpLocation: _tempPickUpAddresses[2],
      dropOffLocation: _tempDestinationAddresses[3],
      bookingTime: DateTime(2025, 3, 9, 12, 30),
      bookingStatus: BookingStatus.cancelled,
    ),

    Booking(
      id: 3,
      userID: 0,
      name: 'Andrea',
      surname: 'Deguara',
      pickUpLocation: _tempPickUpAddresses[3],
      dropOffLocation: _tempDestinationAddresses[0],
      bookingTime: DateTime(2025, 2, 18, 10, 00),
      bookingStatus: BookingStatus.completed,
    ),

    Booking(
      id: 4,
      userID: 1,
      name: 'Moira',
      surname: 'Buhagiar',
      pickUpLocation: _tempPickUpAddresses[4],
      dropOffLocation: _tempDestinationAddresses[1],
      bookingTime: DateTime(2025, 1, 25, 09, 30),
      bookingStatus: BookingStatus.completed,
    ),

    Booking(
      id: 5,
      userID: 2,
      name: 'Kola',
      surname: 'Farrugia',
      pickUpLocation: _tempPickUpAddresses[5],
      dropOffLocation: _tempDestinationAddresses[2],
      bookingTime: DateTime(2025, 1, 15, 15, 30),
      bookingStatus: BookingStatus.cancelled,
    ),
  ];

  @override
  ConsumerState<ViewBookingsPage> createState() {
    return _ViewBookingsPageState();
  }
}

class _ViewBookingsPageState extends ConsumerState<ViewBookingsPage> {
  int _selectedPageIndex = 0;
  double _rotationAngle = 0.0;

  //Lists that contain filtered bookings according to future or past date
  List<Booking> _upcomingBookingsList = [];
  List<Booking> _bookingsHistoryList = [];
  late final User user;
  //initialises before the widget build only one time, when the page is entered
  @override
  void initState() {
    user = ref.read(userInfoProvider);
    extractBookingsLists();
    super.initState();
  }

  void extractBookingsLists() {
    Map<String, List<Booking>> sortedBookings = BookingSorter.sortBookings(
      widget._tempBookings,
      user,
    );
    _upcomingBookingsList = sortedBookings['upcoming'] ?? [];
    _bookingsHistoryList = sortedBookings['history'] ?? [];
  }

  // Function to refresh bookings with rotation animation
  Future<void> _sortAndRefresh() async {
    // Start animation
    setState(() {
      _rotationAngle += 1.0; // Rotate icon by 1 full turn
    });

    // Records the time taken to sort the booking list
    final startTime = DateTime.now();

    // Perform sorting of bookings
    extractBookingsLists();

    // Calculate sorting duration
    final sortingDuration = DateTime.now().difference(startTime);

    // Ensure animation lasts at least 300ms
    final minDuration = Duration(milliseconds: 300);
    final adjustedDuration =
        sortingDuration < minDuration ? minDuration : sortingDuration;

    await Future.delayed(adjustedDuration);

    //stops animation, but icon keeps turning until it completes the turn
    //mounted so that if a user changes screen while animation is occuring, set state does not try to change a no longer existing widget.
    if (mounted) {
      setState(() {});
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = UpcomingBookingsPage(
      tempBookings: _upcomingBookingsList,
    );
    String activePageTitle = 'Bookings';

    if (_selectedPageIndex == 1) {
      activePage = BookingHistoryPage(tempBookings: _bookingsHistoryList);
      activePageTitle = 'Booking History';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
        actions: [
          IconButton(
            //calls widgetSorter to refresh the screen
            onPressed: _sortAndRefresh,

            icon: AnimatedRotation(
              turns: _rotationAngle, // Rotates smoothly when state changes
              duration: const Duration(
                milliseconds: 300,
              ), //controls the time the animation takes to complete a full turn animation
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
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

// //Sorts bookings to different lists to be used in different pages
// void _sortBookingList() {
//   List<Booking> upcoming = [];
//   List<Booking> history = [];

//   // Create temporary lists before updating state according to the role of the user

//   switch (user.userRole) {
//     //Driver role
//     case 1:
//     //Admin role
//     case 2:
//       for (var booking in widget._tempBookings) {
//         bool isUpcoming =
//             booking.bookingTime.isAfter(DateTime.now()) &&
//             booking.bookingStatus != BookingStatus.completed;

//         //true if booking is within the past 2 hours and status is in progress or booked
//         //Allows leeway in case the booking time is in the past but the job is still being done.  Currently set for 2hrs
//         bool isOngoing =
//             booking.bookingTime.isBefore(
//               DateTime.now().subtract(Duration(hours: 2)),
//             ) &&
//             (booking.bookingStatus == BookingStatus.inProgress ||
//                 booking.bookingStatus == BookingStatus.booked);
//         if (isUpcoming || isOngoing) {
//           upcoming.add(booking);
//         } else {
//           history.add(booking);
//         }
//       }
//       break;
//     //User role
//     case 3:
//       for (var booking in widget._tempBookings) {
//         if (booking.userID != user.userID) {
//           continue;
//         }

//         //true if booking is in the future or is not completed yet
//         bool isUpcoming =
//             booking.bookingTime.isAfter(DateTime.now()) &&
//             booking.bookingStatus != BookingStatus.completed;

//         //true if booking is within the past 2 hours and status is in progress or booked
//         bool isOngoing =
//             booking.bookingTime.isBefore(
//               DateTime.now().subtract(Duration(hours: 2)),
//             ) &&
//             (booking.bookingStatus == BookingStatus.inProgress ||
//                 booking.bookingStatus == BookingStatus.booked);

//         if (isUpcoming || isOngoing) {
//           upcoming.add(booking);
//         } else {
//           history.add(booking);
//         }
//       }
//       break;
//     default:
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         '/login',
//         (Route<dynamic> route) => false,
//       );
//   }

//   //Reverses the order of Upcoming list so that the user sees the next booking
//   upcoming = upcoming.reversed.toList();

//   //Updates UI with new lists
//   setState(() {
//     _upcomingBookingsList = upcoming;
//     _bookingsHistoryList = history;
//   });
// }
