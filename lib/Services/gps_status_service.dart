import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GpsStatusService extends ChangeNotifier {
  bool _isGpsEnabled = false;
  bool _isLocationPermissionGranted = false;
  bool _isLocationServiceEnabled = false;
  String _statusMessage = "Checking GPS status...";
  Timer? _refreshTimer;
  bool _isAutoRefreshEnabled = true;

  bool get isGpsEnabled => _isGpsEnabled;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  String get statusMessage => _statusMessage;

  // Check all GPS and location related statuses
  Future<void> checkAllStatuses() async {
    await Future.wait([
      _checkLocationService(),
      _checkLocationPermission(),
      _checkGpsStatus(),
    ]);
    notifyListeners();
  }

  // Check if location services are enabled
  Future<void> _checkLocationService() async {
    try {
      _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_isLocationServiceEnabled) {
        _statusMessage = "Location services are disabled. Please enable them in device settings.";
      }
    } catch (e) {
      _statusMessage = "Error checking location services: $e";
    }
  }

  // Check location permission status
  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      _isLocationPermissionGranted = status.isGranted;
      
      if (!_isLocationPermissionGranted) {
        if (status.isDenied) {
          _statusMessage = "Location permission denied. Please grant location permission.";
        } else if (status.isPermanentlyDenied) {
          _statusMessage = "Location permission permanently denied. Please enable in app settings.";
        }
      }
    } catch (e) {
      _statusMessage = "Error checking location permission: $e";
    }
  }

  // Check GPS status using Geolocator
  Future<void> _checkGpsStatus() async {
    try {
      if (_isLocationServiceEnabled && _isLocationPermissionGranted) {
        // Try to get current position to verify GPS is working
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );
        _isGpsEnabled = position != null;
        if (_isGpsEnabled) {
          _statusMessage = "GPS is working properly!";
        } else {
          _statusMessage = "GPS signal is weak or unavailable.";
        }
      } else {
        _isGpsEnabled = false;
        if (!_isLocationServiceEnabled) {
          _statusMessage = "Please enable location services first.";
        } else if (!_isLocationPermissionGranted) {
          _statusMessage = "Please grant location permission first.";
        }
      }
    } catch (e) {
      _isGpsEnabled = false;
      _statusMessage = "GPS error: $e";
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      _isLocationPermissionGranted = status.isGranted;
      notifyListeners();
      return _isLocationPermissionGranted;
    } catch (e) {
      _statusMessage = "Error requesting permission: $e";
      notifyListeners();
      return false;
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
      // Recheck status after returning from settings
      await Future.delayed(Duration(seconds: 1));
      await checkAllStatuses();
    } catch (e) {
      _statusMessage = "Error opening location settings: $e";
      notifyListeners();
    }
  }

  // Open app settings for permissions
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
      // Recheck status after returning from settings
      await Future.delayed(Duration(seconds: 1));
      await checkAllStatuses();
    } catch (e) {
      _statusMessage = "Error opening app settings: $e";
      notifyListeners();
    }
  }

  // Get a summary of all issues
  List<String> getIssues() {
    List<String> issues = [];
    
    if (!_isLocationServiceEnabled) {
      issues.add("Location services are disabled");
    }
    
    if (!_isLocationPermissionGranted) {
      issues.add("Location permission not granted");
    }
    
    if (!_isGpsEnabled && _isLocationServiceEnabled && _isLocationPermissionGranted) {
      issues.add("GPS signal is weak or unavailable");
    }
    
    return issues;
  }

  // Check if everything is working
  bool get isEverythingWorking => 
      _isLocationServiceEnabled && _isLocationPermissionGranted && _isGpsEnabled;

  // Start automatic refresh
  void startAutoRefresh({Duration? interval}) {
    final refreshInterval = interval ?? Duration(seconds: 5);
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
    }
    
    _refreshTimer = Timer.periodic(refreshInterval, (timer) {
      if (_isAutoRefreshEnabled) {
        checkAllStatuses();
      }
    });
  }

  // Stop automatic refresh
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Toggle auto refresh
  void toggleAutoRefresh() {
    _isAutoRefreshEnabled = !_isAutoRefreshEnabled;
    if (_isAutoRefreshEnabled) {
      startAutoRefresh();
    } else {
      stopAutoRefresh();
    }
    notifyListeners();
  }

  // Get auto refresh status
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
