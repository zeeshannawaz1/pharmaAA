import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../injection_container.dart' as di;
import 'splash_screen.dart';
import 'auth_check_widget.dart';
import 'force_update_blocker.dart';

class MainAppWidget extends StatefulWidget {
  const MainAppWidget({Key? key}) : super(key: key);

  @override
  State<MainAppWidget> createState() => _MainAppWidgetState();
}

class _MainAppWidgetState extends State<MainAppWidget> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wrap everything in ForceUpdateBlocker to block app if force_update = true
    return ForceUpdateBlocker(
      child: _showSplash
          ? SplashScreen(onSplashComplete: _onSplashComplete)
          : BlocProvider(
              create: (_) => di.sl<AuthBloc>(),
              child: const AuthCheckWidget(),
            ),
    );
  }
} 
