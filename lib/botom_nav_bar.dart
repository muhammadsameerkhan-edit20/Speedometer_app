import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speedo_meter/gauge_selection_screen.dart';
import 'package:speedo_meter/history.dart';
import 'package:speedo_meter/settings.dart';

import 'Services/current_location_map.dart';

import 'digital_meter.dart';


import 'gauge_meter.dart';


class BottomNavigationBarItemScreen extends StatefulWidget {
  const BottomNavigationBarItemScreen({super.key});

  @override
  State<BottomNavigationBarItemScreen> createState() => _BottomNavigationBarItemScreenState();
}

class _BottomNavigationBarItemScreenState extends State<BottomNavigationBarItemScreen> {
  int currentindex=0;
  final List<Widget> _screens=[
    Center(child: SpeedometerScreen()),
    Center(child: DigitalSpeedScreen()),


    Center(child: CurrentLocationMap()),
    //  Center(child: GaugeSelectionScreen()),
  ];
  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent, // Keep transparent
          title: Text('Speedo Meter', style: TextStyle(color: Colors.white)),
          centerTitle: false,
          actions: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xff68DAE4), width: 1.5),
              ),
              child: IconButton(
                icon: Icon(Icons.settings_outlined, color: Color(0xff68DAE4)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
                },
              ),
            ),
            SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xff68DAE4), width: 1.5),
              ),
              child: IconButton(
                icon: Icon(Icons.history, color: Color(0xff68DAE4)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen()));
                },
              ),
            ),
          ],

        ),

          body: _screens[currentindex],

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xff141414),
            selectedItemColor: Color(0xff68DAE4),
            unselectedItemColor: Color(0xff869FA1),
            currentIndex: currentindex,
            onTap: (index) {
              setState(() {
                currentindex = index;
              });       },
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.shutter_speed),label:  'Gauge',),
              BottomNavigationBarItem(icon: Icon(Icons.speed),label: "Digital",),
      
              BottomNavigationBarItem(icon: Icon(Icons.map),label: 'Map',),
              // BottomNavigationBarItem(icon: Icon(Icons.label),text: 'Map',),
            ]),
        // body: BottomNavigationBarItemBarView(
        //   children: [
        //     Center(child: DigitalSpeedScreen()),
        //     Center(child: SpeedometerScreen()),
        //     Center(child: CurrentLocationMap()),
        //     Center(child: GaugeSelectionScreen()),
        //                 // Center(
        //     //   child: ElevatedButton(
        //     //     onPressed: () {
        //     //       Navigator.push(
        //     //         context,
        //     //         MaterialPageRoute(
        //     //           builder: (context) => SingleCity(
        //     //             cityData: {
        //     //               'name': 'Lahore',
        //     //               'address': 'Lahore, Punjab, Pakistan',
        //     //               'lat': 31.5497,
        //     //               'lng': 74.3436,
        //     //             },
        //     //           ),
        //     //         ),
        //     //       );
        //     //     },
        //     //     child: Text('Show Lahore on Map'),
        //     //   ),
        //     // ),
        //   ],
        // ),
      
      ),
    );
  }
}


