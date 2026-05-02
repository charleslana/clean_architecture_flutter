import 'package:flutter/foundation.dart';

/// Records used to group sub-object fields together.
///
/// The architecture guide suggests using Dart records to "group related values
/// (prevents index misalignment)" within an SSOT class. They are a great fit
/// for nested API objects like company/address that don't deserve a class of
/// their own — but the top-level [User] is still a class because:
///   - records can't have `fromJson`/`toJson`,
///   - records can't carry a domain-specific type name (a record `(int id,
///     String name)` matches anything with the same shape).
typedef Company = ({String name, String catchPhrase});
typedef Address = ({String city, String street, String suite});

@immutable
class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.company,
    required this.address,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final Company company;
  final Address address;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          other.id == id &&
          other.name == name &&
          other.username == username &&
          other.email == email &&
          other.phone == phone &&
          other.website == website &&
          other.company == company &&
          other.address == address;

  @override
  int get hashCode =>
      Object.hash(id, name, username, email, phone, website, company, address);
}
