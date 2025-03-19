import 'package:frontend/models/booking.dart';
import 'package:frontend/models/user.dart';

class BookingSorter {
  static Map<String, List<Booking>> sortBookings(
    List<Booking> bookings,
    User user,
  ) {
    List<Booking> upcoming = [];
    List<Booking> history = [];

    switch (user.userRole) {
      case 1: // Driver role
      case 2: // Admin role
        for (var booking in bookings) {
          if (_isUpcomingBooking(booking) || _isOngoingBooking(booking)) {
            upcoming.add(booking);
          } else {
            history.add(booking);
          }
        }
        break;

      case 3: // User role
        for (var booking in bookings) {
          if (booking.userID != user.userID) {
            continue; //filter out bookings belonging to other users
          }
          if (_isUpcomingBooking(booking) || _isOngoingBooking(booking)) {
            upcoming.add(booking);
          } else {
            history.add(booking);
          }
        }
        break;

      default:
        return {'redirect': []};
    }

    // Reverse upcoming list so the next booking appears first
    upcoming = upcoming.reversed.toList();

    return {'upcoming': upcoming, 'history': history};
  }

  static bool _isUpcomingBooking(Booking booking) {
    return booking.bookingTime.isAfter(DateTime.now()) &&
        booking.bookingStatus != BookingStatus.completed;
  }

  static bool _isOngoingBooking(Booking booking) {
    final now = DateTime.now();
    return (booking.bookingTime.isBefore(now) &&
        booking.bookingTime.isAfter(now.subtract(Duration(hours: 2))) &&
        (booking.bookingStatus == BookingStatus.inProgress ||
            booking.bookingStatus == BookingStatus.booked));
  }
}
