import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:frontend/config/api_config.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;   // For showing a spinner until profile data is loaded
  bool _isEditing = false;  // Toggles read-only vs. editable mode

  final _keyForm = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // If you need password fields for an "edit password" feature, keep them. Otherwise remove.
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Town / Street
  String? _town;
  List<String> _streetList = [];
  String? _street; // Must be nullable to avoid invalid default

  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  /// Fetch the user’s profile from your server.
  Future<void> _fetchUserProfile() async {
    try {
      final String? apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('API_KEY not found in .env file');
        setState(() => _isLoading = false);
        return;
      }

      // Example endpoint. Change to match your actual "getProfile" route
      final url = Uri.parse('$apiBaseUrl/endpoints/user/profileRead.php');

      const storage = FlutterSecureStorage();
      final String? userEmail = await storage.read(key: 'email');

      // Possibly pass user ID, token, or email in request body
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_key': apiKey,
          'email': userEmail
        }),
      );

      debugPrint('Profile fetch status: ${response.statusCode}');
      debugPrint('Profile fetch body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final messageObj = data['message'];

        // Parse out the fields (adjust keys to match your actual JSON)
        _nameController.text = messageObj['userFirstname'] ?? '';
        _surnameController.text = messageObj['userLastname'] ?? '';
        _dobController.text = messageObj['userDob'] ?? '';
        _houseNumberController.text = messageObj['userAddress'] ?? '';
        _mobileNumberController.text = messageObj['userMobile'] ?? '';
        _emailController.text = messageObj['userEmail'] ?? '';

        // For Town / Street
        _town = messageObj['town'] ?? '';     
        _street = messageObj['streetName'] ?? ''; 

        _town = 'L-Imsida';

        // Now fetch the streets for "L-Imsida"
        await _fetchStreets(_town!);

        setState(() => _isLoading = false);
      } else {
        debugPrint('Error fetching profile: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e, st) {
      debugPrint('Exception in _fetchUserProfile: $e\n$st');
      setState(() => _isLoading = false);
    }
  }

  /// Fetch streets for the user's town (similar to your RegisterPage).
  Future<void> _fetchStreets(String townName) async {
    try {
      final String? apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('API_KEY not found in .env file');
        return;
      }

      final url = Uri.parse('$apiBaseUrl/endpoints/locations/streetList.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_key': apiKey,
          'townName': townName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<String> fetchedStreets;
        if (data is List) {
          // If the endpoint returns an array
          fetchedStreets = data
              .map<String>((item) => item['streetName'].toString())
              .toList();
        } else if (data is Map && data.containsKey('streets')) {
          // If there's a "streets" key
          fetchedStreets = (data['streets'] as List)
              .map<String>((item) => item['streetName'].toString())
              .toList();
        } else {
          throw Exception('Unexpected format for street data: $data');
        }

        // Remove duplicates if needed
        fetchedStreets = fetchedStreets.toSet().toList();

        setState(() {
          _streetList = fetchedStreets;

          // Ensure the current street is valid, or default to the first
          if (_streetList.isNotEmpty) {
            if (!_streetList.contains(_street)) {
              _street = _streetList.first;
            }
          } else {
            // If no streets exist for that town, set street to null
            _street = null;
          }
        });
      } else {
        debugPrint('Error fetching streets: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('Exception in _fetchStreets: $e\n$st');
    }
  }

  /// If you need to pick a date of birth
  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dobController.text = formatter.format(pickedDate);
      });
    }
  }

  /// Validate + save user input. (Use this when sending updated data back to server.)
  bool _validateForm() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
      return true;
    }
    return false;
  }

  /// Example update action: call your "updateProfile" endpoint
  Future<void> _saveProfile() async {
    if (!_validateForm()) return; // stop if invalid

    try {
      final String? apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('API_KEY not found in .env file');
        return;
      }

      // Retrieve the user’s email from secure storage or from the controller
      const storage = FlutterSecureStorage();
      final String? userEmail = await storage.read(key: 'email');

      final url = Uri.parse('$apiBaseUrl/endpoints/user/profileUpdate.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_key': apiKey,
          'email': userEmail,            
          'name': _nameController.text.trim(),
          'surname': _surnameController.text.trim(),
          'dob': _dobController.text.trim(),
          'houseNumber': _houseNumberController.text.trim(),
          'street': _street,
          'town': _town,
          'mobile': _mobileNumberController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Possibly show a "Profile updated" message
          setState(() {
            _isEditing = false; // exit edit mode
          });
        } else {
          debugPrint('Update failed: ${data['message']}');
        }
      } else {
        debugPrint('Error updating profile: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('Exception in _saveProfile: $e\n$st');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _dobController.dispose();
    _houseNumberController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // While loading, just show a spinner
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Edit button toggles _isEditing
          IconButton(
            onPressed: () {
              setState(() => _isEditing = true);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _keyForm,
            child: IgnorePointer(
              ignoring: !_isEditing, // If not editing, all fields are read-only
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  CustomTextField(
                    labelText: 'Name',
                    controller: _nameController,
                    textFieldType: TextFieldType.textRequired,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 100,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 10),

                  // Surname
                  CustomTextField(
                    labelText: 'Surname',
                    controller: _surnameController,
                    textFieldType: TextFieldType.textRequired,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 100,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 10),

                  // Date of Birth
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month),
                      label: Text(
                        _dobController.text.isEmpty
                            ? 'Date of Birth'
                            : _dobController.text,
                        style: TextStyle(
                          color: _isEditing ? Colors.black : Colors.grey,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 10),

                  // House Number
                  CustomTextField(
                    labelText: 'House Name / Number',
                    controller: _houseNumberController,
                    textFieldType: TextFieldType.textRequired,
                    maxLength: 30,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 10),

                  // Street
                  DropdownButtonFormField<String>(
                    value: (_streetList.contains(_street)) ? _street : null,
                    decoration: InputDecoration(
                      labelText: 'Select Street',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: _isEditing ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    items: _streetList.map((String street) {
                      return DropdownMenuItem<String>(
                        value: street,
                        child: Text(
                          street,
                          style: TextStyle(
                            color: _isEditing ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _isEditing
                        ? (value) => setState(() => _street = value)
                        : null,
                    iconDisabledColor:
                        !_isEditing ? Colors.grey : Colors.black,
                  ),
                  const SizedBox(height: 10),

                  // Town (read-only; if you want to change it, remove IgnorePointer)
                  TextFormField(
                    initialValue: _town ?? '',
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Town',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Mobile
                  CustomTextField(
                    labelText: 'Mobile Number',
                    controller: _mobileNumberController,
                    textFieldType: TextFieldType.mobile,
                    maxLength: 20,
                    isEditing: _isEditing,
                  ),
                  const SizedBox(height: 10),

                  // Email (read-only or up to you)
                  CustomTextField(
                    labelText: 'Email Address',
                    controller: _emailController,
                    textFieldType: TextFieldType.email,
                    textCapitalization: TextCapitalization.none,
                    enabled: false,
                  ),
                  const SizedBox(height: 30),

                  // Show "Save" button only in edit mode
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}