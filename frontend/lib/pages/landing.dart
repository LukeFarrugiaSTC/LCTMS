import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/widgets/book_ride.dart';
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
        drawer: MainDrawer(onSelectPage: setPage, roleId: user.userRole),
        body: BookRide(showScaffold: false),
      ),
    );
  }
}
