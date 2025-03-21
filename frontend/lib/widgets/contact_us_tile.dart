import 'package:flutter/material.dart';

class ContactUsTile extends StatelessWidget {
  const ContactUsTile({
    super.key,
    required this.icon,
    required this.contactMethod,
    required this.contactDetail,
  });
  final IconData icon;
  final String contactMethod;
  final String contactDetail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 40),
              Icon(icon, size: 40),
              SizedBox(height: 15),
              Text(
                contactMethod,
                style: Theme.of(context).textTheme.titleLarge!,
              ),
              SizedBox(height: 10),
              Text(
                contactDetail,
                style: Theme.of(context).textTheme.bodyLarge!,
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
