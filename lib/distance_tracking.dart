// lib/distance_tracker.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';

enum TrackingState { stopped, running, paused }

class DistanceTracker {
  static final DistanceTracker _instance = DistanceTracker._internal();
  factory DistanceTracker() => _instance;
  DistanceTracker._internal();

  double totalDistance = 0.0;
  Position? lastPosition;
  bool _isTracking = false;
  double _currentSpeed = 0.0;
  double get currentSpeed => _currentSpeed;
  double _topSpeed = 0.0;
  double _averageSpeed = 0.0;
  int _speedSampleCount = 0;
  double get topSpeed => _topSpeed;
  double get averageSpeed => _averageSpeed;
  bool get isTracking => _state == TrackingState.running;
  bool get isPaused => _state == TrackingState.paused;
  bool get isStopped => _state == TrackingState.stopped;


  // A callback to notify UI
  void Function(double)? onSpeedChanged;

  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _subscription;
  TrackingState _state = TrackingState.stopped;
  double get totalKm => totalDistance / 1000;
  Position? get currentPosition => lastPosition;



  Duration elapsedTime = Duration.zero;

  Timer? _timer;

  // Start tracking + start timer
  void startTracking() async{
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return;
      }
    }


    if (permission == LocationPermission.deniedForever) {
      print('Location permission permanently denied');
      await Geolocator.openAppSettings();
      return;
    }
    // if (_isTracking) return;
    // _isTracking = true;
    if (_state == TrackingState.running) return;
    _state = TrackingState.running;

    _startTimer();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    );
    _subscription = _positionStream!.listen((Position position) {
      if (lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          lastPosition!.latitude,
          lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        // Ignore small GPS noise
        if (distance > 5) {
          totalDistance += distance;
        }
      }

      lastPosition = position;

      _currentSpeed = position.speed * 3.6;

      // Filter out small speed fluctuations
      if (_currentSpeed < 1.5) {
        _currentSpeed = 0.0;
      }

      // Top speed
      if (_currentSpeed > _topSpeed) {
        _topSpeed = _currentSpeed;
      }

      // Avg speed
      _speedSampleCount++;
      _averageSpeed =
          ((_averageSpeed * (_speedSampleCount - 1)) + _currentSpeed) / _speedSampleCount;

      onSpeedChanged?.call(_currentSpeed);
    });

//     _subscription = _positionStream!.listen((Position position) {
//       if (lastPosition != null) {
//         final distance = Geolocator.distanceBetween(
//           lastPosition!.latitude,
//           lastPosition!.longitude,
//           position.latitude,
//           position.longitude,
//         );
//         totalDistance += distance;
//       }
//
//       lastPosition = position;
//
//       _currentSpeed = position.speed * 3.6; // convert to km/h
//
// // Update top speed
//       if (_currentSpeed > _topSpeed) {
//         _topSpeed = _currentSpeed;
//       }
//
// // Update average speed
//       _speedSampleCount++;
//       _averageSpeed = ((_averageSpeed * (_speedSampleCount - 1)) + _currentSpeed) / _speedSampleCount;
//
//       onSpeedChanged?.call(_currentSpeed);
// // convert to km/h for gauge
//     });

  }

  void _startTimer() {
    _timer ??= Timer.periodic(Duration(seconds: 1), (_) {
      elapsedTime += Duration(seconds: 1);
    });
  }

  void pauseTracking() {
    if (_state != TrackingState.running) return;

    _state = TrackingState.paused;
    _subscription?.pause();
    _timer?.cancel();
    _timer = null;
  }


  void resumeTracking() {
    if (_state != TrackingState.paused) return;

    _state = TrackingState.running;
    _subscription?.resume();
    _startTimer();
  }


  void stopTracking() {
    _state = TrackingState.stopped;
    _subscription?.cancel();
    _subscription = null;
    _timer?.cancel();
    _timer = null;
  }


  void reset() {
    totalDistance = 0.0;
    lastPosition = null;
    elapsedTime = Duration.zero;
    _currentSpeed = 0.0;
    _topSpeed = 0.0;
    _averageSpeed = 0.0;
    _speedSampleCount = 0;
  }


}
