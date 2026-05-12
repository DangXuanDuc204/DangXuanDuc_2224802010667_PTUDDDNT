class Roles {
  Roles._();

  static const String admin = 'Admin';
  static const String manager = 'Manager';
  static const String staff = 'Staff';
  static const String user = 'User';

  static const List<String> all = [admin, manager, staff, user];
  static const List<String> managedByManager = [staff, user];
}
