import '../../../../domain/models/user.dart';

class UserApiModel {
  const UserApiModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.companyName,
    required this.companyCatchPhrase,
    required this.addressCity,
    required this.addressStreet,
    required this.addressSuite,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>? ?? const {};
    final address = json['address'] as Map<String, dynamic>? ?? const {};
    return UserApiModel(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      companyName: company['name'] as String? ?? '',
      companyCatchPhrase: company['catchPhrase'] as String? ?? '',
      addressCity: address['city'] as String? ?? '',
      addressStreet: address['street'] as String? ?? '',
      addressSuite: address['suite'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String companyName;
  final String companyCatchPhrase;
  final String addressCity;
  final String addressStreet;
  final String addressSuite;

  User toDomain() => User(
    id: id,
    name: name,
    username: username,
    email: email,
    phone: phone,
    website: website,
    company: (name: companyName, catchPhrase: companyCatchPhrase),
    address: (city: addressCity, street: addressStreet, suite: addressSuite),
  );
}
