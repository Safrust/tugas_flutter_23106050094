import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'mahasiswa_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final isLogin = await _authService.isLoggedIn();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MahasiswaPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
