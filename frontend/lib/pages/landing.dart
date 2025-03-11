import 'package:flutter/material.dart';
import 'package:frontend/widgets/main_drawer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  final int _role = 1;


  @override
  Widget build(BuildContext context) {


    void _setPage(String identifier) {
      if (identifier == '/login') {
        //logs out user
        // => to do is to clear providers from user/ password and role once these are set up
        Navigator.pushNamedAndRemoveUntil(
          context,
          identifier,
          (Route<dynamic> route) => false,
        );
      }
      Navigator.pop(context); //to close drawer
      Navigator.pushNamed(context, identifier); //navigate to chosen screen
    }

    //Logic to create nav menu

    




    return Scaffold(
      appBar: AppBar(title: const Text('Book a Ride')),
      drawer: MainDrawer(onSelectPage: _setPage, roleId: _role,),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
          ],
        ),
      ),
    );
  }
}
