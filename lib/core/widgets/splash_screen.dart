import 'package:flutter/material.dart';
import 'dart:async';
import '../services/app_update_service.dart';
import 'app_update_dialog.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onSplashComplete;

  const SplashScreen({
    super.key,
    required this.onSplashComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _updateCheckComplete = false;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _startAnimations();
    _checkForUpdates(); // Check for updates in parallel
  }

  void _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    await Future.delayed(const Duration(seconds: 2)); // Reduced from 5 to 2
    
    // Wait for update check to complete
    while (!_updateCheckComplete) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    widget.onSplashComplete();
  }

  Future<void> _checkForUpdates() async {
    try {
      // Check both flags in parallel
      final results = await Future.wait([
        AppUpdateService.checkAppUpdates(),
        AppUpdateService.checkForceUpdate(),
      ]);

      final hasAppUpdates = results[0];
      final isForceUpdate = results[1];

      // Note: Force update blocking is handled by ForceUpdateBlocker
      // We only show optional update dialog here
      if (hasAppUpdates && !isForceUpdate && mounted) {
        // Show optional update dialog after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => AppUpdateDialog(
              isForceUpdate: false,
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
      // Continue app launch even if update check fails
    } finally {
      if (mounted) {
        setState(() {
          _updateCheckComplete = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg, primary.withOpacity(0.12)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withOpacity(0.12),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.08),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.home, size: 64, color: primary),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                        AnimatedBuilder(
                      animation: _fadeController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                            child: Column(
                              children: [
                          Text(
                            'AA App',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 32,
                              color: primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                                    ),
                                  ),
                          const SizedBox(height: 8),
                          Text(
                            'Welcome to your smart experience',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: primary.withOpacity(0.7),
                                              fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                        strokeWidth: 3,
                          ),
                        );
                      },
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }
} 
