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

import 'Database/database_helper.dart';


import 'Services/SpeedAlertHelper.dart';
import 'distance_tracking.dart';

import 'main.dart';
import 'meter_with_timer.dart';
import 'gauge_selection_screen.dart';
import 'widgets/newguage.dart';
import 'widgets/custom_gauge.dart';
import 'widgets/digital_speedometer.dart';


class SpeedometerScreen extends StatefulWidget {
  @override
  _SpeedometerScreenState createState() => _SpeedometerScreenState();
}

class _SpeedometerScreenState extends State<SpeedometerScreen> {
  double _speed = 0.0; // in m/s
  String status = 'Idle';
  int _speedLimit = 200; // default fallback
  bool _alertShown = false;

  final tracker = DistanceTracker();
  double _distance = 0.0;
  Duration _elapsedTime = Duration.zero;
  Timer? _uiTimer;
  int _selectedGaugeType = 0; // 0: Default, 1: Custom, 2: Digital, 3: Enhanced
  double _gaugeRotation = 0.0; // Rotation angle for the gauge

  @override
  void initState() {

    super.initState();
    _loadSpeedLimit();
    _loadGaugePreference();
    _setupTrackerListener();
    tracker.onSpeedChanged = _handleSpeedChange;
    _checkPermissions();
    // Future.delayed(Duration(seconds: 3), () {
    //   _handleSpeedChange(300); // Triggers alert with simulated speed
    // });

    _startUITimer();
  }

  Future<void> _loadGaugePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGaugeType = prefs.getInt('selectedGaugeIndex') ?? 0;
      _gaugeRotation = prefs.getDouble('gaugeRotation') ?? 0.0;
    });
  }

  Future<void> _saveGaugePreference(int gaugeType, double rotation) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedGaugeIndex', gaugeType);
    await prefs.setDouble('gaugeRotation', rotation);
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

  // Helper method to get digit at specific position for odometer display
  String _getDigitAt(int position, double value) {
    // Convert to integer and pad with leading zeros to 5 digits
    int intValue = value.toInt();
    String paddedValue = intValue.toString().padLeft(5, '0');
    
    // Ensure we don't go out of bounds
    if (position < paddedValue.length) {
      return paddedValue[paddedValue.length - 1 - position];
    }
    return '0';
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
    Widget gaugeWidget;

    switch (_selectedGaugeType) {
      case 0: // Default Gauge
        gaugeWidget = SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 180,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: 60, color: Colors.green),
                GaugeRange(startValue: 60, endValue: 120, color: Colors.orange),
                GaugeRange(startValue: 120, endValue: 180, color: Colors.red),
              ],
              pointers: <GaugePointer>[NeedlePointer(value: _speed)],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${_speed.toStringAsFixed(1)} km/h',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        );
        break;

      case 1: // Custom Gauge
        gaugeWidget = CustomPaint(
          size: Size(300, 300),
          painter: GaugePainter(_speed),
        );
        break;

      case 2: // Digital Speedometer
        gaugeWidget = Container(
          height: 300,
          width: 300,
          child: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: DigitalSpeedometer(
                speed: _speed,
                totalDistance: _distance,
              ),
            ),
          ),
        );
        break;

      case 3: // Enhanced Gauge
        gaugeWidget = Container(
          height: 300,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: _speed,
                    lengthUnit: GaugeSizeUnit.factor,
                    needleLength: 0.8,
                    needleEndWidth: 11,
                    tailStyle: TailStyle(
                      length: 0.2,
                      width: 11,
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFFFF6B78),
                          Color(0xFFFF6B78),
                          Color(0xFFE20A22),
                          Color(0xFFE20A22),
                        ],
                        stops: <double>[0, 0.5, 0.5, 1],
                      ),
                    ),
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFFFF6B78),
                        Color(0xFFFF6B78),
                        Color(0xFFE20A22),
                        Color(0xFFE20A22),
                      ],
                      stops: <double>[0, 0.5, 0.5, 1],
                    ),
                    needleColor: Color(0xFFF67280),
                    knobStyle: KnobStyle(
                      knobRadius: 0.08,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        break;

      default:
        gaugeWidget = SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 180,
              pointers: <GaugePointer>[NeedlePointer(value: _speed)],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${_speed.toStringAsFixed(1)} km/h',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        );
    }

    // Apply rotation if not zero
    if (_gaugeRotation != 0.0) {
      return Transform.rotate(angle: _gaugeRotation, child: gaugeWidget);
    }

    return gaugeWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: AppBar(
      //   title: Text('Speedometer'),
      //   backgroundColor: Colors.blue,
      //   foregroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       onPressed: () async {
      //         final result = await Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => GaugeSelectionScreen(),
      //           ),
      //         );
      //         if (result != null) {
      //           setState(() {
      //             _selectedGaugeType = result['gaugeIndex'];
      //             _gaugeRotation = result['rotation'];
      //           });
      //           await _saveGaugePreference(_selectedGaugeType, _gaugeRotation);
      //         }
      //       },
      //       icon: Icon(Icons.tune),
      //       tooltip: 'Select Gauge Style',
      //     ),
      //
      //     IconButton(
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => RotatedGaugeFullscreenPage(
      //               speed: _speed,
      //               gaugeType: _selectedGaugeType,
      //               rotation: _gaugeRotation,
      //               distance: _distance,
      //             ),
      //           ),
      //         );
      //       },
      //       icon: Icon(Icons.rotate_right),
      //       tooltip: 'Fullscreen Rotated Gauge',
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff141414),
                  border: Border.all(
                    color: Color(0xff68DAE4), // Border color
                    width: 2.0,
                  ),
                ),
                height: 300,
                child: Stack(
                  children: [
                    // Main gauge
                    Center(
                      child: Container(
                        color: Colors.transparent,
                        width: 400,
                        height: 250,
                        child: _buildGauge(),
                      ),
                    ),
                    // Small odometer overlay at left bottom
                    Positioned(
                      bottom: 20,
                      left: 15,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // Distance display
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Small digits
                                ...List.generate(5, (index) {
                                  String digit = _getDigitAt(index, tracker.totalKm);
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 1),
                                    child: Text(
                                      digit,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Digital',
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  );
                                }),
                                SizedBox(width: 4),
                                Text(
                                  'km',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            // Trip distance
                            Text(
                              'Trip: ${_distance.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //SizedBox(height: 10),
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
                        TripStatsCard(duration:'${formatDuration(tracker.elapsedTime)}', distance:  '${DistanceTracker().totalKm.toStringAsFixed(2)}', avgSpeed: '${DistanceTracker().averageSpeed.toStringAsFixed(0)} ', topSpeed: '${DistanceTracker().topSpeed.toStringAsFixed(0)} '),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10,0,10,10),
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
          ],
        ),
      ),
    );
  }
}

