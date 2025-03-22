import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To access .env
import 'package:frontend/pages/enter_pin_page.dart';

// Class for requesting a password reset PIN using the user's email address
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _keyForm = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitEmail() async {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final url = Uri.parse('$apiBaseUrl/endpoints/user/generatePin.php');

      // Get the API key from .env
      final String? apiKey = dotenv.env['API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('API key is missing.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'api_key': apiKey}),
        );
        final data = json.decode(response.body);
        debugPrint('Forgot password error: $data');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Unknown response')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EnterPinPage(email: email)),
          );
        } else {
          final data = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Unknown response')),
          );
        }
      } catch (e) {
        debugPrint('Forgot password error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again later.'),
          ),
        );
        debugPrint('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Reset Your Password',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 100),
            Form(
              key: _keyForm,
              child: CustomTextField(
                labelText: 'Email',
                controller: _emailController,
                textFieldType: TextFieldType.email,
                textCapitalization: TextCapitalization.none,
              ),
            ),
            const SizedBox(height: 25),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _submitEmail,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [SizedBox(width: 16), Text("Submit")],
                  ),
                ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
