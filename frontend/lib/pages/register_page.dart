import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
  final List<String> _tempStreetList = ['Street 1', 'street 2'];
  final List<String> _tempTownsList = ['Msida', 'town 2'];
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _town = _tempTownsList[0]; //defaulting to Msida
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
    print(_confirmPasswordController.text);
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
      currentScreen = SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Registration Form',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontSize: 30),
            ),
            SizedBox(height: 20),
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
                        prefixIcon: Icon(Icons.calendar_month),
                        label: Text(
                          _dobController.text.isEmpty
                              ? 'Date of Birth'
                              : _dobController.text,
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
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: null,
                      decoration: InputDecoration(
                        label: Text(_street == '' ? 'Select Street' : ''),
                      ),
                      items:
                          _tempStreetList.map((String street) {
                            return DropdownMenuItem<String>(
                              value: street,
                              child: Text(street),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _street = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: _tempTownsList[0],
                      items:
                          _tempTownsList.map((String town) {
                            return DropdownMenuItem<String>(
                              value: town,
                              child: Text(town),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _town = value!;
                        });
                      },
                    ),
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
                    SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                //changes screen according to if registration was successful or not
                                _isRegistered = _register();
                              });
                            },
                            child: Text('Register'),
                          ),
                          const SizedBox(height: 5),

                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: TextButton.styleFrom(
                              fixedSize: Size(300, 40),
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
