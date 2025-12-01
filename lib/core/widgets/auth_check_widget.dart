import 'package:flutter/material.dart';
import 'package:aa_app/core/services/auth_service.dart';
import 'package:aa_app/features/auth/presentation/pages/login_page.dart';
import 'package:aa_app/main_screen.dart';

class AuthCheckWidget extends StatefulWidget {
  const AuthCheckWidget({Key? key}) : super(key: key);

  @override
  State<AuthCheckWidget> createState() => _AuthCheckWidgetState();
}

class _AuthCheckWidgetState extends State<AuthCheckWidget> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final userName = await AuthService.getCurrentUserName();
      
      setState(() {
        _isLoggedIn = isLoggedIn;
        _userName = userName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _userName = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLoggedIn) {
      return MainScreen(userName: _userName);
    } else {
      return const LoginPage();
    }
  }
} 
