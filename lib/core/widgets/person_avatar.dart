import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ảnh đại diện dạng chữ cái đầu của tên.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar(this.name, {super.key, this.radius = 20});

  final String name;
  final double radius;

  String get _initial {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.last.isEmpty) return '?';
    return parts.last[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.goldLight,
      child: Text(
        _initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
