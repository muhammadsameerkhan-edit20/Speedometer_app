import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Database/database_helper.dart';
import 'gauge_selection_screen.dart';
import 'permissions_screen.dart';
import 'theme_selection_screen.dart';
import 'theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int speedUnit = 0; // 0: Km/h, 1: Mph, 2: Knot
  int maxSpeed = 340;
  bool showSpeedInNotification = true;
  bool speedLimitAlarm = false;
  bool enableTrackingOnMap = true;
  bool keepScreenOn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  bool _isSpeedAlertEnabled = true;
  final String _alertPrefKey = "isSpeedAlertEnabled";

  Future<void> setSpeedAlertEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSpeedAlertEnabled', value);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      speedUnit = prefs.getInt('speedUnit') ?? 0;
      maxSpeed = prefs.getInt('maxSpeed') ?? 340;
      showSpeedInNotification =
          prefs.getBool('showSpeedInNotification') ?? true;
      speedLimitAlarm = prefs.getBool('speedLimitAlarm') ?? false;
      enableTrackingOnMap = prefs.getBool('enableTrackingOnMap') ?? true;
      keepScreenOn = prefs.getBool('keepScreenOn') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showRateUsDialog() {
    int selectedRating = 1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            height: 230,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Icon(
                    Icons.thumb_up_alt_outlined,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Enjoying the app? Let us know!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRating = index + 1;
                              });
                            },
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 35,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnack(
                          "Thanks for rating us $selectedRating stars!",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Rate",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 40,
                        width: 70,
                        child: Center(
                          child: Text(
                            "Later",
                            style: TextStyle(
                              color: Color(0xff7A7A7A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _speedLimit = 80;
  void _openPrivacyPolicy() async {
    const url = 'https://your-privacy-policy-url.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showSnack('Could not open Privacy Policy');
    }
  }

  Future<void> _loadSpeedLimit() async {
    final dbLimit = await DatabaseHelper().getSpeedLimit();
    setState(() {
      _speedLimit = dbLimit.toInt();
    });
  }

  void _openFeedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      query: 'subject=App Feedback',
    );
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      _showSnack('Could not open email client');
    }
  }

  void _shareApp() async {
    await Share.share(
      'Check out my app: https://play.google.com/store/apps/details?id=com.yourcompany.app',
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text("Exit", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  "Are you sure you want to exit?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 40,
                    width: 70,
                    child: Center(
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          color: Color(0xff7A7A7A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Exit", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SafeArea(
          child: GradientBackground(



        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: IconThemeData(

              color: Colors.white, // ← change to your desired color
            ),

            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: true,
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back, color: Colors.white),
            //   onPressed: () => Navigator.pop(context),
            // ),
            title: Text(

              'Settings',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF033438), Color(0xFF081214)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              children: [
                // Permission Setting Card
                _sectionCard(
                  child: ListTile(
                    title: Text(
                      "Permission Setting",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xff68DAE4),
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PermissionScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                _sectionCard(
                  child: ListTile(
                    title: Text(
                      "Theme ",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xff68DAE4),
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ThemeSelectionScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Analog Style Selection Card
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Analog Style",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Current selected style display
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xff68DAE4), width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.speed,
                              color: Color(0xff68DAE4),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Classic Analog Gauge",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              color: Color(0xff68DAE4),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      // Style selection buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => GaugeSelectionScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff68DAE4),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                "Change Style",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Speed Unit Card
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Speed Unit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _speedUnitButton("Km/H", 0),
                          _speedUnitButton("Mph", 1),
                          _speedUnitButton("Knot", 2),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.tealAccent, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Speed Warning",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
        
                      // Max Speed Limit Expandable
                      ExpansionTile(
                        title: Text(
                          "Max Speed Limit Warn",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "$maxSpeed Km/h",
                          style: TextStyle(color: Colors.grey),
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.black),
                                onPressed: () async {
                                  setState(() {
                                    if (maxSpeed > 0) maxSpeed--;
                                  });
                                  await DatabaseHelper().updateSpeedLimit(
                                    maxSpeed.toDouble(),
                                  );
                                  await _loadSpeedLimit();
                                  Navigator.of(context).pop(); // close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Speed limit updated to $maxSpeed',
                                      ),
                                    ),
                                  );
                                  _saveSetting('maxSpeed', maxSpeed);
                                }, // handle minus
                                color: Colors.cyan,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.cyan,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  "$maxSpeed",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.black),
                                onPressed: () async {
                                  setState(() {
                                    if (maxSpeed > 0) maxSpeed++;
                                  });
                                  await DatabaseHelper().updateSpeedLimit(
                                    maxSpeed.toDouble(),
                                  );
                                  await _loadSpeedLimit();
                                  Navigator.of(context).pop(); // close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Speed limit updated to $maxSpeed',
                                      ),
                                    ),
                                  );
                                  _saveSetting('maxSpeed', maxSpeed);
                                }, // handle add
                                color: Colors.cyan,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.cyan,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
        
                      // Analog Meter Max Speed (collapsed initially)
        
                      // Show speed in notification
        
                      // Speed limit alarm
                      SwitchListTile(
                        value: _isSpeedAlertEnabled,
                        onChanged: (value) async {
                          print(maxSpeed);
                          setState(() {
                            _isSpeedAlertEnabled = value;
                          });
                          setSpeedAlertEnabled(value);
                        },
                        activeColor: Colors.cyan,
                        title: Text(
                          "Speed limit alarm",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
        
                // Speed Warning Card
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Speed Warning",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.cyan),
                            onPressed: () {
                              setState(() {
                                if (maxSpeed > 0) maxSpeed--;
                              });
                              _saveSetting('maxSpeed', maxSpeed);
                            },
                          ),
                          Text(
                            "$maxSpeed",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.cyan),
                            onPressed: () {
                              setState(() {
                                maxSpeed++;
                              });
                              _saveSetting('maxSpeed', maxSpeed);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Analog meter max speed",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      SwitchListTile(
                        value: showSpeedInNotification,
                        onChanged: (val) {
                          setState(() => showSpeedInNotification = val);
                          _saveSetting('showSpeedInNotification', val);
                        },
                        activeColor: Colors.cyan,
                        title: Text(
                          "Show speed in notification",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "Allow you to display speed in notification",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          activeColor: Colors.amber,
                          value: _isSpeedAlertEnabled,
                          onChanged: (value) async {
                            print(maxSpeed);
                            setState(() {
                              _isSpeedAlertEnabled = value;
                            });
                            setSpeedAlertEnabled(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Speed Warning 2nd Card
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Speed Warning",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SwitchListTile(
                        value: enableTrackingOnMap,
                        onChanged: (val) {
                          setState(() => enableTrackingOnMap = val);
                          _saveSetting('enableTrackingOnMap', val);
                        },
                        activeColor: Colors.cyan,
                        title: Text(
                          "Enable Tracking On Map",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SwitchListTile(
                        value: keepScreenOn,
                        onChanged: (val) {
                          setState(() => keepScreenOn = val);
                          _saveSetting('keepScreenOn', val);
                        },
                        activeColor: Colors.cyan,
                        title: Text(
                          "Keep Screen On",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Support Us Card
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Support Us",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _supportTile("Share app", _shareApp),
                      _supportTile("Rate us", _showRateUsDialog),
                      _supportTile("Privacy Policy", _openPrivacyPolicy),
                      _supportTile("Feedback", _openFeedback),
                      _supportTile("Exit", _confirmExit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
        );
      },
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xff68DAE4), width: 1.5),
      ),
      child: child,
    );
  }

  Widget _speedUnitButton(String label, int index) {
    bool selected = speedUnit == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => speedUnit = index);
          _saveSetting('speedUnit', index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Color(0xff68DAE4) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _supportTile(String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(color: Colors.white)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Color(0xff68DAE4),
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
