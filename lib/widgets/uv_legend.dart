import 'package:flutter/material.dart';

class UVLegend extends StatelessWidget {
  const UVLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "UV Index Guide",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _uvLegendBox(Colors.green, "0-2", "Low"),
                      _uvLegendBox(Colors.yellow, "3-5", "Moderate"),
                      _uvLegendBox(Colors.orange, "6-7", "High"),
                      _uvLegendBox(Colors.red, "8-10", "Very High"),
                      _uvLegendBox(Colors.purple, "11+", "Extreme"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uvLegendBox(Color color, String label, String levelLabel) {
    return Column(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
        Text(levelLabel, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
