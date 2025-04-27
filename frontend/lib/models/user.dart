// This class represents a user in the system

class User {
  const User({
    required this.userID,
    required this.userRole,
    required this.email,
  });

  final int userID;
  final int userRole;
  final String email;
}
