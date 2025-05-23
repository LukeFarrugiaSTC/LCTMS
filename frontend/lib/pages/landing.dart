import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/pages/view_bookings.dart';
import 'package:frontend/widgets/book_ridev2.dart';
import 'package:frontend/widgets/main_drawer.dart';
import 'package:frontend/providers/user_info_provider.dart';

// Class representing the post-login landing screen with navigation and booking access
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User user = ref.read(userInfoProvider);

    void setPage(String identifier) {
      if (identifier == '/login') {
        //logs out user
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

    Widget landingWidget(int roleNumber) {
      if (roleNumber == 2) {
        //Driver role
        return ViewBookingsPage(showScaffold: false);
      }
      return BookRideV2(showScaffold: false); // admin or user
    }

    return PopScope(
      canPop:
          false, //since there are is only the landing page in stack, this prevents the user from using the native back button
      child: Scaffold(
        appBar: AppBar(
          title:
              ref.read(userInfoProvider).userRole == 2
                  ? const Text('Bookings')
                  : const Text('Book a Ride'),
        ),
        drawer: MainDrawer(onSelectPage: setPage, roleId: user.userRole),
        body: landingWidget(ref.read(userInfoProvider).userRole),
      ),
    );
  }
}
