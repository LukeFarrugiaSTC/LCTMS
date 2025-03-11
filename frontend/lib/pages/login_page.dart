import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String _username = 'lukefarrugia@stcmalta.edu.mt';
  final String _password = 'a';
  bool _isValid = false;
  String? _invaldCredentials;

  bool _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print(_emailController);
      print(_passwordController);
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    textFieldType: TextFieldType.textRequired,
                    textCapitalization: TextCapitalization.none,
                    obscureText: true,
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isValid = _login();

                              if (_isValid &&
                                  _emailController.text == _username &&
                                  _passwordController.text == _password) {
                                _invaldCredentials =
                                    null; //clears error message
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/landing',
                                  (Route<dynamic> route) => false,
                                );
                              } else {
                                _invaldCredentials =
                                    'Invalid email or password. Please try again.';
                              }
                            });
                          },
                          child: const Text('Log in'),
                        ),
                        if (_invaldCredentials != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _invaldCredentials!,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
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
