import 'dart:developer';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
class LocationService {


  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log("Location services are disabled.");
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        log("Location permission denied, requesting...");
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log("Location permission not granted.");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log("Location permission permanently denied.");
        return null;
      }

      // Get current position with timeout and high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );
    } catch (e) {
      log("Error getting location: $e");
      return null;
    }
  }
  Future<Map<String, String>> getAddressFromLatLng(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      return {
        "address": '${place.street}, ${place.locality}, ${place.country}',
        "city": place.locality ?? "Unknown City",
      };
    } catch (e) {
      log("Error getting address: $e");
      return {
        "address": "Unknown Address",
        "city": "Unknown City",
      };
    }
  }
}
