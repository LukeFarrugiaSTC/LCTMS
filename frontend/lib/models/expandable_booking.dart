import 'package:frontend/models/booking.dart';

class ExpandableBooking {
  Booking booking;
  bool isExpanded;

  ExpandableBooking({required this.booking, this.isExpanded = false});
}
