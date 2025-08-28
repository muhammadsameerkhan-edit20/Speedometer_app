import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';




class SpeedAlertHelper {

  static final AudioPlayer _player = AudioPlayer();
  static bool _isDialogShowing = false;

  /// Show speed alert dialog with audio, vibration, and auto-dismiss.
  static Future<void> showSpeedAlert({
    required BuildContext context,
    required double speed,
    required double speedLimit,
    String soundPath = 'sounds/warning.mp3',
    bool vibrate = true,
    bool autoDismiss = false,
    Duration dismissAfter = const Duration(seconds: 5),
  }) async {
    if (_isDialogShowing) return;


    _isDialogShowing = true;

    // Play sound
    await _player.play(AssetSource(soundPath));

    // Trigger vibration (if supported)
    if (vibrate && await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }

    // Show alert dialog
    showDialog(
      context: context,
      barrierDismissible: !autoDismiss,
      builder: (ctx) => AlertDialog(
        title: const Text("⚠️ Speed Limit Exceeded"),
        content: Text(
          "Your speed is ${speed.toStringAsFixed(1)} km/h which exceeds the limit of $speedLimit km/h!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              _player.stop();
              Navigator.of(ctx).pop();
              _isDialogShowing = false;
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    // Auto-dismiss after timeout
    if (autoDismiss) {
      Future.delayed(dismissAfter, () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          _player.stop();
          _isDialogShowing = false;
        }
      });
    }
  }
}
