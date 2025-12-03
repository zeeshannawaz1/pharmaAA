import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateDialog extends StatelessWidget {
  final bool isForceUpdate;
  final String? updateMessage;
  final String? updateUrl;

  const AppUpdateDialog({
    super.key,
    required this.isForceUpdate,
    this.updateMessage,
    this.updateUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Prevent back button on force update
    if (isForceUpdate) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }

    return WillPopScope(
      onWillPop: () async {
        // Block back button if force update
        if (isForceUpdate) {
          // Show warning that update is required
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update is required to use the app'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          return false; // Prevent dismissal
        }
        return true; // Allow dismissal for optional updates
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: isForceUpdate ? Colors.red : Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isForceUpdate ? 'Update Required' : 'Update Available',
                style: TextStyle(
                  color: isForceUpdate ? Colors.red : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              updateMessage ??
                  (isForceUpdate
                      ? 'A critical update is required. The app cannot be used until you update to the latest version.'
                      : 'A new version of the app is available. Would you like to update now?'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            if (isForceUpdate) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This update is mandatory. The app is blocked until you update.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!isForceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Later',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => _openUpdateUrl(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isForceUpdate 
                  ? Colors.red 
                  : Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Update Now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUpdateUrl(BuildContext context) async {
    try {
      // Default to Play Store for Android
      final String url = updateUrl ??
          'https://play.google.com/store/apps/details?id=com.zeework.aadist';
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        // For force update, keep dialog open and show message
        if (isForceUpdate && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete the update and restart the app'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open update URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

