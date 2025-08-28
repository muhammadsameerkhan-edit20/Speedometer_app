  import 'dart:async';

  import 'package:flutter/material.dart';
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
                  onStart: () {
                    tracker.startTracking();
                    setState(() {});
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

                    final record = TrackingRecord(
                      distance: tracker.totalKm,
                      averageSpeed: tracker.averageSpeed,
                      topSpeed: tracker.topSpeed,
                      duration: tracker.elapsedTime,
                      timestamp: DateTime.now(),
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
