// lib/widgets/stat_row.dart

import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String title1;
  final String value1;
  final String title2;
  final String value2;

  const StatRow({
    Key? key,
    required this.title1,
    required this.value1,
    required this.title2,
    required this.value2,
  }) : super(key: key);

  Widget _buildStatBox(String title, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 80,
          color: Colors.cyan.shade50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,

                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        _buildStatBox(title1, value1),
        _buildStatBox(title2, value2),
      ],
    );
  }
}
