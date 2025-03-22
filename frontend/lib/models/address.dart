// This class represents a physical address with house name/number, street, and town.

class Address {
  const Address({
    required this.houseNameNo,
    required this.street,
    required this.town,
  });

  final String houseNameNo;
  final String street;
  final String town;
}
