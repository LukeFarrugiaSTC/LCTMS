import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/providers/user_info_provider.dart';

class BookRideV2 extends ConsumerStatefulWidget {
  const BookRideV2({super.key, this.showScaffold = true});
  final bool showScaffold;

  @override
  ConsumerState<BookRideV2> createState() => _BookRideState();
}

class _BookRideState extends ConsumerState<BookRideV2> {
  final _keyForm = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bookingDateController = TextEditingController();

  List<String> _destinationsList = [];
  String _selectedDestination = '';
  String? _destinationError;

  final List<String> _timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];
  String? _selectedTime;

  bool _isBooked = false;
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    final url = Uri.parse(
      '$apiBaseUrl/endpoints/locations/destinationList.php',
    );
    final String? apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _destinationError = 'API key is missing in .env file.';
      });
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': apiKey}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> destinations;
        if (data is List) {
          destinations =
              data
                  .map<String>((item) => item['destination_name'].toString())
                  .toList();
        } else if (data is Map && data.containsKey('destinations')) {
          destinations =
              (data['destinations'] as List)
                  .map<String>((item) => item['destination_name'].toString())
                  .toList();
        } else {
          throw Exception('Unexpected response format for destinations');
        }
        setState(() {
          _destinationsList = destinations;
          _selectedDestination = destinations.isNotEmpty ? destinations[0] : '';
        });
      } else {
        setState(() {
          _destinationError = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _destinationError = 'An error occurred: $e';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(Duration(days: 2));
    final DateTime lastDate = now.add(Duration(days: 365));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        _bookingDateController.text = dateFormatter.format(pickedDate);
        _selectedTime = null;
      });
    }
  }

  Future<void> _submitBooking() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      setState(() {
        _destinationError =
            'Authentication token not found. Please log in again.';
      });
      return;
    }

    DateTime dateTime;

    try {
      final inputFormat = DateFormat('dd/MM/yyyy HH:mm');
      dateTime = inputFormat.parse(
        '${_bookingDateController.text} ${_selectedTime ?? '00:00'}',
      );
    } catch (e) {
      setState(() {
        _destinationError = 'Invalid booking date or time format.';
      });
      return;
    }

    final outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = outputFormat.format(dateTime);

    final url = Uri.parse('$apiBaseUrl/endpoints/bookings/addBookingR2.php');
    print('API Key: ${dotenv.env['API_KEY']}');
    print('Selected destination: $_selectedDestination');
    print('Selected date: ${_bookingDateController.text}');
    print('Selected time: $_selectedTime');
    print('Formatted booking datetime: $formattedDate');
    print('User ID: ${ref.read(userInfoProvider).userID}');
    print('client ID: ${ref.read(userInfoProvider).email}');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'api_key': dotenv.env['API_KEY'],
        'destinationName': _selectedDestination,
        'bookingDateTime': formattedDate,
        'userID': ref.read(userInfoProvider).userID,
        'clientID': ref.read(userInfoProvider).email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _isBooked = true;
        });
      } else {
        setState(() {
          _destinationError = data['message'] ?? 'Booking failed.';
        });
      }
    } else {
      setState(() {
        _destinationError = 'Error: ${response.statusCode}. Please try again.';
      });
    }
  }

  bool _bookRide() {
    if (_keyForm.currentState!.validate()) {
      if (_bookingDateController.text.isEmpty) {
        setState(() {
          _destinationError = 'Please select a booking date.';
        });
        return false;
      }
      if (_selectedTime == null || _selectedTime!.isEmpty) {
        setState(() {
          _destinationError = 'Please select a booking time.';
        });
        return false;
      }
      _keyForm.currentState!.save();
      return true;
    }
    return false;
  }

  void _resetForm() {
    _nameController.clear();
    _surnameController.clear();
    _emailController.clear();
    _bookingDateController.clear();
    setState(() {
      _selectedDestination =
          _destinationsList.isNotEmpty ? _destinationsList[0] : '';
      _selectedTime = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _bookingDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientEmail;
    if (ref.read(userInfoProvider).userRole == 3) {
      clientEmail = ref.read(userInfoProvider).email;
    } else {
      //Input code for when the admin cna create an order for a user.
      clientEmail =
          "test@example1.com"; //To be removed once functionality is implemented
    }

    _emailController.text =
        clientEmail; //Email field is disabled and filled according to the clientEmail set

    Widget content;
    if (_isBooked) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 120),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your booking is confirmed!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isBooked = false;
                    _resetForm();
                  });
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    } else {
      content = SingleChildScrollView(
        child: Form(
          key: _keyForm,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Booking Form',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Name',
                  controller: _nameController,
                  textFieldType: TextFieldType.textRequired,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  labelText: 'Surname',
                  controller: _surnameController,
                  textFieldType: TextFieldType.textRequired,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  labelText: 'Email Address',
                  controller: _emailController,
                  textFieldType: TextFieldType.email,
                  textCapitalization: TextCapitalization.none,
                  enabled: false,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bookingDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_month),
                    labelText: 'Select Date',
                    border: const OutlineInputBorder(),
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedTime,
                  decoration: const InputDecoration(labelText: 'Select Time'),
                  items:
                      _timeSlots.map((String time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                  onChanged:
                      _bookingDateController.text.isEmpty
                          ? null
                          : (value) {
                            setState(() {
                              _selectedTime = value;
                            });
                          },
                  validator: (value) {
                    if (_bookingDateController.text.isNotEmpty &&
                        (value == null || value.isEmpty)) {
                      return 'Please select a time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _destinationsList.isEmpty
                    ? _destinationError != null
                        ? Text(
                          _destinationError!,
                          style: const TextStyle(color: Colors.red),
                        )
                        : const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                      value:
                          _selectedDestination.isNotEmpty
                              ? _selectedDestination
                              : null,
                      decoration: const InputDecoration(
                        labelText: 'Select Destination',
                      ),
                      items:
                          _destinationsList.map((String destination) {
                            return DropdownMenuItem<String>(
                              value: destination,
                              child: Text(destination),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDestination = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a destination';
                        }
                        return null;
                      },
                    ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_bookRide()) {
                            await _submitBooking();
                          }
                        },
                        child: const Text('Submit Booking'),
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: _resetForm,
                        style: TextButton.styleFrom(
                          fixedSize: const Size(300, 40),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Reset Booking'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.showScaffold
        ? Scaffold(
          appBar: AppBar(title: const Text('Book a Ride')),
          body: content,
        )
        : content;
  }
}
