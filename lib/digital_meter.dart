import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speedo_meter/widgets/stat_row.dart';
import 'package:speedo_meter/widgets/tracking_ctrl.dart';
import 'Database/database_helper.dart';
import 'Services/SpeedAlertHelper.dart';
import 'distance_tracking.dart';
import 'main.dart';
import 'meter_with_timer.dart';

class DigitalSpeedScreen extends StatefulWidget {
  @override
  _DigitalSpeedScreenState createState() => _DigitalSpeedScreenState();
}

class _DigitalSpeedScreenState extends State<DigitalSpeedScreen> {
  double _speed = 0.0;
  double _distance = 0.0;
  Duration _elapsedTime = Duration.zero; // in m/s
  String status = 'Idle';
  int _speedLimit = 200; // default fallback
  bool _alertShown = false;
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndSetup();
    _setupTrackerListener();
    _startUITimer();
    final tracker = DistanceTracker();
    _loadSpeedLimit();
    tracker.onSpeedChanged = _handleSpeedChange;
    // Manually simulate high speed to test alert
    // Future.delayed(Duration(seconds: 2), () {
    //   _handleSpeedChange(
    //     950,
    //   ); // This should trigger the alert if speedLimit < 250
    // });
  }

  Future<void> _loadSpeedLimit() async {
    final dbLimit = await DatabaseHelper().getSpeedLimit();
    setState(() {
      _speedLimit = dbLimit.toInt();
      print(_speedLimit);
    });
  }

  void _handleSpeedChange(double speed) {
    if (!mounted) return;

    setState(() {
      _speed = speed;
    });

    if (speed > _speedLimit && !_alertShown) {
      _alertShown = true;
      SpeedAlertHelper.showSpeedAlert(
        context: context,
        speed: speed,
        speedLimit: _speedLimit.toDouble(),
        vibrate: true,
        autoDismiss: true, // Will dismiss after 5 seconds
        soundPath: 'sounds/warning.mp3',
      );
    }

    if (speed <= _speedLimit) {
      _alertShown = false;
    }
  }

  void _setupTrackerListener() {
    final tracker = DistanceTracker();

    tracker.onSpeedChanged = (double speed) {
      if (!mounted) return;
      setState(() {
        _speed = speed;
      });
    };
  }

  void _requestPermissionAndSetup() async {
    await Permission.locationWhenInUse.request();
  }

  void _startUITimer() {
    _uiTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!mounted) return;
      final tracker = DistanceTracker();
      setState(() {
        _distance = tracker.totalKm;
        _elapsedTime = tracker.elapsedTime;
      });
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracker = DistanceTracker();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff141414),
                  border: Border.all(
                    color: Color(0xff68DAE4), // Border color
                    width: 2.0,
                  ),

                ),

                height: 300,
                child: Center(


                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.cyanAccent,
                            width: 4,
                          ),
                        ),

                        child: Center(
                          child: Text(
                            '${_speed.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'Digital',
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff68DAE4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Color(0xff363636),
                        ),
                        child: Center(
                          child: Text(
                            'Km/h',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff141414),
                  border: Border.all(
                    color: Color(0xff68DAE4), // Border color
                    width: 2.0,
                  ),
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        TripStatsCard(
                          duration: '${_formatDuration(tracker.elapsedTime)}',
                          distance:
                              '${DistanceTracker().totalKm.toStringAsFixed(2)}',
                          avgSpeed:
                              '${DistanceTracker().averageSpeed.toStringAsFixed(0)}',
                          topSpeed:
                              '${DistanceTracker().topSpeed.toStringAsFixed(0)}',
                        ),
                        // StatRow(
                        //   title1: 'Distance',
                        //   value1:
                        //       '${DistanceTracker().totalKm.toStringAsFixed(2)} km',
                        //   title2: 'Top Speed',
                        //   value2:
                        //       '${DistanceTracker().topSpeed.toStringAsFixed(1)} km/h',
                        // ),
                        // StatRow(
                        //   title1: 'Avg Speed',
                        //   value1:
                        //       '${DistanceTracker().averageSpeed.toStringAsFixed(1)} km/h',
                        //   title2: 'Duration',
                        //   value2: 'Time: ${formatDuration(tracker.elapsedTime)}',
                        // ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: TrackingControls(
                        onUpdate: () {
                          setState(() {
                            _distance = tracker.totalKm;
                            _elapsedTime = tracker.elapsedTime;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 20),
            // Column(
            //   children: [
            //     // StatRow(
            //     //   title1: 'Distance',
            //     //   value1: '${DistanceTracker().totalKm.toStringAsFixed(2)} km',
            //     //   title2: 'Top Speed',
            //     //   value2: '${DistanceTracker().topSpeed.toStringAsFixed(1)} km/h',
            //     // ),
            //     // StatRow(
            //     //   title1: 'Avg Speed',
            //     //   value1: '${DistanceTracker().averageSpeed.toStringAsFixed(1)} km/h',
            //     //   title2: 'Duration',
            //     //   value2: 'Time: ${_formatDuration(tracker.elapsedTime)}',
            //     // ),
            //   ],
            // ),
            // SizedBox(height: 20),
            // TrackingControls(
            //   onUpdate: () {
            //     setState(() {
            //       _distance = tracker.totalKm;
            //       _elapsedTime = tracker.elapsedTime;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(duration.inHours);
    final m = twoDigits(duration.inMinutes.remainder(60));
    final s = twoDigits(duration.inSeconds.remainder(60));
    return "$h:$m:$s";
  }
}
