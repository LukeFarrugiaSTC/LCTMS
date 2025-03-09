import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    final _keyForm = GlobalKey<FormState>();
    String _email = '';
    RegExp _emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    void _resetPassword() {
      if (_keyForm.currentState!.validate()) {
        _keyForm.currentState!.save();
        print(_email);
      }
    }

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
              child: TextFormField(
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
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                _resetPassword();
              },

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
