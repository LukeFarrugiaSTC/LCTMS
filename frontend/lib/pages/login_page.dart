import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
//import 'package:frontend/config/api_config.dart';

// Import your custom text field widget
import 'package:frontend/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Keys and controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Validation / state variables
  bool _isValid = false;
  String? _invalidCredentials;

  /// Validates the form inputs using the validators
  /// defined in each `CustomTextField`.
  bool _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }

  /// Makes a POST request to your PHP login endpoint.
  /// If successful, it retrieves the JWT token and stores
  /// it securely, then navigates to the Landing page.
  Future<void> _submitLogin() async {
    try {
      //final url = Uri.parse('$apiBaseUrl/endpoints/user/login.php');
      final url = Uri.parse(
        '/endpoints/user/login.php',
      ); //temp to delete until emma pushes
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Extract the JWT token
          final String token = data['token'];

          // Securely store it using flutter_secure_storage
          const storage = FlutterSecureStorage();
          await storage.write(key: 'jwt_token', value: token);

          // Navigate to landing page
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/landing',
            (Route<dynamic> route) => false,
          );
        } else {
          // Show error message from server or a default one
          setState(() {
            _invalidCredentials = data['message'] ?? 'Invalid credentials.';
          });
        }
      } else {
        setState(() {
          _invalidCredentials =
              'Error: ${response.statusCode}. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _invalidCredentials = 'An error occurred: $e';
      });
    }
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
          // Top "Welcome" text
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

          // Form fields and buttons
          const Spacer(),
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
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isValid = _login();
                              _invalidCredentials = null;
                            });

                            if (_isValid) {
                              await _submitLogin();
                            }
                          },
                          child: const Text('Log in'),
                        ),

                        // Show any error messages
                        if (_invalidCredentials != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _invalidCredentials!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: TextButton.styleFrom(
                                fixedSize: const Size(150, 40),
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                              ),
                              child: const Text('Register now'),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              style: TextButton.styleFrom(
                                fixedSize: const Size(150, 40),
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
          const Spacer(),
        ],
      ),
    );
  }
}
