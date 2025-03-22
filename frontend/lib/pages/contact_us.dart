import 'package:flutter/material.dart';
import 'package:frontend/widgets/contact_us_tile.dart';

// Class displaying contact information for the local council using ContactUsTile widgets
class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Center(
        child: Column(
          children: [
            ContactUsTile(
              icon: Icons.map,
              contactMethod: 'Address',
              contactDetail: 'Menqa Square, Msida. MSD9090',
            ),
            ContactUsTile(
              icon: Icons.phone,
              contactMethod: 'Phone',
              contactDetail: '+356 21334343',
            ),
            ContactUsTile(
              icon: Icons.email,
              contactMethod: 'Email',
              contactDetail: 'msida.lc@gov.mt',
            ),
          ],
        ),
      ),
    );
  }
}
