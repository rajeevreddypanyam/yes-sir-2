enum UserRole { orgAdmin, teamAdmin, employee }

class AppUser {
  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.organizationId,
    this.teamId,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;
  final String? organizationId;
  final String? teamId;

  factory AppUser.fromJson(String uid, Map<String, dynamic> json) {
    final roleValue = (json['role'] as String?) ?? 'employee';
    return AppUser(
      uid: uid,
      email: (json['email'] as String?) ?? '',
      role: _roleFromString(roleValue),
      displayName: json['displayName'] as String?,
      organizationId: json['organizationId'] as String?,
      teamId: json['teamId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role.name,
      if (displayName != null) 'displayName': displayName,
      if (organizationId != null) 'organizationId': organizationId,
      if (teamId != null) 'teamId': teamId,
    };
  }

  static UserRole _roleFromString(String value) {
    switch (value) {
      case 'org_admin':
      case 'orgAdmin':
        return UserRole.orgAdmin;
      case 'team_admin':
      case 'teamAdmin':
        return UserRole.teamAdmin;
      default:
        return UserRole.employee;
    }
  }
}
