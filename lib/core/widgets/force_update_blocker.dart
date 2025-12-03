import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_update_service.dart';
import 'app_update_dialog.dart';

/// Widget that blocks the entire app if force_update is true
/// This widget MUST be placed at the root level to block all app functionality
class ForceUpdateBlocker extends StatefulWidget {
  final Widget child;

  const ForceUpdateBlocker({
    super.key,
    required this.child,
  });

  @override
  State<ForceUpdateBlocker> createState() => _ForceUpdateBlockerState();
}

class _ForceUpdateBlockerState extends State<ForceUpdateBlocker> {
  bool _isChecking = true;
  bool _isForceUpdate = false;
  bool _hasShownDialog = false;
  String? _currentVersion;
  List<String> _blockedVersions = [];

  @override
  void initState() {
    super.initState();
    _checkForceUpdate();
  }

  Future<void> _checkForceUpdate() async {
    try {
      // Get current version info
      final versionInfo = await AppUpdateService.getAppVersionInfo();
      _currentVersion = versionInfo.buildNumber;
      
      // FIRST: Check cached value immediately (works offline)
      final cachedForceUpdate = await AppUpdateService.getCachedForceUpdate();
      
      // Get blocked versions for display
      _blockedVersions = await AppUpdateService.getBlockedVersions();
      
      if (cachedForceUpdate) {
        // If cached value is true, block immediately
        setState(() {
          _isForceUpdate = true;
          _isChecking = false;
        });
        
        // Show blocking dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showForceUpdateDialog();
        });
        return;
      }

      // SECOND: Try to fetch from Firebase (if online)
      final forceUpdate = await AppUpdateService.checkForceUpdate();
      
      // Update blocked versions list
      _blockedVersions = await AppUpdateService.getBlockedVersions();
      
      setState(() {
        _isForceUpdate = forceUpdate;
        _isChecking = false;
      });

      if (forceUpdate) {
        // Show blocking dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showForceUpdateDialog();
        });
      }
    } catch (e) {
      print('Error in force update check: $e');
      // If Firebase check fails, use cached value
      final cachedForceUpdate = await AppUpdateService.getCachedForceUpdate();
      setState(() {
        _isForceUpdate = cachedForceUpdate;
        _isChecking = false;
      });
      
      if (cachedForceUpdate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showForceUpdateDialog();
        });
      }
    }
  }

  void _showForceUpdateDialog() {
    if (!_hasShownDialog && mounted) {
      _hasShownDialog = true;
      
      // Create custom message with version info
      String message = 'A critical update is required. Please update the app to continue.';
      if (_blockedVersions.isNotEmpty && _currentVersion != null) {
        final versionsText = _blockedVersions.join(', ');
        message = 'Your app version ($_currentVersion) is no longer supported. '
            'Blocked versions: $versionsText. Please update to the latest version.';
      }
      
      showDialog(
        context: context,
        barrierDismissible: false, // Cannot dismiss
        barrierColor: Colors.black87, // Dark overlay
        builder: (context) => WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: AppUpdateDialog(
            isForceUpdate: true,
            updateMessage: message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If force update is required, show blocking screen
    if (_isForceUpdate) {
      String versionInfo = '';
      if (_currentVersion != null) {
        versionInfo = 'Current Version: $_currentVersion';
      }
      if (_blockedVersions.isNotEmpty) {
        versionInfo += '\nBlocked Versions: ${_blockedVersions.join(", ")}';
      }
      
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.system_update_alt,
                  size: 80,
                  color: Colors.red[700],
                ),
                const SizedBox(height: 24),
                Text(
                  'Update Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Your app version is no longer supported. Please update to the latest version to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                if (versionInfo.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      versionInfo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If still checking, show loading
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // If no force update, show normal app
    return widget.child;
  }
}

