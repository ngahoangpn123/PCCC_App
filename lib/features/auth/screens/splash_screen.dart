import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // TODO: khi có Supabase, kiểm tra phiên đăng nhập để vào thẳng trang chủ.
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 88, onDark: true),
            SizedBox(height: 20),
            Text(
              'PCCC & CNCH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Hỗ trợ người đứng đầu cơ sở',
              style: TextStyle(color: AppColors.goldLight),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo tạm của app.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: Icon(
        Icons.local_fire_department,
        size: size * 0.6,
        color: onDark ? AppColors.primary : Colors.white,
      ),
    );
  }
}
