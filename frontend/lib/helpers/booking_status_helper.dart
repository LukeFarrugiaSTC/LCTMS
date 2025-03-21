import 'package:flutter/material.dart';
import 'package:frontend/models/booking.dart';

//extending on enum functions so that a predefined status and colour associated with that status is returned.
extension BookingStatusExtension on BookingStatus {
  String get bookingStatusValue {
    switch (this) {
      case BookingStatus.booked:
        return 'Booked';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  Color get bookingStatusColour {
    switch (this) {
      case BookingStatus.booked:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.inProgress:
        return Colors.orange;
      case BookingStatus.completed:
        return Colors.green;
    }
  }
}

// Returns the list of statuses that the current role is allowed to update to
List<BookingStatus> getEditableStatusesForRole(int roleID) {
  switch (roleID) {
    case 1: // Driver
      return [
        BookingStatus.booked,
        BookingStatus.inProgress,
        BookingStatus.completed,
      ];

    case 2: // Admin
      return BookingStatus.values;

    case 3: // User
      return [BookingStatus.booked, BookingStatus.cancelled];

    default:
      return [];
  }
}
