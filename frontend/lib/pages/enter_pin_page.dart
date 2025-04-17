import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/pages/update_password_page.dart';

// Class for verifying the reset PIN sent to the user's email before allowing password reset
class EnterPinPage extends StatefulWidget {
  final String email;
  const EnterPinPage({Key? key, required this.email}) : super(key: key);

  @override
  State<EnterPinPage> createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  /// Verifies the entered PIN with the backend.
  Future<void> _verifyPin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('$apiBaseUrl/endpoints/user/verifyPin.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': widget.email,
          'pin': _pinController.text.trim(),
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        // If the PIN is correct, navigate to the update password page.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => UpdatePasswordPage(
                  email: widget.email,
                  pin: _pinController.text.trim(),
                ),
          ),
        );
      } else {
        // Show error message from the backend.
        setState(() {
          _errorMessage = data['message'] ?? 'Invalid PIN. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
      debugPrint('Error verifying PIN: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitPin() async {
    if (_formKey.currentState!.validate()) {
      await _verifyPin();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'A PIN has been sent to your email. Please enter the PIN below:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the PIN.';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _submitPin,
                    child: const Text('Submit PIN'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
