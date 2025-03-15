import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/api_config.dart';
import 'package:http/http.dart' as http;

class UpdatePasswordPage extends StatefulWidget {
  final String email;
  final String pin;
  const UpdatePasswordPage({Key? key, required this.email, required this.pin})
      : super(key: key);

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });

      final url =
          Uri.parse('$apiBaseUrl/endpoints/user/updatePassword.php');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': widget.email,
            'pin': widget.pin,
            'newPassword': _newPasswordController.text,
          }),
        );
        final data = json.decode(response.body);
        if (response.statusCode == 200 && data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          Navigator.popUntil(context, ModalRoute.withName('/login'));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(data['message'] ?? 'Error updating password')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("An error occurred. Please try again later.")),
        );
        debugPrint('Update password error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter your new password below:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password.';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updatePassword,
                      child: const Text('Update Password'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}