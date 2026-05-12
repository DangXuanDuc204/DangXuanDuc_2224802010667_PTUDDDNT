import 'package:flutter/material.dart';

import '../models/role_model.dart';
import '../models/user_model.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge(this.role, {super.key});

  final String role;

  @override
  Widget build(BuildContext context) {
    final colors = switch (role) {
      Roles.admin => (bg: const Color(0xFFFFE4EF), fg: const Color(0xFFB0004B)),
      Roles.manager => (
        bg: const Color(0xFFE0F2FE),
        fg: const Color(0xFF0369A1),
      ),
      Roles.staff => (bg: const Color(0xFFFFEDD5), fg: const Color(0xFFC2410C)),
      _ => (bg: const Color(0xFFEFF6FF), fg: const Color(0xFF475569)),
    };

    return Chip(
      label: Text(role.isEmpty ? 'Unknown' : role),
      visualDensity: VisualDensity.compact,
      backgroundColor: colors.bg,
      side: BorderSide(color: colors.fg.withValues(alpha: 0.18)),
      labelStyle: TextStyle(color: colors.fg, fontWeight: FontWeight.w700),
    );
  }
}

class UserDetails extends StatelessWidget {
  const UserDetails({
    super.key,
    required this.user,
    this.canEdit = false,
    this.canToggle = false,
    this.onEdit,
    this.onToggle,
  });

  final UserModel user;
  final bool canEdit;
  final bool canToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isActive ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      RoleBadge(user.role),
                      Chip(
                        label: Text(
                          user.isActive ? 'Đang hoạt động' : 'Đã khóa',
                        ),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: statusColor),
                        labelStyle: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (canEdit)
              IconButton(
                tooltip: 'Sửa',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
            if (canToggle)
              IconButton(
                tooltip: user.isActive ? 'Khóa' : 'Kích hoạt',
                icon: Icon(
                  user.isActive ? Icons.lock_outline : Icons.lock_open_outlined,
                ),
                onPressed: onToggle,
              ),
          ],
        ),
      ),
    );
  }
}
