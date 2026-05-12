import 'role_model.dart';

class RegisterModel {
  RegisterModel({
    required this.fullName,
    required this.email,
    required this.password,
    this.role = Roles.user,
  });

  final String fullName;
  final String email;
  final String password;
  final String role;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'password': password,
    'role': role,
  };
}
