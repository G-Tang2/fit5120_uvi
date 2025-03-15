import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onboarding/data/uvi_data.dart';
import 'package:onboarding/widgets/location_search_bar.dart';
import 'package:lottie/lottie.dart';

Future<UVIData> fetchUVI(
  Map<String, dynamic> place,
  Function(String) updateSource,
) async {
  final String apiUrl =
      "https://api.openuv.io/api/v1/uv?lat=${place['lat']}&lng=${place['long']}&alt=100&dt=";
  final String accessToken = dotenv.get('OPEN_UV_API_KEY');

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "x-access-token": accessToken,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      updateSource('https://www.openuv.io/');
      return UVIData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load UVI data');
    }
  } catch (e) {
    // attempt to get UVI data from another source
    try {
      final response = await http.get(
        Uri.parse(
          'https://currentuvindex.com/api/v1/uvi?latitude=${place['lat']}&longitude=${place['lon']}',
        ),
      );

      if (response.statusCode == 200) {
        updateSource('https://currentuvindex.com');
        return UVIData.fromCurrentUVAPIJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load UVI data');
      }
    } catch (e) {
      throw Exception('Failed to load UVI data');
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Map<String, dynamic> _selectedPlace = {"lat":0.0, "lon":0.0};   //TODO: change to current location
  Map<String, dynamic> _selectedPlace = {"lat": -37.8142, "lon": 144.9631};
  late Future<UVIData> _futureUVIData;
  String _uvAPISource = '';
  // Color _sunColor = Colors.yellow;

  String _selectedPlaceName = "Melbourne, Australia";

  void _updatePlace(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place;
      _selectedPlaceName = place["name"] ?? "Unknown Location";
    });
    _futureUVIData = fetchUVI(place, _updateSource);
  }

  void _updateSource(String source) {
    setState(() {
      _uvAPISource = source;
    });
  }

  @override
  void initState() {
    super.initState();
    //TODO: get current coordinates
    _futureUVIData = fetchUVI({
      'lat': -37.8142454,
      'lon': 144.9631732,
    }, _updateSource);
  }

  Widget _buildLocation() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.location_on, color: Colors.redAccent),
        title: Text(
          _selectedPlaceName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text("Current Location"),
        subtitle: Text(
          'Lat: ${_selectedPlace["lat"]}, Lon: ${_selectedPlace["lon"]}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            LocationSearchBar(onValueChanged: _updatePlace),
            _buildLocation(),
            // Text('${_selectedPlace["lat"]} ${_selectedPlace["lon"]}'),
            FutureBuilder<UVIData>(
              future: _futureUVIData,
              builder: (context, snapshot) {
                double lottieWidth = 150;
                double lottieHeight = 150;

                if (snapshot.hasData) {
                  double uvIndex = snapshot.data!.uv;
                  // double uvIndex = 8;
                  // UV with different Animation
                  String lottieAsset;
                  if (uvIndex <= 2) {
                    lottieAsset = "assets/lottie/cloudy.json"; // UV low
                  } else if (uvIndex <= 5) {
                    lottieAsset = "assets/lottie/sun.json"; // UV Moderate
                    lottieWidth = 250;
                    lottieHeight = 250;
                  } else {
                    lottieAsset = "assets/lottie/warning.json"; // UV high
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Icon(Icons.wb_sunny, color: _sunColor, size: 100),
                      Lottie.asset(
                        lottieAsset,
                        width: lottieWidth,
                        height: lottieHeight,
                        repeat: true,
                        animate: true,
                      ),

                      Text('UV ${snapshot.data!.uv.toInt().toString()}'),
                      Text(
                        'Last Updated: ${DateFormat('E dd/MM, hh:mm a').format(DateTime.parse(snapshot.data!.uvTime.toString()).toLocal())}',
                      ),
                      Text('Retrieved from $_uvAPISource'),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
