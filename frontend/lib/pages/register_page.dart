import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _keyForm = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final formatter = DateFormat('yyyy-MM-dd');

  // Dynamic lists for towns and streets populated via API
  List<String> _townsList = [];
  List<String> _streetsList = [];

  // Selected town and street
  String _selectedTown = '';
  String _selectedStreet = '';

  bool _isRegistered = false;
  String? _registrationError;

  @override
  void initState() {
    super.initState();
    _fetchTowns();
  }

  /// Fetches towns from the townsList endpoint.
  Future<void> _fetchTowns() async {
    // Directly set the town to L-Imsida
    setState(() {
      _townsList = ["L-Imsida"];
      _selectedTown = "L-Imsida";
    });
    // Immediately fetch the streets for L-Imsida.
    _fetchStreets("L-Imsida");
  }

  /// Fetches streets based on the selected town from the streetList endpoint.
  Future<void> _fetchStreets(String townName) async {
    final url = Uri.parse('$apiBaseUrl/endpoints/locations/streetList.php');

    // Get the API key from the .env file
    final String? apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('API_KEY not found in .env file');
      return;
    }
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'api_key': apiKey, // Use the API key from .env
          'townName': townName,
        }),
      );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> streets;
        if (data is List) {
          streets = data
              .map<String>((item) => item['streetName'].toString())
              .toList();
        } else if (data is Map && data.containsKey('streets')) {
          streets = (data['streets'] as List)
              .map<String>((item) => item['streetName'].toString())
              .toList();
        } else {
          throw Exception('Unexpected response format for streets: $data');
        }
        setState(() {
          _streetsList = streets;
          _selectedStreet = streets.isNotEmpty ? streets[0] : '';
        });
      } else {
        setState(() {
          _registrationError = 'Error: ${response.statusCode}';
        });
      }
    } catch (e, stacktrace) {
      debugPrint('Error in _fetchStreets: $e');
      debugPrint('Stacktrace: $stacktrace');
      setState(() {
        _registrationError = 'An error occurred: $e';
      });
    }
  }

  Future<void> _selectDate(context) async {
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

  bool _validateForm() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
      return true;
    }
    return false;
  }

  Future<void> _submitRegistration() async {
    final url = Uri.parse('$apiBaseUrl/endpoints/user/registration.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'fname': _nameController.text.trim(),
          'lname': _surnameController.text.trim(),
          'houseNumber': _houseNumberController.text.trim(),
          'townName': _selectedTown,
          'streetName': _selectedStreet,
          'mobile': _mobileNumberController.text.trim(),
          'dob': _dobController.text.trim(),
          'password': _passwordController.text.trim(),
          'confirm': _confirmPasswordController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _isRegistered = true;
            _registrationError = null;
          });
        } else {
          setState(() {
            _registrationError = data['message'] ?? 'Registration failed.';
          });
        }
      } else {
        setState(() {
          _registrationError =
              'Error: ${response.statusCode}. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _registrationError = 'An error occurred: $e';
      });
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
    Widget currentScreen;

    if (_isRegistered) {
      currentScreen = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 120),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your registration has been successfully submitted!',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Your submission is now being reviewed by the Local Council staff. Once approved, you will be able to log in using the credentials you have set.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                child: const Text('Home'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    } else {
      currentScreen = SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Registration Form',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontSize: 30),
            ),
            const SizedBox(height: 20),
            Form(
              key: _keyForm,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: 'Name',
                      controller: _nameController,
                      textFieldType: TextFieldType.textRequired,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 100,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      labelText: 'Surname',
                      controller: _surnameController,
                      textFieldType: TextFieldType.textRequired,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 100,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_month),
                        label: Text(
                          _dobController.text.isEmpty
                              ? 'Date of Birth'
                              : _dobController.text,
                        ),
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 5),
                    CustomTextField(
                      labelText: 'House Name / Number',
                      controller: _houseNumberController,
                      textFieldType: TextFieldType.textRequired,
                      maxLength: 30,
                    ),
                    const SizedBox(height: 10),
                    _townsList.isEmpty
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            value: _selectedTown.isNotEmpty ? _selectedTown : null,
                            hint: const Text('Select Town'),
                            decoration: const InputDecoration(
                              labelText: 'Select Town',
                            ),
                            items: _townsList.map((String town) {
                              return DropdownMenuItem<String>(
                                value: town,
                                child: Text(town),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTown = value!;
                                _streetsList = [];
                                _selectedStreet = '';
                              });
                              _fetchStreets(_selectedTown);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a town';
                              }
                              return null;
                            },
                          ),
                    const SizedBox(height: 10),
                    _selectedTown.isNotEmpty
                        ? _streetsList.isEmpty
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                                value: _selectedStreet.isNotEmpty ? _selectedStreet : null,
                                decoration: const InputDecoration(
                                  labelText: 'Select Street',
                                ),
                                items: _streetsList.map((String street) {
                                  return DropdownMenuItem<String>(
                                    value: street,
                                    child: Text(street),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStreet = value!;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a street';
                                  }
                                  return null;
                                },
                              )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 10),
                    CustomTextField(
                      labelText: 'Mobile Number',
                      controller: _mobileNumberController,
                      textFieldType: TextFieldType.mobile,
                      maxLength: 20,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      labelText: 'Email Address',
                      controller: _emailController,
                      textFieldType: TextFieldType.email,
                      textCapitalization: TextCapitalization.none,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      labelText: 'Password',
                      controller: _passwordController,
                      textFieldType: TextFieldType.password,
                      textCapitalization: TextCapitalization.none,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      labelText: 'Confirm Password',
                      controller: _confirmPasswordController,
                      textFieldType: TextFieldType.confirmPassword,
                      textCapitalization: TextCapitalization.none,
                      confirmPasswordController: _passwordController,
                    ),
                    const SizedBox(height: 40),
                    if (_registrationError != null)
                      Text(
                        _registrationError!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_validateForm()) {
                                await _submitRegistration();
                              }
                            },
                            child: const Text('Register'),
                          ),
                          const SizedBox(height: 5),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: TextButton.styleFrom(
                              fixedSize: const Size(300, 40),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Already have an account?',
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
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      resizeToAvoidBottomInset: true,
      body: currentScreen,
    );
  }
}