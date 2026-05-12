class ChangePasswordModel {
  ChangePasswordModel({required this.oldPassword, required this.newPassword});

  final String oldPassword;
  final String newPassword;

  Map<String, dynamic> toJson() => {
    'oldPassword': oldPassword,
    'currentPassword': oldPassword,
    'newPassword': newPassword,
  };
}
