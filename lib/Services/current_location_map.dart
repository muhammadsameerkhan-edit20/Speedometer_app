import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../distance_tracking.dart';
import '../main.dart';
import '../widgets/stat_row.dart';
import '../widgets/tracking_ctrl.dart';

class CurrentLocationMap extends StatefulWidget {
  const CurrentLocationMap({Key? key}) : super(key: key);

  @override
  State<CurrentLocationMap> createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<CurrentLocationMap>
    with WidgetsBindingObserver {
  late GoogleMapController _mapController;
  final Map<String, Marker> _markers = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observe app lifecycle
    print("CurrentLocationMap initialized");
    _getCurrentLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If app comes back from background (e.g., after opening settings)
    if (state == AppLifecycleState.resumed && _currentPosition == null) {
      _getCurrentLocation(); // Retry fetching location
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      print("Getting current location...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("Location service enabled: $serviceEnabled");

      if (!serviceEnabled) {
        print("Location service disabled, showing dialog");
        // Show dialog to open location settings
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Location Disabled"),
              content: const Text("Please enable location services to use the map."),
              actions: [
                TextButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                    Navigator.of(context).pop();
                    // Retry getting location after returning from settings
                    await Future.delayed(Duration(seconds: 2));
                    _getCurrentLocation();
                  },
                  child: const Text("Open Settings"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print("Location permission: $permission");
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print("Requested permission: $permission");
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permission denied.")),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission permanently denied.")),
          );
        }
        return;
      }

          try {
            print("Attempting to get current position...");
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 20),
            );
            print("Position obtained: ${position.latitude}, ${position.longitude}");
            
            if (mounted) {
              setState(() {
                _currentPosition = position;
                _markers['currentLocation'] = Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(position.latitude, position.longitude),
                  infoWindow: const InfoWindow(title: 'You are here'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                );
              });
              await _getAddressFromLatLng(position);
            }
          } catch (e) {
            print("Error getting current location: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error getting location: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          print("Error in location service: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Location service error: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
  }

  String? _currentAddress;
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      print("Fetching address for: ${position.latitude}, ${position.longitude}");
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;
      print("Placemark: $place");

      if (mounted) {
        setState(() {
          // Create a cleaner address format
          List<String> addressParts = [];
          
          if (place.subLocality?.isNotEmpty == true) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality?.isNotEmpty == true) {
            addressParts.add(place.locality!);
          }
          if (place.administrativeArea?.isNotEmpty == true) {
            addressParts.add(place.administrativeArea!);
          }
          if (place.country?.isNotEmpty == true) {
            addressParts.add(place.country!);
          }
          
          _currentAddress = addressParts.join(", ");
          print("Formatted address: $_currentAddress");
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "Unable to fetch address.";
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final tracker = DistanceTracker();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _getCurrentLocation(),
            heroTag: "refresh",
            backgroundColor: Color(0xff68DAE4),
            child: const Icon(Icons.refresh, color: Colors.black),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    14,
                  ),
                );
              }
            },
            heroTag: "location",
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
              child: Container(
                width: double.infinity,
                height: 300.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff141414),
                  border: Border.all(
                    color: Color(0xff68DAE4), // Border color
                    width: 2.0,
                  ),
                ),
                child: _currentPosition == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xff68DAE4),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Loading map...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Please ensure location services are enabled",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _getCurrentLocation(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff68DAE4),
                                foregroundColor: Colors.black,
                              ),
                              child: Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            zoom: 14,
                          ),
                          markers: _markers.values.toSet(),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                          mapType: MapType.normal,
                        ),
                      ),

              ),
            ),

            Column(


              children: [
                if (_currentAddress != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xff141414),

                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Color(0xff68DAE4), // Border color
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Location icon
                          Container(
                            width: 40,
                            height: 40,
                            child: Image.asset(
                              "assets/loc_mark/loc_mark.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          
                          SizedBox(width: 12),
                          
                          // Address text
                          Expanded(
                            child: Text(
                              _currentAddress!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                //  SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    height: 210,
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
                              duration:
                                  '${_formatDuration(tracker.elapsedTime)}',
                              distance:
                                  '${DistanceTracker().totalKm.toStringAsFixed(2)}',
                              avgSpeed:
                                  '${DistanceTracker().averageSpeed.toStringAsFixed(0)}',
                              topSpeed:
                                  '${DistanceTracker().topSpeed.toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(d.inHours);
    final m = twoDigits(d.inMinutes.remainder(60));
    final s = twoDigits(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }
}
