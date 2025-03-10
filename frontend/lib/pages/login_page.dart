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

  void _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print(_emailController);
      print(_passwordController);
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
