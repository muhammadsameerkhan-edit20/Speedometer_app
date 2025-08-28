// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'botom_nav_bar.dart';
import 'theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff68DAE4),));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Speedometer App',
            theme: themeProvider.currentTheme,
            home: GradientBackground(
              child: const BottomNavigationBarItemScreen(),
            ),
          );
        },
      ),
    );
  }
}


class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.isDarkTheme 
                ? [Color(0xFF033438), Color(0xFF081214)]
                : [Color(0xFFE8F5E8), Color(0xFFF0F8F0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: this.child,
        );
      },
    );
  }
}


class TripStatsCard extends StatelessWidget {
  final String duration;
  final String distance;
  final String avgSpeed;
  final String topSpeed;

  const TripStatsCard({
    Key? key,
    required this.duration,
    required this.distance,
    required this.avgSpeed,
    required this.topSpeed,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _StatColumn(
                  label: 'Duration',
                  value: duration,
                  unit: '',
                ),
                _VerticalDivider(),
                _StatColumn(
                  label: 'Distance',
                  value: distance,
                  unit: 'km',
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                _StatColumn(
                  label: 'Avg Speed',
                  value: avgSpeed,
                  unit: 'km/h',
                ),
                _VerticalDivider(),
                _StatColumn(
                  label: 'Top Speed',
                  value: topSpeed,
                  unit: 'km/h',
                ),
              ],
            ),
           // const SizedBox(height:14),


          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatColumn({
    required this.label,

    required this.value,
    required this.unit,
  });


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF68DAE4),

                  fontSize: 30,
                  fontFamily: 'Digital', // Use your digital font here
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    unit,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class startButton extends StatelessWidget {
  final VoidCallback? onStart;
  const startButton({super.key, required this.onStart,   });

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF68DAE4),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            color: Color(0xff032B29),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Start Trip'),
            SizedBox(width: 8),
            Icon(Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}
class customButton extends StatelessWidget {
  final VoidCallback? onStart;
  String text;
      final Color bgColor;
   customButton({super.key, required this.onStart,   required this.text, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


