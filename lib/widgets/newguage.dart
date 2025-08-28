import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'custom_gauge.dart';

class CustomSpeedometerGauge extends StatelessWidget {
  final double speed;





  const CustomSpeedometerGauge({super.key, required this.speed});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF043245), // dark teal background
      // body: Center(
      //   child: SfRadialGauge(

      //     axes: <RadialAxis>[
      //       RadialAxis(
      //         minimum: 0,
      //         maximum: 240,
      //         startAngle: 180,
      //         endAngle: 0,
      //         showAxisLine: true,
      //         radiusFactor: 0.85,
      //         canScaleToFit: true,
      //         axisLineStyle: AxisLineStyle(
      //           thickness: 0.3,
      //           thicknessUnit: GaugeSizeUnit.factor,
      //           cornerStyle: CornerStyle.bothCurve,
      //           gradient: SweepGradient(
      //             colors: [
      //               Colors.green,
      //               Colors.lime,
      //               Colors.yellow,
      //               Colors.orange,
      //               Colors.red,
      //             ],
      //             stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      //           ),
      //         ),
      //         majorTickStyle: const MajorTickStyle(
      //           length: 0.15,
      //           thickness: 2.5,
      //           color: Colors.white,
      //           lengthUnit: GaugeSizeUnit.factor,
      //         ),
      //         minorTickStyle: const MinorTickStyle(
      //           length: 0.08,
      //           thickness: 1.5,
      //           color: Colors.white,
      //           lengthUnit: GaugeSizeUnit.factor,
      //         ),
      //         interval: 30,
      //         minorTicksPerInterval: 2,
      //         axisLabelStyle: const GaugeTextStyle(
      //           color: Color(0xFF7FDBFF), // light blue-green color
      //           fontSize: 16,
      //           fontWeight: FontWeight.w600,
      //         ),
      //         pointers: <GaugePointer>[
      //           NeedlePointer(
      //             value: 30, // Set to 30 to match the image
      //             needleLength: 0.75,
      //             needleColor: Colors.white,
      //             needleStartWidth: 0,
      //             needleEndWidth: 10,
      //             knobStyle: const KnobStyle(
      //               color: Colors.black,
      //               borderColor: Color(0xFF7FDBFF),
      //               borderWidth: 5,
      //               knobRadius: 0.12,
      //               sizeUnit: GaugeSizeUnit.factor,
      //             ),
      //             tailStyle: const TailStyle(
      //               color: Color(0xFF7FDBFF),
      //               width: 8,
      //               length: 0.3,
      //               lengthUnit: GaugeSizeUnit.factor,
      //             ),
      //           ),
      //         ],
      //         annotations: const <GaugeAnnotation>[
      //           // Circle at 0 (green zone start)
      //           GaugeAnnotation(
      //             widget: CircleAvatar(
      //               radius: 10,
      //               backgroundColor: Colors.white,
      //               child: CircleAvatar(
      //                 radius: 8,
      //                 backgroundColor: Colors.green,
      //               ),
      //             ),
      //             angle: 180,
      //             positionFactor: 1.2,
      //           ),
      //           // Circle at 120 (yellow zone center)
      //           GaugeAnnotation(
      //             widget: CircleAvatar(
      //               radius: 10,
      //               backgroundColor: Colors.white,
      //               child: CircleAvatar(
      //                 radius: 8,
      //                 backgroundColor: Colors.yellow,
      //               ),
      //             ),
      //             angle: 90,
      //             positionFactor: 1.2,
      //           ),
      //           // Circle at 240 (red zone end)
      //           GaugeAnnotation(
      //             widget: CircleAvatar(
      //               radius: 10,
      //               backgroundColor: Colors.white,
      //               child: CircleAvatar(
      //                 radius: 8,
      //                 backgroundColor: Colors.red,
      //               ),
      //             ),
      //             angle: 0,
      //             positionFactor: 1.2,
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
      body: Center(
        child: CustomGauge(speed: 90),
      ),
    );
  }
}

class CustomGauge extends StatelessWidget {
  final double speed; // e.g., 0 - 240

  const CustomGauge({Key? key, required this.speed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 300),
      painter: GaugePainter(speed),
    );
  }
}
