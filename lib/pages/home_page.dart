import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onboarding/data/uvi_data.dart';
import 'package:onboarding/widgets/location_search_bar.dart';
import 'package:onboarding/widgets/small_card.dart';
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

  String getUVLevel(double uvIndex) {
    if (uvIndex <= 2)
      return "Low";
    else if (uvIndex <= 5)
      return "Moderate";
    else if (uvIndex <= 7)
      return "High";
    else if (uvIndex <= 10)
      return "Very High";
    else
      return "Extreme";
  }

  String _selectedPlaceName = "Melbourne, Australia";

  void _updatePlace(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place;
      _selectedPlaceName = place["name"] ?? "Unknown Location";
    });
    _futureUVIData = fetchUVI(place, _updateSource).then((data){
      setState(() {
      _scaffoldBackgroundGradient = getBackgroundColor(data.uv);
    });
    return data;
    });
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
    }, _updateSource).then((data) {
      setState(() {
        _scaffoldBackgroundGradient = getBackgroundColor(data.uv);
      });
      return data;
    });
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

  // bg color
  List<Color> getBackgroundColor(double uvIndex) {
    if (uvIndex <= 2)
      return [Colors.green.shade50, Colors.green.shade500];
    else if (uvIndex <= 5)
      return [Colors.yellow.shade100, Colors.yellow.shade500];
    else if (uvIndex <= 7)
      return [Colors.orange.shade100, Colors.orange.shade500];
    else if (uvIndex <= 10)
      return [Colors.red.shade100, Colors.red.shade500];
    else
      return [Colors.purple.shade100, Colors.purple.shade500];
  }

  List<Color> _scaffoldBackgroundGradient = [
    Colors.blue.shade100,
    Colors.blue.shade50,
  ];

  void _updateBackgroundGradient(double uvIndex) {
    setState(() {
      _scaffoldBackgroundGradient = getBackgroundColor(uvIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _scaffoldBackgroundGradient,
          ),
        ),
        child: Center(
          child: Column(
            children: <Widget>[
              LocationSearchBar(onValueChanged: _updatePlace),
              _buildLocation(),
              FutureBuilder<UVIData>(
                future: _futureUVIData,
                builder: (context, snapshot) {
                  double lottieWidth = 150;
                  double lottieHeight = 150;

                  if (snapshot.hasData) {
                    double uvIndex = snapshot.data!.uv;
                    
                    // List<Color> backgroundColor = getBackgroundColor(uvIndex);
                    String uvLevel = getUVLevel(uvIndex);

                    // UV with different Animation
                    String lottieAsset;
                    if (uvIndex <= 2) {
                      lottieAsset = "assets/lottie/night.json"; // UV low
                    } else if (uvIndex <= 5) {
                      lottieAsset = "assets/lottie/cloudy.json"; // UV Moderate
                    } else if (uvIndex <= 7) {
                      lottieAsset = "assets/lottie/sun.json"; // UV High
                      lottieWidth = 250;
                      lottieHeight = 200;
                    } else {
                      lottieAsset = "assets/lottie/warning.json"; // UV high
                    }

                    return Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: double.infinity,
                      // decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: _scaffoldBackgroundGradient,
                      //   ),
                      // ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 30),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Lottie.asset(
                                      lottieAsset,
                                      width: lottieWidth,
                                      height: lottieHeight,
                                      repeat: true,
                                      animate: true,
                                    ),
                                    const SizedBox(height: 10),

                                    Text(
                                      'UV ${snapshot.data!.uv.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${DateFormat('hh:mm a').format(DateTime.now())}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Last Updated: ${DateFormat('E dd/MM, hh:mm a').format(DateTime.parse(snapshot.data!.uvTime.toString()).toLocal())}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),

                                    const SizedBox(height: 4),
                                    Text(
                                      'Retrieved from $_uvAPISource',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SmallCard(
                                  label: "UV",
                                  value: uvLevel,
                                  subtext: "UV Level",
                                ),
                                SmallCard(
                                  label: "Max",
                                  // value: uvMax.toStringAsFixed(1),
                                  value: snapshot.data!.uv_max.toStringAsFixed(
                                    1,
                                  ),
                                  subtext: "Max UVI of Today",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
      ),
    );
  }
}
