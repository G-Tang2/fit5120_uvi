import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:onboarding/data/uvi_data.dart';
import 'package:onboarding/widgets/location_search_bar.dart';

class SettingsPage extends StatefulWidget {
  final String title;
  const SettingsPage({super.key, required this.title});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  String _selectedSkinType = "Fair"; // Default selected skin type
  String _selectedPlaceName = "Melbourne, Australia";
  List<Map<String, dynamic>> _uviData = [];
  final List<String> _skinTypes = ["Fair", "Olive", "Brown", "Black"];
  bool _isLoading = false;
  String? _errorMessage;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchData(_selectedPlaceName); // Fetch data for Melbourne on startup
    _tabController = TabController(length: 2, vsync: this);
  }

  void _updatePlace(Map<String, dynamic> place) {
    setState(() {
      _selectedPlaceName = place["name"] ?? "Unknown Location";
    });
    fetchData(_selectedPlaceName);
  }

  Future<void> fetchData(String place) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, double> coordinates = await getCoordinates(place);
      List<Map<String, dynamic>> data = await fetchUVForecast(coordinates['lat']!, coordinates['lon']!);
      
      setState(() {
        _uviData = data.map((entry) {
          double uvi = entry['uvi'].toDouble();
          return {
            'time': entry['time'],
            'uvi': uvi,
            'time_to_burn': calculateTimeToBurn(uvi, _selectedSkinType)
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  double calculateTimeToBurn(double uvi, String skinType) {
    if (uvi <= 0) return double.infinity;
    double skinFactor;
    switch (skinType.toLowerCase()) {
      case 'fair': skinFactor = 3; break;
      case 'olive': skinFactor = 5; break;
      case 'brown': skinFactor = 8; break;
      case 'black': skinFactor = 15; break;
      default: skinFactor = 2.5;
    }
    return (200 * skinFactor) / (3 * uvi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive graphs"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "UV Index"),
            Tab(text: "Time to Burn"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Change Location",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LocationSearchBar(onValueChanged: _updatePlace),
            const SizedBox(height: 20),
            Text(
              "Selected Location: $_selectedPlaceName",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)))
                      : _uviData.isEmpty
                          ? const Center(child: Text("No UVI data available."))
                          : TabBarView(
                              controller: _tabController,
                              children: [
                                _buildUVIChart(),
                                Column(
                                  children: [
                                    DropdownButton<String>(
                                      value: _selectedSkinType,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedSkinType = newValue!;
                                          fetchData(_selectedPlaceName);
                                        });
                                      },
                                      items: _skinTypes.map((String type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                    ),
                                    Expanded(child: _buildBurnTimeChart()),
                                  ],
                                ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUVIChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: "UV Index Forecast"),
      series: <LineSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          dataSource: _uviData.map((data) => 
            ChartData(DateFormat.Hm().format(DateTime.parse(data['time']).toLocal()), data['uvi'])).toList(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildBurnTimeChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
      title: AxisTitle(text: "Forecast Time"),
      labelRotation: 45, // Helps readability if overlapping occurs
    ),
      primaryYAxis: NumericAxis(
      minimum: 0,
      title: AxisTitle(text: 'Time to Burn (Minutes)'),
    ),
    title: ChartTitle(text: "Time to Burn Forecast (Minutes)"),
    series: <LineSeries<ChartData, String>>[
        LineSeries<ChartData, String>(
          dataSource: _uviData.map((data) {
            double burnTime = calculateTimeToBurn(data['uvi'], _selectedSkinType);
            return ChartData(DateFormat.Hm().format(DateTime.parse(data['time']).toLocal()), burnTime.isFinite ? burnTime : 9999);
          }).toList(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        name: "Time to Burn (min)",
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}


Future<List<Map<String, dynamic>>> fetchUVForecast(double lat, double lon) async {
  try {
    final response = await http.get(
      Uri.parse('https://currentuvindex.com/api/v1/uvi?latitude=$lat&longitude=$lon'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      UVIData uviData = UVIData.fromJson(data);

      if (uviData.ok) {
        DateTime now = DateTime.now().toUtc().add(const Duration(hours: 11));
        DateTime endTime = now.add(const Duration(hours: 24));

        List<Map<String, dynamic>> filteredData = uviData.forecast!.where((entry) {
          DateTime entryTime = DateTime.parse(entry['time']).toUtc().add(const Duration(hours: 11));
          return entryTime.isAfter(now) && entryTime.isBefore(endTime);
        }).toList();

        print("Fetched UVI Data: $filteredData");
        return filteredData;
      } else {
        throw Exception(uviData.message);
      }
    } else {
      throw Exception('Failed to load UVI data. Status Code: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching UVI data: $e');
  }
}

Future<Map<String, double>> getCoordinates(String place) async {
  final response = await http.get(
    Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$place'),
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      for (var location in data) {
        String displayName = location['display_name'].toString();
        if (displayName.contains("Australia")) { // Check if it's in Australia
          double lat = double.parse(location['lat']);
          double lon = double.parse(location['lon']);
          return {'lat': lat, 'lon': lon};
        }
      }
      throw Exception("Location not in Australia. Please choose an Australian location.");
    } else {
      throw Exception("Location not found. Try another name.");
    }
  } else {
    throw Exception("Failed to fetch coordinates. Status Code: ${response.statusCode}");
  }
}
