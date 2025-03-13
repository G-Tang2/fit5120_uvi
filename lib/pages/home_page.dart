import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onboarding/data/uvi_data.dart';
import 'package:onboarding/widgets/location_search_bar.dart';

Future<UVIData> fetchUVI(Map<String, dynamic> place) async{
  final response = await http.get(Uri.parse('https://currentuvindex.com/api/v1/uvi?latitude=${place['lat']}&longitude=${place['lon']}'));

  if (response.statusCode == 200) {
    return UVIData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load UVI data');
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

  void _updatePlace(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place;
    });
    _futureUVIData = fetchUVI(place);
  }

  @override
  void initState() {
    super.initState();
    //TODO: get current coordinates
    _futureUVIData = fetchUVI({'lat': -37.8142454, 'lon': 144.9631732});
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
                      Text('UV ${snapshot.data!.now.uvi.toInt().toString()}'),
                      Text(DateFormat('hh:mm a').format(DateTime.parse(snapshot.data!.now.time.toString()).toLocal())),
                      Text('Retrieved from https://currentuvindex.com'),
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