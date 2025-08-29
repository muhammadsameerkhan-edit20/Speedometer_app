import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GpsStatusService extends ChangeNotifier with WidgetsBindingObserver {
  bool _isGpsEnabled = false;
  bool _isLocationPermissionGranted = false;
  bool _isLocationServiceEnabled = false;
  String _statusMessage = "Checking GPS status...";
  Timer? _refreshTimer;
  bool _isAutoRefreshEnabled = true;
  bool _isInitialized = false;

  bool get isGpsEnabled => _isGpsEnabled;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  String get statusMessage => _statusMessage;

  // Initialize the service
  void initialize() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(this);
      _isInitialized = true;
      print("GPS Status Service initialized");
      // Do an initial check
      checkAllStatuses();
    }
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground, recheck all statuses with a slight delay
      print("App resumed - rechecking GPS status");
      Future.delayed(Duration(milliseconds: 500), () {
        checkAllStatuses();
      });
    }
  }

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
      print("Location service enabled: $_isLocationServiceEnabled");
      if (!_isLocationServiceEnabled) {
        _statusMessage = "Location services are disabled. Please enable them in device settings.";
      }
    } catch (e) {
      print("Error checking location service: $e");
      _statusMessage = "Error checking location services: $e";
    }
  }

  // Check location permission status
  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      _isLocationPermissionGranted = status.isGranted;
      print("Location permission granted: $_isLocationPermissionGranted (status: $status)");
      
      if (!_isLocationPermissionGranted) {
        if (status.isDenied) {
          _statusMessage = "Location permission denied. Please grant location permission.";
        } else if (status.isPermanentlyDenied) {
          _statusMessage = "Location permission permanently denied. Please enable in app settings.";
        }
      }
    } catch (e) {
      print("Error checking location permission: $e");
      _statusMessage = "Error checking location permission: $e";
    }
  }

  // Check GPS status using Geolocator
  Future<void> _checkGpsStatus() async {
    try {
      print("Checking GPS status - Location service: $_isLocationServiceEnabled, Permission: $_isLocationPermissionGranted");
      
      if (_isLocationServiceEnabled && _isLocationPermissionGranted) {
        // Try to get current position to verify GPS is working
        print("Attempting to get current position...");
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        );
        _isGpsEnabled = position != null;
        print("GPS position obtained: $_isGpsEnabled, Position: $position");
        
        if (_isGpsEnabled) {
          _statusMessage = "GPS is working properly!";
        } else {
          _statusMessage = "GPS signal is weak or unavailable.";
        }
      } else {
        _isGpsEnabled = false;
        print("GPS disabled - Location service: $_isLocationServiceEnabled, Permission: $_isLocationPermissionGranted");
        if (!_isLocationServiceEnabled) {
          _statusMessage = "Please enable location services first.";
        } else if (!_isLocationPermissionGranted) {
          _statusMessage = "Please grant location permission first.";
        }
      }
    } catch (e) {
      _isGpsEnabled = false;
      print("GPS error: $e");
      if (e.toString().contains('Location service is disabled')) {
        _statusMessage = "Location services are disabled. Please enable them in device settings.";
      } else if (e.toString().contains('Location permission denied')) {
        _statusMessage = "Location permission denied. Please grant location permission.";
      } else {
        _statusMessage = "GPS error: $e";
      }
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
      // The status will be rechecked when app resumes via lifecycle observer
    } catch (e) {
      _statusMessage = "Error opening location settings: $e";
      notifyListeners();
    }
  }

  // Open app settings for permissions
  Future<void> openAppSettings() async {
    try {
      await Permission.location.request();
      // The status will be rechecked when app resumes via lifecycle observer
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

  // Manual test method for debugging
  Future<void> testGpsStatus() async {
    print("=== GPS Status Test ===");
    print("Location service enabled: $_isLocationServiceEnabled");
    print("Location permission granted: $_isLocationPermissionGranted");
    print("GPS enabled: $_isGpsEnabled");
    print("Status message: $_statusMessage");
    
    // Force a fresh check
    await checkAllStatuses();
    
    print("=== After fresh check ===");
    print("Location service enabled: $_isLocationServiceEnabled");
    print("Location permission granted: $_isLocationPermissionGranted");
    print("GPS enabled: $_isGpsEnabled");
    print("Status message: $_statusMessage");
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}
