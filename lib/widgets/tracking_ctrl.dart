  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:geocoding/geocoding.dart';
  import 'package:geolocator/geolocator.dart';
  import '../Database/database_helper.dart';

  import '../Model/tracking_history.dart';
  import '../distance_tracking.dart';
import '../main.dart';

  class TrackingControls extends StatefulWidget {
    final VoidCallback? onUpdate;

    const TrackingControls({Key? key, this.onUpdate}) : super(key: key);

    @override
    State<TrackingControls> createState() => _TrackingControlsState();
  }

  class _TrackingControlsState extends State<TrackingControls> {
    final tracker = DistanceTracker();
    Timer? _uiTimer;

    // Store start/stop info for the current session
    double? _startLat;
    double? _startLng;
    String? _startAddress;

    @override
    void initState() {
      super.initState();
      _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {}); // update timer UI every second
      });
    }

    @override
    void dispose() {
      _uiTimer?.cancel();
      super.dispose();
    }

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final h = twoDigits(d.inHours);

      final m = twoDigits(d.inMinutes.remainder(60));
      final s = twoDigits(d.inSeconds.remainder(60));
      return "$h:$m:$s";
    }

    Future<String?> _reverseGeocode(double? lat, double? lng) async {
      if (lat == null || lng == null) return null;
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isEmpty) return null;
        final p = placemarks.first;
        final parts = <String?>[
          p.subLocality?.isNotEmpty == true ? p.subLocality : null,
          p.locality?.isNotEmpty == true ? p.locality : null,
          p.administrativeArea?.isNotEmpty == true ? p.administrativeArea : null,
          p.country?.isNotEmpty == true ? p.country : null,
        ]..removeWhere((e) => e == null);
        return parts.join(', ');
      } catch (_) {
        return null;
      }
    }



    @override
    Widget build(BuildContext context) {
      return Column(
        children: [

          // Text(
          //   'Time: ${formatDuration(tracker.elapsedTime)}',
          //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
         // const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              // Start Button – only show when not tracking and not paused
              if (!tracker.isTracking && !tracker.isPaused)
                startButton(
                  onStart: () async {
                    try {
                      // Capture start coords BEFORE starting the stream
                      final pos = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.best,
                        timeLimit: Duration(seconds: 20),
                      );
                      _startLat = pos.latitude;
                      _startLng = pos.longitude;
                      _startAddress = await _reverseGeocode(_startLat, _startLng);
                    } catch (_) {
                      // Fallbacks: last known, then tracker snapshot
                      try {
                        final last = await Geolocator.getLastKnownPosition();
                        if (last != null) {
                          _startLat = last.latitude;
                          _startLng = last.longitude;
                        } else {
                          final pos = tracker.currentPosition;
                          _startLat = pos?.latitude;
                          _startLng = pos?.longitude;
                        }
                      } catch (_) {
                        final pos = tracker.currentPosition;
                        _startLat = pos?.latitude;
                        _startLng = pos?.longitude;
                      }
                      _startAddress = await _reverseGeocode(_startLat, _startLng);
                    }
                    tracker.startTracking();
                    if (mounted) setState(() {});
                  },

                ),



              // Pause Button – show only when actively tracking (not paused)

              // Reset Button – show when either tracking or paused
              if (tracker.isTracking || tracker.isPaused)
                customButton(
                  onStart: () async {
                    tracker.stopTracking();
                    tracker.reset();
                    setState(() {});
                  }, text: 'Reset', bgColor: Color(0xff363636),
                  // style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  // child: const Text('Reset'),
                ),
              if (tracker.isTracking || tracker.isPaused)
                customButton(
                  onStart: () async {
                    tracker.stopTracking();

                    final now = DateTime.now();
                    final stopPos = tracker.currentPosition;
                    // Ensure we have a start address before saving
                    if (_startAddress == null && _startLat != null && _startLng != null) {
                      _startAddress = await _reverseGeocode(_startLat, _startLng);
                    }
                    final record = TrackingRecord(
                      distance: tracker.totalKm,
                      averageSpeed: tracker.averageSpeed,
                      topSpeed: tracker.topSpeed,
                      duration: tracker.elapsedTime,
                      timestamp: now.subtract(tracker.elapsedTime),
                      stopTimestamp: now,
                      startLat: _startLat,
                      startLng: _startLng,
                      startAddress: _startAddress,
                      stopLat: stopPos?.latitude,
                      stopLng: stopPos?.longitude,
                      stopAddress: await _reverseGeocode(stopPos?.latitude, stopPos?.longitude),
                    );

                    await DatabaseHelper().insertRecord(record);

                    tracker.reset();
                    setState(() {});
                  },
                  bgColor: Color(0xff68DAE4),
                 text: 'Stop',
                ),
              if (tracker.isTracking && !tracker.isPaused)
                customButton(
                  onStart: () {
                    tracker.pauseTracking();
                    setState(() {});
                  },
                  bgColor: Color(0xff363636),
                  text: 'Pause',
                ),

              // Resume Button – show only when paused
              if (tracker.isPaused)
                customButton(
                  onStart: () {
                    tracker.resumeTracking();
                    setState(() {});
                  },
                  bgColor: Color(0xff363636),
                  text: 'Resume',
                ),

            ],
          )


        ],
      );
    }
  }
  Widget _buildCustomButton(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
