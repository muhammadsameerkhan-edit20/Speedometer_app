import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedo_meter/widgets/stat_row.dart';
import 'package:speedo_meter/widgets/tracking_ctrl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../Database/database_helper.dart';
import '../Services/SpeedAlertHelper.dart';
import '../distance_tracking.dart';
import '../gauge_selection_screen.dart';
import '../meter_with_timer.dart';
import 'custom_gauge.dart';
import 'digital_speedometer.dart';
import 'newguage.dart';


class SpeedometerScreen2 extends StatefulWidget {
  @override
  _SpeedometerScreen2State createState() => _SpeedometerScreen2State();
}

class _SpeedometerScreen2State extends State<SpeedometerScreen2> {
  double _speed = 0.0; // in m/s
  String status = 'Idle';
  int _speedLimit = 200; // default fallback
  bool _alertShown = false;
  final tracker = DistanceTracker();
  double _distance = 0.0;
  Duration _elapsedTime = Duration.zero;
  Timer? _uiTimer;
  int _selectedGaugeType = 0; // 0: Default, 1: Custom, 2: Digital, 3: Enhanced

  @override
  void initState() {
    super.initState();
    _loadSpeedLimit();
    _loadGaugePreference();
    _setupTrackerListener();
    tracker.onSpeedChanged = _handleSpeedChange;
    _checkPermissions();
    _startUITimer();
  }

  Future<void> _loadGaugePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGaugeType = prefs.getInt('selectedGaugeIndex') ?? 0;
    });
  }

  Future<void> _saveGaugePreference(int gaugeType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedGaugeType', gaugeType);
  }

  void _setupTrackerListener() {
    tracker.onSpeedChanged = (double speed) {
      if (!mounted) return;
      setState(() {
        _speed = speed;
      });
    };
  }

  Future<void> _loadSpeedLimit() async {
    final dbLimit = await DatabaseHelper().getSpeedLimit();
    setState(() {
      _speedLimit = dbLimit.toInt();
    });
  }

  void _handleSpeedChange(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    final isAlertEnabled = prefs.getBool('isSpeedAlertEnabled') ?? true;

    if (!mounted) return;

    setState(() {
      _speed = speed;
    });

    if (isAlertEnabled && speed > _speedLimit && !_alertShown) {
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

  Future<void> _checkPermissions() async {
    await Permission.locationWhenInUse.request();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  void _startUITimer() {
    _uiTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _distance = tracker.totalKm;
        _elapsedTime = tracker.elapsedTime;
      });
    });
  }

  Widget _buildGauge() {
    switch (_selectedGaugeType) {
      case 0: // Default Gauge
        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 180,
              ranges: <GaugeRange>[
                GaugeRange(
                  startValue: 0,
                  endValue: 60,
                  color: Colors.green,
                ),
                GaugeRange(
                  startValue: 60,
                  endValue: 120,
                  color: Colors.orange,
                ),
                GaugeRange(
                  startValue: 120,
                  endValue: 180,
                  color: Colors.red,
                ),
              ],
              pointers: <GaugePointer>[NeedlePointer(value: _speed)],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${_speed.toStringAsFixed(1)} km/h',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        );

      case 1: // Custom Gauge
        return CustomPaint(
          size: Size(300, 300),
          painter: GaugePainter(_speed),
        );

      case 2: // Digital Speedometer
        return DigitalSpeedometer(
          speed: _speed,
          totalDistance: _distance,
        );

      case 3: // Enhanced Gauge
        return CustomSpeedometerGauge(speed: _speed);

      default:
        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 180,
              pointers: <GaugePointer>[NeedlePointer(value: _speed)],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${_speed.toStringAsFixed(1)} km/h',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speedometer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GaugeSelectionScreen(),
                ),
              );
              if (result != null) {
                setState(() {
                  _selectedGaugeType = result;
                });
                await _saveGaugePreference(result);
              }
            },
            icon: Icon(Icons.tune),
            tooltip: 'Select Gauge Style',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullscreenGaugePage(speed: _speed),
                ),
              );
            },
            icon: Icon(Icons.crop_rotate),
            tooltip: 'Fullscreen View',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                height: 350,
                child: _buildGauge(),
              ),
            ),
            SizedBox(height: 10),

            Column(
              children: [
                StatRow(
                  title1: 'Distance',
                  value1: '${DistanceTracker().totalKm.toStringAsFixed(2)} km',
                  title2: 'Top Speed',
                  value2:
                  '${DistanceTracker().topSpeed.toStringAsFixed(1)} km/h',
                ),
                StatRow(
                  title1: 'Avg Speed',
                  value1:
                  '${DistanceTracker().averageSpeed.toStringAsFixed(1)} km/h',
                  title2: 'Duration',
                  value2: 'Time: ${formatDuration(tracker.elapsedTime)}',
                ),
              ],
            ),

            SizedBox(height: 10),

            TrackingControls(
              onUpdate: () {
                setState(() {

                  _distance = tracker.totalKm;
                  _elapsedTime = tracker.elapsedTime;

                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Mycard extends StatelessWidget {
  String name;
  final String imagePath;
  Color color;
  Mycard({required this.imagePath, required this.color, required this.name});


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: Color(0xFFF1F4FF),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF1F4FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Color(0xffA9BBE1), // stroke color
            width: 2.0, // stroke width
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Shadow color
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 40,
              width: 40,
              // optional tint
            ),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Color(0xff1A2B7E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}