import 'package:flutter/material.dart';

class UVAdvice extends StatelessWidget {
  final double uvIndex;

  const UVAdvice({Key? key, required this.uvIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String riskLevel;
    String advice;

    if (uvIndex < 3) {
      icon = Icons.sunny;
      riskLevel = "Low Risk";
      advice = "No protection needed. You can safely stay outside with minimal sun protection.";
    } else if (uvIndex < 6) {
      icon = Icons.sunny; // Hat icon
      riskLevel = "Moderate Risk";
      advice = "Seek shade during late morning through mid-afternoon. Use SPF-15 sunscreen, wear a hat, and sunglasses.";
    } else if (uvIndex < 8) {
      icon = Icons.umbrella; // Sunglasses icon
      riskLevel = "High Risk";
      advice = "Avoid outdoor exposure during peak hours. Use SPF-30 sunscreen, sunglasses, and protective clothing.";
    } else if (uvIndex < 11) {
      icon = Icons.warning_amber; // Warning icon
      riskLevel = "Very High Risk";
      advice = "Be extra careful outside! Seek shade, wear full protective gear, and apply SPF-50 sunscreen.";
    } else {
      icon = Icons.dangerous; // Extreme danger icon
      riskLevel = "Extreme Risk";
      advice = "Avoid sun exposure. Stay indoors if possible, wear UV-blocking clothing, and apply SPF-50+ sunscreen.";
    }

    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: _getUVLevelColor(uvIndex), size: 32),
        title: Text(
          riskLevel,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          advice,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
  Color _getUVLevelColor(double uvIndex) {
    if (uvIndex < 3) return Colors.green;
    else if (uvIndex < 6) return Colors.yellow;
    else if (uvIndex < 8) return Colors.orange;
    else if (uvIndex < 11) return Colors.red;
    else return Colors.purple;
  }
}
