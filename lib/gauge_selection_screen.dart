import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedo_meter/widgets/newmete2.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'botom_nav_bar.dart';
import 'gauge_meter.dart';
import 'widgets/newguage.dart';
import 'widgets/custom_gauge.dart';
import 'widgets/digital_speedometer.dart';

class GaugeSelectionScreen extends StatefulWidget {
  @override
  _GaugeSelectionScreenState createState() => _GaugeSelectionScreenState();
}

class _GaugeSelectionScreenState extends State<GaugeSelectionScreen> {
  int selectedGaugeIndex = 0;
  double demoSpeed = 30.0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<Map<String, dynamic>> gaugeOptions = [
    {
      'name': 'Default Gauge',
      'description': 'Standard circular gauge with ranges',
      'widget': (double speed) => Container(
        height: 300,
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 180,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: 60, color: Colors.green),
                GaugeRange(startValue: 60, endValue: 120, color: Colors.orange),
                GaugeRange(startValue: 120, endValue: 180, color: Colors.red),
              ],
              pointers: <GaugePointer>[NeedlePointer(value: speed)],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '${speed.toStringAsFixed(1)} km/h',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        ),
      ),
    },
    {
      'name': 'Custom Gauge',
      'description': 'Custom painted gauge with gradient',
      'widget': (double speed) => Container(
        height: 300,
        child: CustomPaint(size: Size(300, 300), painter: GaugePainter(speed)),
      ),
    },
    {
      'name': 'Digital Speedometer',
      'description': 'Futuristic digital speedometer with frame',
      'widget': (double speed) => Container(
        height: 300,
        child: DigitalSpeedometer(speed: speed, totalDistance: 0),
      ),
    },
    {
      'name': 'Enhanced Gauge',
      'description': 'Improved gauge with better styling',
      'widget': (double speed) =>
          Container(height: 300, child: CustomSpeedometerGauge(speed: speed)),
    },
    {
      'name': 'Enhanced Gauge',
      'description': 'Improved gauge with better styling',
      'widget': (double speed) => Container(
        height: 300,
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: speed,
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
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, // ← change to your desired color
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),

              title: Text(

                'Select Analog Style',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),


            ),
            body: Column(

              children: [
                // Demo speed slider
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(height: 25,),
                      Text(
                        'Demo Speed: ${demoSpeed.toStringAsFixed(1)} km/h',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                      Slider(
                        value: demoSpeed,
                        min: 0,
                        max: 240,

                        activeColor: Color(0xff68DAE4),
                        divisions: 240,
                        label: '${demoSpeed.toStringAsFixed(1)} km/h',
                        onChanged: (value) {
                          setState(() {
                            demoSpeed = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Gauge preview
SizedBox(height: 39,),
                Flexible(
                  child: CarouselSlider(
                    items: gaugeOptions.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Color(0xff141414),

                              border: Border.all(color: Color(0xff68DAE4)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: i['widget'](demoSpeed),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: 320,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() => selectedGaugeIndex = index);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 70),

                // Gauge selection
                // Expanded(
                //   child: ListView.builder(
                //     padding: EdgeInsets.symmetric(horizontal: 16),
                //     itemCount: gaugeOptions.length,
                //     itemBuilder: (context, index) {
                //       final gauge = gaugeOptions[index];
                //       final isSelected = selectedGaugeIndex == index;
                //
                //       return Card(
                //         margin: EdgeInsets.only(bottom: 12),
                //         elevation: isSelected ? 8 : 2,
                //         color: isSelected ? Colors.blue.shade50 : Colors.white,
                //         child: ListTile(
                //           leading: Container(
                //             width: 50,
                //             height: 50,
                //             decoration: BoxDecoration(
                //               color: isSelected ? Colors.blue : Colors.grey.shade200,
                //               borderRadius: BorderRadius.circular(8),
                //             ),
                //             child: Icon(
                //               Icons.speed,
                //               color: isSelected ? Colors.white : Colors.grey.shade600,
                //             ),
                //           ),
                //           title: Text(
                //             gauge['name'],
                //             style: TextStyle(
                //               fontWeight: isSelected
                //                   ? FontWeight.bold
                //                   : FontWeight.normal,
                //               color: isSelected
                //                   ? Colors.blue.shade800
                //                   : Colors.black87,
                //             ),
                //           ),
                //           subtitle: Text(
                //             gauge['description'],
                //             style: TextStyle(
                //               color: isSelected
                //                   ? Colors.blue.shade600
                //                   : Colors.grey.shade600,
                //             ),
                //           ),
                //           trailing: isSelected
                //               ? Icon(Icons.check_circle, color: Colors.blue, size: 24)
                //               : null,
                //           onTap: () {
                //             setState(() {
                //               selectedGaugeIndex = index;
                //             });
                //           },
                //         ),
                //       );
                //     },
                //   ),
                // ),

                // Apply button
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setInt(
                              'selectedGaugeIndex',
                              selectedGaugeIndex,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BottomNavigationBarItemScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff68DAE4),

                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff141414),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            pointers: <GaugePointer>[
              NeedlePointer(
                value: 65,
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
    ),
  );
}
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF033438), Color(0xFF081214)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
