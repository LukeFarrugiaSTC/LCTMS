import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isRegistered = false;
  bool _isLoading = true;
  final _keyForm = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  String _street = '';
  String _town = '';
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final formatter = DateFormat('dd/MM/yyyy');
  List<String> _tempStreetList = [];
  List<String> _tempTownsList = ['Msida'];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user data when the page loads
  }

  Future<void> _fetchUserProfile() async {
    // Simulating API call (Replace with actual API request)
    //await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    // Mocked response from API (Replace with actual API response parsing)
    final userData = {
      "name": "Luke",
      "surname": "Smith",
      "dob": "15/04/1990",
      "houseNumber": "123",
      "street": "Church Road",
      "town": "Msida",
      "mobile": "987654321",
      "email": "luke@example.com",
    };

    final apiStreets = [
      "Main Street",
      "High Street",
      "Church Road",
      "Victoria Avenue",
    ];

    setState(() {
      _tempStreetList = apiStreets;
      _street =
          _tempStreetList.contains(userData["street"])
              ? userData["street"]!
              : _tempStreetList.first;
      _nameController.text = userData["name"]!;
      _surnameController.text = userData["surname"]!;
      _dobController.text = userData["dob"]!;
      _houseNumberController.text = userData["houseNumber"]!;
      _street = userData["street"]!;
      _town = userData["town"]!;
      _mobileNumberController.text = userData["mobile"]!;
      _emailController.text = userData["email"]!;

      //_tempStreetList.clear();
      _tempStreetList = apiStreets;
      _isLoading = false;
      //_tempTownsList = _apiTown;  Not needed since currently only Msida is needed
    });
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

  bool _register() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();

      print(_nameController.text);
      print(_surnameController.text);
      print(_dobController.text);
      print(_houseNumberController.text);
      print(_street);
      print(_town);
      print(_mobileNumberController.text);
      print(_emailController.text);
      print(_passwordController.text);
      print(_confirmPasswordController.text);
      print(_confirmPasswordController.text);
      return true;
    }
    return false;
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

  //Build
  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    if (_isRegistered) {
      currentScreen = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 120),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Your registration has been successfully submitted!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Your submission is now being reviewed by the Local Council staff. '
                      'Once approved, you will be able to log in using the credentials you have set.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Return to home
                  Navigator.pushNamed(context, '/');
                },
                child: Text('Home'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    } else {
      currentScreen =
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading spinner
              : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    IgnorePointer(
                      ignoring:
                          !_isEditing, //interaction ignored so user cannot edit while not in edit mode
                      child: Form(
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
                                isEditing: _isEditing,
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                labelText: 'Surname',
                                controller: _surnameController,
                                textFieldType: TextFieldType.textRequired,
                                textCapitalization: TextCapitalization.words,
                                maxLength: 100,
                                isEditing: _isEditing,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                enabled: _isEditing,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.calendar_month),
                                  label: Text(
                                    _dobController.text.isEmpty
                                        ? 'Date of Birth'
                                        : _dobController.text,
                                    style: TextStyle(
                                      color:
                                          _isEditing
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(),
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
                                isEditing: _isEditing,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField(
                                value:
                                    _tempStreetList.contains(_street)
                                        ? _street
                                        : null,
                                decoration: InputDecoration(
                                  label: Text(
                                    'Select Street',
                                    style: TextStyle(
                                      color:
                                          _isEditing
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          _isEditing
                                              ? Colors.black
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                                items:
                                    _tempStreetList.map((String street) {
                                      return DropdownMenuItem<String>(
                                        value: street,
                                        child: Text(
                                          street,
                                          style: TextStyle(
                                            color:
                                                _isEditing
                                                    ? Colors.black
                                                    : Colors.grey,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    _isEditing
                                        ? (String? value) {
                                          setState(() {
                                            _street = value!;
                                          });
                                        }
                                        : null,
                                iconDisabledColor:
                                    !_isEditing ? Colors.grey : Colors.black,
                              ),
                              const SizedBox(height: 10),
                              IgnorePointer(
                                ignoring: true,
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            _isEditing
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  value: _tempTownsList[0],
                                  items:
                                      _tempTownsList.map((String town) {
                                        return DropdownMenuItem<String>(
                                          value: town,
                                          child: Text(
                                            town,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: null,
                                  // onChanged: (value) {
                                  //   setState(() {
                                  //     _town = value!;
                                  //   });
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                labelText: 'Mobile Number',
                                controller: _mobileNumberController,
                                textFieldType: TextFieldType.mobile,
                                maxLength: 20,
                                isEditing: _isEditing,
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                labelText: 'Email Address',
                                controller: _emailController,
                                textFieldType: TextFieldType.email,
                                textCapitalization: TextCapitalization.none,
                                enabled: false,
                              ),

                              const SizedBox(height: 40),
                              SizedBox(
                                width: 300,
                                child: Column(
                                  children: [
                                    if (_isEditing) // Only show the button when _isEditing is true
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = false;
                                            // Send data to API
                                          });
                                        },
                                        child: Text('Save'),
                                      ),
                                    if (_isEditing)
                                      const SizedBox(
                                        height: 20,
                                      ), // Space only when button exists
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            icon: Icon(_isEditing ? Icons.edit : Icons.edit_outlined),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: currentScreen,
    );
  }
}
