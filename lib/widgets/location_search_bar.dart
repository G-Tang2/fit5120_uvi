import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationSearchBar extends StatefulWidget {

  final Function(Map<String, dynamic>) onValueChanged;

  const LocationSearchBar({super.key, required this.onValueChanged});

  @override
  _LocationSearchBarState createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _changeTextFieldValue(String value) {
    setState(() {
      print(value);
      _controller.text = "hi";
    });
  }

  Future<List<Map<String, dynamic>>> _searchLocation(String query) async {
    if (query.isEmpty) return [];

    // retrieve top 5 locations from OpenStreetMap in Australia based on user input
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=AU");
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((place) {
        return {
          "name": place["display_name"],
          "lat": double.parse(place["lat"]),
          "lon": double.parse(place["lon"]),
        };
      }).toList();
    } else {
      throw Exception("Failed to fetch locations");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child:TypeAheadField<Map<String, dynamic>>(
      builder: (context, _controller, focusNode) {
        return TextField(
          controller: _controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: "Search Location",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
        );},
      suggestionsCallback: (query) => _searchLocation(query),
      emptyBuilder: (context) => Container(
          padding: const EdgeInsets.all(14),
          child: Text("No matching address")),
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(Icons.place),
          title: Text(suggestion["name"]),  // location suggestions to be displayed in the text field
        );
      },
      onSelected: (suggestion) {
        _changeTextFieldValue(suggestion["name"]);  // update text field with selected location
        widget.onValueChanged({'lat': suggestion["lat"], 'lon': suggestion["lon"], 'name': suggestion["name"] });  // update coordinates for uvi
      },
      )
    );
  }
}
