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
        isOngoingStatus(booking);
  }

  // Determines if a booking is currently ongoing (within the last 2 hours)
  static bool _isOngoingBooking(Booking booking) {
    final now = DateTime.now();
    return (booking.bookingTime.isBefore(now) &&
        booking.bookingTime.isAfter(now.subtract(Duration(hours: 2))) &&
        isOngoingStatus(booking));
  }

  //if the status of the booking is suitable for the ongoing bookings, these will return true
  static bool isOngoingStatus(Booking booking) {
    switch (booking.bookingStatus) {
      case BookingStatus.pending:
        return true;
      case BookingStatus.confirmed:
        return true;
      case BookingStatus.driverEnRoute:
        return true;
      case BookingStatus.driverArrived:
        return true;
      case BookingStatus.clientPickedUp:
        return true;
      case BookingStatus.cancelled:
        print('I am here');
        return true;
      default:
        return false;
    }
  }
}
