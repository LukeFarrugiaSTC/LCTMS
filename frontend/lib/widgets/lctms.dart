import 'package:flutter/material.dart';
import 'package:frontend/pages/forgot_password.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/landing.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/pages/users.dart';
import 'package:google_fonts/google_fonts.dart';

var kcolourScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 107, 77, 87),
);

class LCTMS extends StatelessWidget {
  const LCTMS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //setting up theme
      theme: ThemeData().copyWith(
        colorScheme: kcolourScheme,
        appBarTheme: AppBarTheme().copyWith(
          backgroundColor: kcolourScheme.onPrimaryContainer,
          foregroundColor: kcolourScheme.primaryContainer,
          elevation: 6,
          titleTextStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 243, 231, 231),
            fontSize: 24,
          ),
          iconTheme: IconThemeData(
            color: const Color.fromARGB(255, 243, 231, 231),
          ),
        ),
        cardTheme: const CardTheme().copyWith(
          color: kcolourScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 107, 77, 87),
            fixedSize: Size(300, 40),
            foregroundColor: const Color.fromARGB(255, 243, 231, 231),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            fixedSize: Size(300, 40),
            foregroundColor: const Color.fromARGB(255, 107, 77, 87),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: kcolourScheme.onSecondaryContainer,
            fontSize: 16,
          ),
        ),
      ),
      initialRoute: '/landing',

      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/landing': (context) => const LandingPage(),
        '/profile': (context) => const ProfilePage(),
        '/users': (context) => const UsersPage(),
      },
    );
  }
}
