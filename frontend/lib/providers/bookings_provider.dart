import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/address.dart';
import 'package:frontend/models/booking.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/config/api_config.dart';

// Class managing booking data and sync with backend using Riverpod StateNotifier
class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super([]) {
    fetchBookings();
  }

  // Returns list of upcoming bookings
  List<Booking> get upcomingBookings =>
      state.where((b) => b.bookingTime.isAfter(DateTime.now())).toList();

  // Returns list of past bookings
  List<Booking> get historyBookings =>
      state.where((b) => b.bookingTime.isBefore(DateTime.now())).toList();

  // Resets bookings state and triggers re-fetch
  void resetBookings() {
    fetchBookings();
  }

  // Fetches bookings from backend API
  Future<void> fetchBookings() async {
    final String? apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Missing API Key');
    }

    final url = Uri.parse('$apiBaseUrl/endpoints/bookings/getAllBookings.php');
    final requestBody = {'api_key': apiKey};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final bookingsRaw = data['data'] as List;

          final parsedBookings =
              bookingsRaw.map<Booking>((json) {
                return Booking(
                  id:
                      json['booking_id'] != null
                          ? int.tryParse(json['booking_id'].toString())
                          : null,
                  userID:
                      json['clientId'] != null
                          ? int.tryParse(json['clientId'].toString())
                          : null,
                  name: json['userFirstname'] ?? '',
                  surname: json['userLastname'] ?? '',
                  bookingTime: DateTime.parse(json['bookingDate']),
                  bookingStatus: _parseStatus(json['bookingStatus']),
                  pickUpLocation: Address(
                    houseNameNo: json['userAddress'] ?? '',
                    street: json['streetName'] ?? '',
                    town: json['townName'] ?? '',
                  ),
                  dropOffLocation: json['destination_name'] ?? '',
                );
              }).toList();

          state = parsedBookings;
        } else {
          print('Server error: ${data['message']}');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      final singleLineError = e.toString().replaceAll('\n', ' ');
      print('Fetch error 1232: $singleLineError');
    }
  }

  // Helper to convert string status into enum
  BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'driver en route':
        return BookingStatus.driverEnRoute;
      case 'driver arrived':
        return BookingStatus.driverArrived;
      case 'client picked up':
        return BookingStatus.clientPickedUp;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'client no show':
        return BookingStatus.clientNoShow;
      case 'rejected':
        return BookingStatus.rejected;
      case 'failed':
        return BookingStatus.failed;
      default:
        return BookingStatus.failed; // fallback
    }
  }
}

// Provider used to access and interact with booking data
final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>(
  (ref) => BookingsNotifier(),
);
