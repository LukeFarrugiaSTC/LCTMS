import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/helpers/booking_status_helper.dart';
import 'package:frontend/providers/bookings_provider.dart';
import 'package:frontend/providers/user_info_provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetails extends ConsumerStatefulWidget {
  const BookingDetails({super.key});

  @override
  ConsumerState<BookingDetails> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends ConsumerState<BookingDetails> {
  Booking? _booking;
  BookingStatus? _currentStatus;

  @override
  void initState() {
    super.initState();

    // Wait until the widget is built before accessing context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingArg = ModalRoute.of(context)?.settings.arguments as Booking?;
      if (bookingArg != null) {
        setState(() {
          _booking = bookingArg;
          _currentStatus = bookingArg.bookingStatus;
        });
      }
    });
  }

  void updateStatus(BookingStatus? newStatus) async {
    final roleID = ref.read(userInfoProvider).userRole;
    final userID = ref.read(userInfoProvider).userID;

    if (newStatus != null &&
        newStatus != _currentStatus &&
        getEditableStatusesForRole(roleID).contains(newStatus)) {
      setState(() {
        _currentStatus = newStatus;
        _booking = _booking!.copyWith(bookingStatus: newStatus);
      });

      const storage = FlutterSecureStorage();
      final jwtToken = await storage.read(key: 'jwt_token');

      if (jwtToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authorization token not found.')),
        );
        return;
      }

      final url = Uri.parse(
        '$apiBaseUrl/endpoints/bookings/updateBookingStatus.php',
      );

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwtToken',
          },
          body: jsonEncode({
            'bookingId': _booking!.id,
            'bookingStatus': newStatus.bookingStatusValue.toLowerCase(),
            'userId': userID,
          }),
        );

        print('Raw response body: ${response.body}');

        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              ref.read(bookingsProvider.notifier).resetBookings();
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Status updated to ${newStatus.bookingStatusValue}',
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Update failed: ${data['message'] ?? 'Unknown error'}',
                  ),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Server returned invalid response.'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update. Status: ${response.statusCode}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error connecting to server: $e')),
        );
      }
    }
  }

  void _openGoogleMapsForPickup() async {
    final pickup = _booking!.pickUpLocation;
    final query = Uri.encodeComponent('${pickup.street}, ${pickup.town}');
    final googleMapsUrl =
        'google.navigation:q=$query&mode=d'; // 'd' = driving mode

    final uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_booking == null || _currentStatus == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final roleID = ref.watch(userInfoProvider).userRole;
    final editableStatuses = getEditableStatusesForRole(roleID);
    final allowedToEdit = editableStatuses.contains(_currentStatus);
    final dropdownItems = allowedToEdit ? editableStatuses : [_currentStatus!];

    final pickup = _booking!.pickUpLocation;
    final formattedTime = DateFormat(
      'EEE, MMM d • HH:mm',
    ).format(_booking!.bookingTime);
    final labelStyle = TextStyle(color: Colors.grey[600], fontSize: 14);
    final valueStyle = const TextStyle(fontSize: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${_booking!.name} ${_booking!.surname}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Spacer(),
                if (roleID == 2)
                  IconButton(
                    onPressed: _openGoogleMapsForPickup,
                    icon: Icon(Icons.location_on, color: Colors.black),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            Text('Pickup Location', style: labelStyle),
            const SizedBox(height: 4),
            Text(
              '${pickup.houseNameNo}, ${pickup.street}, ${pickup.town}',
              style: valueStyle,
            ),

            const SizedBox(height: 16),
            Text('Drop-off Location', style: labelStyle),
            const SizedBox(height: 4),
            Text(_booking!.dropOffLocation, style: valueStyle),

            const SizedBox(height: 16),
            Text('Time', style: labelStyle),
            const SizedBox(height: 4),
            Text(formattedTime, style: valueStyle),

            const SizedBox(height: 28),
            Text('Booking Status', style: labelStyle),
            const SizedBox(height: 8),

            AbsorbPointer(
              absorbing: !allowedToEdit,
              child: Opacity(
                opacity: allowedToEdit ? 1.0 : 0.6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BookingStatus>(
                      value: _currentStatus,
                      isExpanded: true,
                      onChanged: allowedToEdit ? updateStatus : null,
                      style: valueStyle,
                      dropdownColor: Colors.white,
                      items:
                          dropdownItems.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status.bookingStatusValue,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
