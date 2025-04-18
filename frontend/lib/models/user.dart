// This class represents a user in the system

class User {
  const User({
    required this.userID,
    required this.userRole,
    required this.token,
  });

  final int userID;
  final int userRole;
  final String token;
}
