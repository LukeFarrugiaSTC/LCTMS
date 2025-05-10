// This class represents a client-user in the system from an Admin's POV

class Client {
  const Client({
    required this.clientID,
    required this.clientEmail,
    required this.clientFirstName,
    required this.clientLastName,
    required this.clientAddress,
    required this.streetName,
    required this.townName,
    required this.clientMobile,
  });

  final int clientID;
  final String clientEmail;
  final String clientFirstName;
  final String clientLastName;
  final String clientAddress;
  final String streetName;
  final String townName;
  final String clientMobile;
}
