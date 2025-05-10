import 'package:frontend/models/booking.dart';

// Sorts bookings into 'upcoming' and 'history' based on booking time and role
class BookingSorter {
  static Map<String, List<Booking>> sortBookings(
    List<Booking> bookings,
    int roleID,
    int userId,
  ) {
    List<Booking> upcoming = [];
    List<Booking> history = [];
    switch (roleID) {
      case 1: // Admin role
      case 2: // Driver role
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
          if (booking.userID != userId) {
            //this list is filtered from backend
            continue; //filter out bookings belonging to other users
          }
          if (_isUpcomingBooking(booking) || _isOngoingBooking(booking)) {
            upcoming.add(booking);
          } else {
            history.add(booking);
          }
        }
      default:
        return {'redirect': []};
    }

    return {'upcoming': upcoming, 'history': history.reversed.toList()};
  }

  // Determines if a booking is scheduled for the future and not completed
  static bool _isUpcomingBooking(Booking booking) {
    return booking.bookingTime.isAfter(DateTime.now()) &&
        booking.bookingStatus != BookingStatus.completed;
  }

  // Determines if a booking is currently ongoing (within the last 2 hours)
  static bool _isOngoingBooking(Booking booking) {
    final now = DateTime.now();
    return (booking.bookingTime.isBefore(now) &&
        booking.bookingTime.isAfter(now.subtract(Duration(hours: 2))) &&
        (booking.bookingStatus == BookingStatus.inProgress ||
            booking.bookingStatus == BookingStatus.booked));
  }
}