class RotatedGaugeFullscreenPage extends StatefulWidget {
  final double speed;
  final int gaugeType;
  final double rotation;
  final double distance;

  const RotatedGaugeFullscreenPage({
    Key? key,
    required this.speed,
    required this.gaugeType,
    required this.rotation,
    required this.distance,
  }) : super(key: key);

  @override
  State<RotatedGaugeFullscreenPage> createState() =>
      _RotatedGaugeFullscreenPageState();
}

class _RotatedGaugeFullscreenPageState
    extends State<RotatedGaugeFullscreenPage> {
  double currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    currentRotation = widget.rotation;
  }

  Widget _buildFullscreenGauge() {
    Widget gaugeWidget;

    switch (widget.gaugeType) {
      case 0: // Default Gauge
        gaugeWidget = SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 180,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: 60, color: Colors.green),
                GaugeRange(startValue: 60, endValue: 120, color: Colors.orange),
                GaugeRange(startValue: 120, endValue: 180, color: Colors.red),
              ],
              pointers: <GaugePointer>[NeedlePointer(value: widget.speed)],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${widget.speed.toStringAsFixed(1)} km/h',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        );
        break;

      case 1: // Custom Gauge
        gaugeWidget = CustomPaint(
          size: Size(400, 400),
          painter: GaugePainter(widget.speed),
        );
        break;

      case 2: // Digital Speedometer
        gaugeWidget = DigitalSpeedometer(
          speed: widget.speed,
          totalDistance: widget.distance,
        );
        break;

      case 3: // Enhanced Gauge
        gaugeWidget = CustomSpeedometerGauge(speed: widget.speed);
        break;

      default:
        gaugeWidget = SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 180,
              pointers: <GaugePointer>[NeedlePointer(value: widget.speed)],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${widget.speed.toStringAsFixed(1)} km/h',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

    return Transform.rotate(angle: currentRotation, child: gaugeWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rotated Gauge View',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                currentRotation -= 0.1;
              });
            },
            icon: Icon(Icons.rotate_left, color: Colors.white),
            tooltip: 'Rotate Left',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                currentRotation = 0.0;
              });
            },
            icon: Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reset Rotation',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                currentRotation += 0.1;
              });
            },
            icon: Icon(Icons.rotate_right, color: Colors.white),
            tooltip: 'Rotate Right',
          ),
        ],
      ),
      body: Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _buildFullscreenGauge(),
          ),
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
