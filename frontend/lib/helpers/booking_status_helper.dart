import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';

//extending on enum functions so that a predefined status and colour associated with that status is returned.
extension BookingStatusExtension on BookingStatus {
  String get bookingStatusValue {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.driverEnRoute:
        return 'Driver En Route';
      case BookingStatus.driverArrived:
        return 'Driver Arrived';
      case BookingStatus.clientPickedUp:
        return 'Client Picked Up';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.clientNoShow:
        return 'Client No Show';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.failed:
        return 'Failed';
    }
  }

  // Returns a specific color based on the booking status
  Color get bookingStatusColour {
    switch (this) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.driverEnRoute:
        return Colors.pinkAccent;
      case BookingStatus.driverArrived:
        return Colors.pink;
      case BookingStatus.clientPickedUp:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.clientNoShow:
        return Colors.brown;
      case BookingStatus.rejected:
        return Colors.black;
      case BookingStatus.failed:
        return Colors.black;
    }
  }
}

// Returns the list of statuses that the current role is allowed to update to
List<BookingStatus> getEditableStatusesForRole(int roleID) {
  switch (roleID) {
    case 1: // Driver
      return [
        BookingStatus.driverEnRoute,
        BookingStatus.driverArrived,
        BookingStatus.clientPickedUp,
        BookingStatus.completed,
        BookingStatus.clientNoShow,
      ]; // Drivers have limited control

    case 2: // Admin
      return BookingStatus.values; // Admins can access all statuses

    case 3: // User
      return [
        BookingStatus.pending,
        BookingStatus.cancelled,
      ]; // Users have limited control

    default:
      return [];
  }
}
