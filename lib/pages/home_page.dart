import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onboarding/data/uvi_data.dart';
import 'package:onboarding/widgets/location_search_bar.dart';

Future<UVIData> fetchUVI(Map<String, dynamic> place, Function(String) updateSource) async{
  final String apiUrl = "https://api.openuv.io/api/v1/uv?lat=${place['lat']}&lng=${place['long']}&alt=100&dt=";
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
          final response = await http.get(Uri.parse('https://currentuvindex.com/api/v1/uvi?latitude=${place['lat']}&longitude=${place['lon']}'));

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
  Map<String, dynamic> _selectedPlace = {"lat":0.0, "lon":0.0};   //TODO: change to current location
  TextEditingController controller = TextEditingController();
  late Future<UVIData> _futureUVIData;
  String _uvAPISource = '';

  void _updatePlace(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place;
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
    _futureUVIData = fetchUVI({'lat': -37.8142454, 'lon': 144.9631732}, _updateSource);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: <Widget>[
          LocationSearchBar(onValueChanged: _updatePlace),
          Text('${_selectedPlace["lat"]} ${_selectedPlace["lon"]}'),
          FutureBuilder<UVIData>(
              future: _futureUVIData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('UV ${snapshot.data!.uv.toInt().toString()}'),
                      Text('Last Updated: ${DateFormat('E dd/MM, hh:mm a').format(DateTime.parse(snapshot.data!.uvTime.toString()).toLocal())}'),
                      Text('Retrieved from ${_uvAPISource}'),
                    ]
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
        ])
        ),
      );
  }
}