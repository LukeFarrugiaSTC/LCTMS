import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/address.dart';
import 'package:frontend/models/booking.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/config/api_config.dart';

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super([]) {
    fetchBookings();
  }

  void updateStatus(int bookingId, BookingStatus newStatus) {
    state =
        state.map((booking) {
          if (booking.id == bookingId) {
            return booking.copyWith(bookingStatus: newStatus);
          }
          return booking;
        }).toList();
  }

  List<Booking> get upcomingBookings =>
      state.where((b) => b.bookingTime.isAfter(DateTime.now())).toList();

  List<Booking> get historyBookings =>
      state.where((b) => b.bookingTime.isBefore(DateTime.now())).toList();

  //resets state so that refresh button works
  void resetBookings() {
    fetchBookings();
  }

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final bookingsRaw = data['bookings'] as List;

          // Adjust parsing to match PHP response keys:
          final parsedBookings =
              bookingsRaw.map((json) {
                return Booking(
                  // PHP returns 'id' instead of 'bookingID'
                  id: int.tryParse(json['id'].toString()),
                  // If userId is not returned by PHP, you might have to assign it elsewhere
                  userID: 0,
                  // PHP returns destinationName. Adapt as needed.
                  name: json['destinationName'] ?? '',
                  surname: '',
                  // PHP returns bookingDateTime instead of bookingTime
                  bookingTime: DateTime.parse(json['bookingDateTime']),
                  bookingStatus: _parseStatus(json['status']),
                  // PHP response doesn’t include address details; adjust or remove these as needed.
                  pickUpLocation: Address(
                    houseNameNo: '',
                    street: '',
                    town: '',
                  ),
                  dropOffLocation: Address(
                    houseNameNo: '',
                    street: '',
                    town: '',
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
      print('Fetch error: $singleLineError');
    }
  }

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

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>(
  (ref) => BookingsNotifier(),
);
