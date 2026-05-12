class ChangeRoleModel {
  ChangeRoleModel({required this.role, required this.isActive});

  final String role;
  final bool isActive;

  Map<String, dynamic> toJson() => {'role': role, 'isActive': isActive};
}
