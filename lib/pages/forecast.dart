import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:onboarding/data/uvi_data.dart';
import 'package:onboarding/widgets/location_search_bar.dart';

class ForecastPage extends StatefulWidget {
  final String title;
  const ForecastPage({super.key, required this.title});

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> with SingleTickerProviderStateMixin {
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

      //           olumn(children: [
    //             Text("Change Location",
    //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //             ),
    //             const SizedBox(height: 10),
    //             LocationSearchBar(onValueChanged: _updatePlace),
    //             const SizedBox(height: 20),
    //             Text(
    //               "Selected Location: $_selectedPlaceName",
    //               style: const TextStyle(fontSize: 16),
    //             )]),

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Scaffold(
      appBar: AppBar(
        title: const Text("24 hour Forecast"),
        centerTitle: true,
        backgroundColor: Color(0xFFF8BC9B).withValues(alpha: 0.8),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFF89B9B),
          tabs: const [
            Tab(text: "UV Index"),
            Tab(text: "Time to Burn"),
          ],
        ),
      ),
      body: SingleChildScrollView(child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
          ),
        child: SizedBox(
          height: 680,
          child: 
            Padding(
              padding: EdgeInsets.all(0),
              child:
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUVIChart(),_buildBurnTimeChart(),
                    ],
                    ),
              )
            )
          )
      )
      )
    );
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
      ),
    );
  }

  Widget _buildUVIChart() {
    return Padding(padding: EdgeInsets.all(30), 
                  child: Column(children: [
                    Text("Enter an Australian location to view the UV Index forecast.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: LocationSearchBar(onValueChanged: _updatePlace),
                    ),
                    SizedBox(width: 600, child: _buildLocation()),
                    SizedBox(height: 20),
                    SfCartesianChart(
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
                    )
                  ]
                )
        );
  }

  Widget _buildBurnTimeChart() {
    return Padding(padding: EdgeInsets.all(30), 
                  child: Column(children: [
                    Text("Enter an Australian location to view the time to burn forecast.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: LocationSearchBar(onValueChanged: _updatePlace),
                  ),
                  SizedBox(width: 600, child: _buildLocation()),
                  // const SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.all(16),
                    color: Color(0xFFF8BC9B).withValues(alpha: 0.9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: SizedBox(
                      width: 200,
                      child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            const Text("Skin Type:   ", style: TextStyle(fontSize: 16)),
                            DropdownButton<String>(
                              value: _selectedSkinType,
                              focusColor: Color(0xFFF8BC9B).withValues(alpha: 0.9),
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
                            )
                          ],
                        )
                    )
                  ),
                                const SizedBox(height: 20),
                SfCartesianChart(
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
                )
              ]
            )
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
