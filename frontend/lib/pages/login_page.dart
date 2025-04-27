import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/user_info_provider.dart';
import 'package:frontend/models/user.dart';

// Class responsible for user authentication and login interaction
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Keys and controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables
  bool _isValid = false;
  String? _invalidCredentials;

  /// Validates the form inputs using validators defined in CustomTextField.
  bool _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }

  /// Makes a POST request to your PHP login endpoint.
  /// On success, stores the JWT token securely and navigates to the Landing page.
  Future<void> _submitLogin() async {
    try {
      final url = Uri.parse('$apiBaseUrl/endpoints/user/login.php');
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
          // Extract the JWT token without logging sensitive data.
          final String token = data['token'];
          final String email = data['email'];
          final int roleId = data['roleId'];

          // Securely store the token using flutter_secure_storage.
          const storage = FlutterSecureStorage();
          await storage.write(key: 'jwt_token', value: token);
          await storage.write(key: 'email', value: email);
          await storage.write(key: 'roleId', value: roleId.toString());

          final user = User(
            userID: data['userId'],
            userRole: data['roleId'],
            email: data['email'],
          );

          ref.read(userInfoProvider.notifier).loginUser(user);

          // Navigate to landing page (clear previous routes).
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/landing',
            (Route<dynamic> route) => false,
          );
        } else {
          // Show an error message from the server or a default one.
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
      // Avoid exposing sensitive error details.
      setState(() {
        _invalidCredentials = 'An error occurred. Please try again later.';
      });
      debugPrint('Login error: $e');
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
