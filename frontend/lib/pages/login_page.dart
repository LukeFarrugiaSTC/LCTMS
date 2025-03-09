import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  void _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print(_email);
      print(_password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Welcome',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(fontSize: 30),
              ),
            ),
          ),
          Spacer(),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      label: const Text('Email'),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    maxLength: 255,
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      } else if (!_emailRegExp.hasMatch(value)) {
                        return 'Invalid email format';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),

                  SizedBox(height: 25),
                  TextFormField(
                    decoration: InputDecoration(label: const Text('Password')),
                    autocorrect: false,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        //checks if password is empty
                        return 'Password is required';
                      } else if (value.length < 8) {
                        //A password smaller than 8 characters is by default invalid and this will reduce an API call.  .trim() not added as a pw can contain spaces.
                        return 'Invalid password';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _login,
                          child: const Text('Log in'),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: TextButton.styleFrom(
                                fixedSize: Size(150, 40),
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                              ),
                              child: const Text(
                                'Register now',
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              style: TextButton.styleFrom(
                                fixedSize: Size(150, 40),
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerRight,
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Spacer(),
        ],
      ),
    );
  }
}
