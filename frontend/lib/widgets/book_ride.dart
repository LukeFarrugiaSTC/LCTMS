import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class BookRide extends StatefulWidget {
  const BookRide({super.key, this.showScaffold = true});
  final bool showScaffold;

  @override
  State<BookRide> createState() => _BookRideState();
}

class _BookRideState extends State<BookRide> {
  final _keyForm = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bookingDateController = TextEditingController();

  // For destinations (drop-off locations)
  List<String> _destinationsList = [];
  String _selectedDestination = '';
  String? _destinationError;

  bool _isBooked = false;
  final DateFormat dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _submitBooking() async {
    // Retrieve the token from secure storage
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      // Handle missing token, perhaps redirect to the login page
      setState(() {
        _destinationError = 'Authentication token not found. Please log in again.';
      });
      return;
    }

    // Convert the booking date from "dd/MM/yyyy HH:mm" to "yyyy-MM-dd HH:mm:ss"
    DateTime dateTime;
    try {
      final inputFormat = DateFormat('dd/MM/yyyy HH:mm');
      dateTime = inputFormat.parse(_bookingDateController.text);
    } catch (e) {
      setState(() {
        _destinationError = 'Invalid booking date format.';
      });
      return;
    }
    final outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = outputFormat.format(dateTime);

    final url = Uri.parse('$apiBaseUrl/endpoints/bookings/addBooking.php');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'destinationName': _selectedDestination,
        'bookingDateTime': formattedDate,
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

  /// Fetches the drop-off locations from the API.
  Future<void> _fetchDestinations() async {
    final url = Uri.parse('$apiBaseUrl/endpoints/locations/destinationList.php');
    
    // Get the API key from the .env file
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
        body: jsonEncode({
          'api_key': apiKey, // Use API key from the environment file
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> destinations;
        if (data is List) {
          destinations = data
              .map<String>((item) => item['destination_name'].toString())
              .toList();
        } else if (data is Map && data.containsKey('destinations')) {
          destinations = (data['destinations'] as List)
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

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(Duration(days: 2));
    final DateTime lastDate = now.add(Duration(days: 365));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );
    if (pickedTime == null) return;

    final DateTime combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _bookingDateController.text = dateTimeFormatter.format(combinedDateTime);
    });
  }

  bool _bookRide() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
      print("Name: ${_nameController.text}");
      print("Surname: ${_surnameController.text}");
      print("Email: ${_emailController.text}");
      print("Booking Date: ${_bookingDateController.text}");
      print("Destination: $_selectedDestination");
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
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: 25),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontSize: 30),
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
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bookingDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_month),
                    label: Text(
                      _bookingDateController.text.isEmpty
                          ? 'Select Date & Time'
                          : _bookingDateController.text,
                    ),
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  onTap: () => _selectDateTime(context),
                ),
                const SizedBox(height: 10),
                // Destination dropdown
                _destinationsList.isEmpty
                    ? _destinationError != null
                        ? Text(
                            _destinationError!,
                            style: const TextStyle(color: Colors.red),
                          )
                        : const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: _selectedDestination.isNotEmpty
                            ? _selectedDestination
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Select Destination',
                        ),
                        items: _destinationsList.map((String destination) {
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
                const SizedBox(height: 10),
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
                        child: const Text(
                          'Reset Booking',
                          textAlign: TextAlign.start,
                        ),
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

    //Only returns scaffold if this is accessed through the navbar
    return widget.showScaffold
        ? Scaffold(appBar: AppBar(title: Text('Book a Ride')), body: content)
        : content;
  }
}