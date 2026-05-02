import '../../../../domain/models/user.dart';
import '../json_field.dart';

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
    final company =
        jsonOptional<Map<String, dynamic>>(json, 'company') ?? const {};
    final address =
        jsonOptional<Map<String, dynamic>>(json, 'address') ?? const {};
    return UserApiModel(
      id: jsonRequired<int>(json, 'id'),
      name: jsonRequired<String>(json, 'name'),
      username: jsonRequired<String>(json, 'username'),
      email: jsonRequired<String>(json, 'email'),

      phone: jsonOptional<String>(json, 'phone') ?? '',
      website: jsonOptional<String>(json, 'website') ?? '',
      companyName: jsonOptional<String>(company, 'name') ?? '',
      companyCatchPhrase: jsonOptional<String>(company, 'catchPhrase') ?? '',
      addressCity: jsonOptional<String>(address, 'city') ?? '',
      addressStreet: jsonOptional<String>(address, 'street') ?? '',
      addressSuite: jsonOptional<String>(address, 'suite') ?? '',
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
