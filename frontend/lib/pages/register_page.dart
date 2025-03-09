import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _keyForm = GlobalKey<FormState>();

  RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  final TextEditingController _dobController = TextEditingController();
  String _name = '';
  String _surname = '';
  String _houseNumber = '';
  String _street = '';
  String _town = '';
  String _mobileNumber = '';
  String _email = '';
  String _password = '';
  DateTime? _dob;
  final formatter = DateFormat('dd/MM/yyyy');
  final List<String> _tempStreetList = ['street 1', 'street 2'];
  final List<String> _tempTownsList = ['Msida', 'town 2'];

  Future<void> _selectDate(context) async {
    final _pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (_pickedDate != null) {
      setState(() {
        _dob = _pickedDate;
      });
    }
  }

  bool _isEmpty(String value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
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
                      TextFormField(
                        decoration: InputDecoration(label: Text('Name')),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(label: Text('Surname')),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.calendar_month),
                          label: Text(
                            _dob == null
                                ? 'Date of Birth'
                                : formatter.format(_dob!),
                          ),
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('House No / Name'),
                        ),
                      ),
                      SizedBox(height: 10),
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
                            //Set state might not be needed but according to him, yes
                            _street = value!;
                          });
                        },
                      ),
                      SizedBox(height: 10),
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
                            //Set state might not be needed but according to him, yes
                            _town = value!;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('Mobile Number'),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text('Email Address'),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text('Password'),
                        ),
                        autocorrect: false,
                        obscureText: true,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text('Confirm Password'),
                        ),
                        autocorrect: false,
                        obscureText: true,
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: Text('Register'),
                            ),
                            SizedBox(height: 5),

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

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
