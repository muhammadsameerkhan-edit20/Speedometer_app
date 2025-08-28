import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Services/gps_status_service.dart';

class PermissionScreen extends StatefulWidget {
  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState() {
    super.initState();
    // Check GPS status when screen loads and start auto-refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gpsService = Provider.of<GpsStatusService>(context, listen: false);
      gpsService.checkAllStatuses();
      gpsService.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Stop auto-refresh when leaving the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GpsStatusService>(context, listen: false).stopAutoRefresh();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GpsStatusService(),
      child: Consumer<GpsStatusService>(
        builder: (context, gpsService, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Color(0xff68DAE4),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'GPS & Location Status',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF033438), Color(0xFF081214)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Status Overview Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xff68DAE4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              gpsService.isEverythingWorking 
                                ? Icons.check_circle 
                                : Icons.warning,
                              color: gpsService.isEverythingWorking 
                                ? Colors.green 
                                : Colors.orange,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              gpsService.isEverythingWorking 
                                ? "GPS Working" 
                                : "GPS Issues Detected",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          gpsService.statusMessage,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // GPS Status Card
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xff68DAE4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "GPS Status",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Location Services Status
                        _buildStatusRow(
                          "Location Services",
                          gpsService.isLocationServiceEnabled,
                          Icons.location_on,
                          onTap: () => gpsService.openLocationSettings(),
                        ),
                        
                        Divider(color: Colors.white24),
                        
                        // Location Permission Status
                        _buildStatusRow(
                          "Location Permission",
                          gpsService.isLocationPermissionGranted,
                          Icons.security,
                          onTap: () => gpsService.requestLocationPermission(),
                        ),
                        
                        Divider(color: Colors.white24),
                        
                        // GPS Signal Status
                        _buildStatusRow(
                          "GPS Signal",
                          gpsService.isGpsEnabled,
                          Icons.gps_fixed,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Auto-Refresh Toggle
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xff68DAE4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              color: Color(0xff68DAE4),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Auto-Refresh",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Automatically refresh GPS status every 5 seconds",
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Switch(
                              value: gpsService.isAutoRefreshEnabled,
                              onChanged: (value) => gpsService.toggleAutoRefresh(),
                              activeColor: Color(0xff68DAE4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Action Buttons
                  if (!gpsService.isEverythingWorking) ...[
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => gpsService.checkAllStatuses(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff68DAE4),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Refresh Status",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    Container(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => gpsService.openLocationSettings(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xff68DAE4),
                          side: BorderSide(color: Color(0xff68DAE4), width: 2),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Open Location Settings",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String title, bool isWorking, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isWorking ? Colors.green : Colors.red,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isWorking ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isWorking ? "ON" : "OFF",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Color(0xff68DAE4),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

