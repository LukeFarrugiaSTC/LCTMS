import 'package:flutter/material.dart';
import 'package:frontend/pages/book_ride.dart';
import 'package:frontend/widgets/main_drawer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  final int _role = 3;

  @override
  Widget build(BuildContext context) {
    void setPage(String identifier) {
      if (identifier == '/login') {
        //logs out user
        // => to do is to clear providers from user/ password and role once these are set up
        Navigator.pushNamedAndRemoveUntil(
          context,
          identifier,
          (Route<dynamic> route) => false,
        );
        return;
      }
      Navigator.pop(context); //to close drawer
      Navigator.pushNamed(context, identifier); //navigate to chosen screen
    }

    return PopScope(
      canPop:
          false, //since there are is only the landing page in stack, this prevents the user from using the native back button
      child: Scaffold(
        appBar: AppBar(title: const Text('Book a Ride')),
        drawer: MainDrawer(onSelectPage: setPage, roleId: _role),
        body: BookRide(),
      ),
    );
  }
}
