import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_text_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final _keyForm = GlobalKey<FormState>();

  void _submitEmail() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
      print(_emailController.text);
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
      appBar: AppBar(title: Text('Forgot Password')),
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
            SizedBox(height: 100),
            Form(
              key: _keyForm,
              child: CustomTextField(
                labelText: 'Email',
                controller: _emailController,
                textFieldType: TextFieldType.email,
                textCapitalization: TextCapitalization.none,
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: _submitEmail,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [SizedBox(width: 16), Text("Submit")],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
