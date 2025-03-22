import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/address.dart';
import 'package:frontend/models/booking.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/config/api_config.dart';

// Class managing booking data and sync with backend using Riverpod StateNotifier
class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super([]) {
    fetchBookings();
  }

  // Updates the booking status for a specific booking ID
  void updateStatus(int bookingId, BookingStatus newStatus) {
    state =
        state.map((booking) {
          if (booking.id == bookingId) {
            return booking.copyWith(bookingStatus: newStatus);
          }
          return booking;
        }).toList();
  }

  // Returns list of upcoming bookings (future bookings)
  List<Booking> get upcomingBookings =>
      state.where((b) => b.bookingTime.isAfter(DateTime.now())).toList();

  // Returns list of past bookings (already occurred)
  List<Booking> get historyBookings =>
      state.where((b) => b.bookingTime.isBefore(DateTime.now())).toList();

  // Resets bookings state and triggers re-fetch
  void resetBookings() {
    fetchBookings();
  }

  // Fetches bookings from backend API using stored credentials
  Future<void> fetchBookings() async {
    try {
      const storage = FlutterSecureStorage();
      // Assuming you have the JWT token stored with key 'jwt'
      final String? jwt = await storage.read(key: 'jwt_token');
      if (jwt == null) {
        throw Exception('Missing JWT token');
      }

      // If you still need email or apiKey for other reasons, you can fetch them
      final String? email = await storage.read(key: 'email');
      final String? apiKey = dotenv.env['API_KEY'];
      if (email == null || apiKey == null) {
        throw Exception('Missing credentials');
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/endpoints/bookings/getUsersBookings.php'),
        headers: {
          'Content-Type': 'application/json',
          // Include the JWT token in the Authorization header
          'Authorization': 'Bearer $jwt',
        },
        // Optionally, if your endpoint does not need a JSON body (since JWT is used), you could remove it.
        body: jsonEncode({'email': email, 'api_key': apiKey}),
      );

      final responseBody = response.body;
      final pattern = RegExp('.{1,800}'); // Adjust chunk size as needed
      pattern.allMatches(responseBody).forEach((match) {
        print(match.group(0));
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final bookingsRaw = data['bookings'] as List;

          // Adjust parsing to match PHP response keys:
          final parsedBookings =
              (bookingsRaw).map<Booking>((json) {
                return Booking(
                  id:
                      json['booking_id'] != null
                          ? int.tryParse(json['booking_id'].toString())
                          : null,
                  userID: int.parse(json['userId'].toString()),
                  name: json['name'] ?? '',
                  surname: json['surname'] ?? '',
                  bookingTime: DateTime.parse(json['bookingDate']),
                  bookingStatus: _parseStatus(json['bookingStatus']),
                  pickUpLocation: Address(
                    houseNameNo: json['pickupHouse'] ?? '',
                    street: json['pickupStreet'] ?? '',
                    town: json['pickupTown'] ?? '',
                  ),
                  dropOffLocation: Address(
                    houseNameNo:
                        '', // If there's no house number for drop-off, use an empty string.
                    street: json['dropoffStreet'] ?? '',
                    town: json['dropoffTown'] ?? '',
                  ),
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

  // Converts status string from backend into enum value
  BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.booked;
    }
  }
}

// Provider used to access and interact with booking data
final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>(
  (ref) => BookingsNotifier(),
);
