import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user.dart';

// Class managing user authentication state using Riverpod's StateNotifier
class UserInfoNotifier extends StateNotifier<User> {
  UserInfoNotifier() : super(User(userID: 0, userRole: 3, email: ''));

  //Method to add logged user's details
  void loginUser(User user) {
    state = user;
  }

  void logoutUser(User user) {
    state = User(userID: 0, userRole: 3, email: '');
  }
}

//returns user top any widget that calls this provider

final userInfoProvider = StateNotifierProvider<UserInfoNotifier, User>((ref) {
  return UserInfoNotifier();
});
