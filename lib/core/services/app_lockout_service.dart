import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle app security lockout using OS authentication
/// This uses device PIN/biometric instead of account-based lockout
class AppLockoutService {
  static const String _lockoutKey = 'app_lockout_attempts';
  static const String _lockoutTimeKey = 'app_lockout_time';
  static const int _maxAttempts = 3;
  static const Duration _lockoutDuration = Duration(minutes: 30);

  final LocalAuthentication _localAuth = LocalAuthentication();
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if app is currently locked out
  Future<bool> isLockedOut() async {
    final lockoutTime = _prefs.getInt(_lockoutTimeKey) ?? 0;
    if (lockoutTime > 0) {
      final lockoutEndTime = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
      if (DateTime.now().isBefore(lockoutEndTime)) {
        return true;
      } else {
        // Lockout period expired, clear it
        await clearLockout();
        return false;
      }
    }
    return false;
  }

  /// Record a failed attempt (e.g., incorrect pastoral PIN)
  Future<void> recordFailedAttempt() async {
    final attempts = (_prefs.getInt(_lockoutKey) ?? 0) + 1;
    await _prefs.setInt(_lockoutKey, attempts);

    if (attempts >= _maxAttempts) {
      // Set lockout time
      final lockoutEndTime = DateTime.now().add(_lockoutDuration);
      await _prefs.setInt(_lockoutTimeKey, lockoutEndTime.millisecondsSinceEpoch);
    }
  }

  /// Get remaining lockout time in minutes
  int getRemainingLockoutMinutes() {
    final lockoutTime = _prefs.getInt(_lockoutTimeKey) ?? 0;
    if (lockoutTime > 0) {
      final lockoutEndTime = DateTime.fromMillisecondsSinceEpoch(lockoutTime);
      final remaining = lockoutEndTime.difference(DateTime.now());
      if (remaining.isNegative) return 0;
      return remaining.inMinutes;
    }
    return 0;
  }

  /// Attempt to unlock using device authentication
  /// Returns true if successfully authenticated
  Future<bool> authenticateWithDevice({
    required String localizedReason,
  }) async {
    try {
      // Check if device supports biometric/PIN authentication
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }

      // Get available biometric types
      // await _localAuth.getAvailableBiometrics();

      // Authenticate using device PIN/biometric
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          // Use device PIN as fallback if biometric fails
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false, // Allow PIN fallback
        ),
      );

      if (authenticated) {
        // Clear lockout on successful authentication
        await clearLockout();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }

  /// Clear lockout attempts and time
  Future<void> clearLockout() async {
    await _prefs.remove(_lockoutKey);
    await _prefs.remove(_lockoutTimeKey);
  }

  /// Get current attempt count
  int getCurrentAttempts() {
    return _prefs.getInt(_lockoutKey) ?? 0;
  }

  /// Get remaining attempts before lockout
  int getRemainingAttempts() {
    final current = getCurrentAttempts();
    return _maxAttempts - current;
  }
}

/// Example usage in a screen
class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final AppLockoutService _lockoutService = AppLockoutService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _lockoutService.init();
  }

  Future<void> _attemptUnlock() async {
    setState(() => _isAuthenticating = true);

    final unlocked = await _lockoutService.authenticateWithDevice(
      localizedReason: 'Please authenticate to unlock Everyday Christian app',
    );

    setState(() => _isAuthenticating = false);

    if (unlocked) {
      // Navigate to main app
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: 24),
            const Text(
              'App is locked',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: Future.value(_lockoutService.getRemainingLockoutMinutes()),
              builder: (context, snapshot) {
                final minutes = snapshot.data ?? 0;
                if (minutes > 0) {
                  return Text(
                    'Try again in $minutes minutes or use device authentication',
                    textAlign: TextAlign.center,
                  );
                }
                return const Text('Use device authentication to unlock');
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isAuthenticating ? null : _attemptUnlock,
              icon: const Icon(Icons.fingerprint),
              label: Text(_isAuthenticating ? 'Authenticating...' : 'Unlock with PIN/Biometric'),
            ),
          ],
        ),
      ),
    );
  }
}