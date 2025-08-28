import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


class FullscreenGaugePage extends StatelessWidget {


  final double speed;

  const FullscreenGaugePage({Key? key, required this.speed}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(

        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: RotatedBox(
            quarterTurns: 1, // Rotate 90 degrees to simulate landscape
            child: Center(
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
                    pointers: <GaugePointer>[
                      NeedlePointer(value: speed),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '${speed.toStringAsFixed(1)} km/h',
                          style: TextStyle(
                            fontSize: 24,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class FullScreenDigitalMeter extends StatefulWidget {
  final double speed;
  const FullScreenDigitalMeter({Key? key, required this.speed}) : super(key: key);

  @override
  State<FullScreenDigitalMeter> createState() => _FullScreenDigitalMeterState();
}

class _FullScreenDigitalMeterState extends State<FullScreenDigitalMeter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:GestureDetector(
        onTap: (){
          Navigator.pop(context);
        },
        child: RotatedBox(
          quarterTurns: 1,
          child: Center(
            child: Text(
              '${widget.speed.toStringAsFixed(1)} km/h',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
